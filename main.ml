open Angstrom

(* parser *)
let keyword str = 
    string_ci str >>= fun _ -> return str

let type_parser = 
  (keyword "INT" >>= fun _ -> return "INT") 
  <|> (keyword "CHAR" >>= fun _ -> many1 (satisfy (function '(' | ')' -> false | _ -> true)) >>= fun n -> return ("CHAR(" ^ String.concat "" n ^ ")"))

let sql_statement =
  let create_database = keyword "CREATE" >>= fun _ -> keyword "DATABASE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun db -> return ("CREATE DATABASE " ^ db)
  let use_database = keyword "USE" >>= fun _ -> keyword "DATABASE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun db -> return ("USE DATABASE " ^ db)
  let create_table = keyword "CREATE" >>= fun _ -> keyword "TABLE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun table -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun column -> type_parser >>= fun typ -> return ("CREATE TABLE " ^ table ^ " (" ^ column ^ " " ^ typ ^ ")")
  let show_tables = keyword "SHOW" >>= fun _ -> keyword "TABLES" >>= fun _ -> return "SHOW TABLES"
  let insert = keyword "INSERT" >>= fun _ -> keyword "INTO" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun table -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun values -> return ("INSERT INTO " ^ table ^ " VALUES (" ^ values ^ ")")
  let select = keyword "SELECT" >>= fun _ -> many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun columns -> keyword "FROM" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun table -> return ("SELECT " ^ columns ^ " FROM " ^ table)
  let update = keyword "UPDATE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun table -> keyword "SET" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun values -> return ("UPDATE " ^ table ^ " SET " ^ values)
  let drop_table = keyword "DROP" >>= fun _ -> keyword "TABLE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun table -> return ("DROP TABLE " ^ table)
  let drop_database = keyword "DROP" >>= fun _ -> keyword "DATABASE" >>= fun _ -> space >>= many1 (satisfy (function ' ' -> false | _ -> true)) >>= fun db -> return ("DROP DATABASE " ^ db)
  let exit = keyword "EXIT" >>= fun _ -> return "EXIT"
  in 
  create_database <|> use_database <|> create_table <|> show_tables <|> insert <|> select <|> update <|> drop_table <|> drop_database <|> exit

let parse_sql str =
  match parse_only sql_statement (String.to BUFFER str) with
  | Ok sql -> sql
  | Error err -> "Parse error: " ^ err

(* test sql parser *)
let test_sql = "CREATE TABLE users (id INT, name CHAR(50));"
let result = parse_sql test_sql

(* executor, use csv file as database *)
module CsvTable = struct
  type t = {
    headers: string list;
    rows: string list list;
  }

  let create headers rows = { headers; rows }

  let to_string table =
    let headers = String.concat "," table.headers in
    let rows = List.map (String.concat ",") table.rows in
    String.concat "\n" (headers :: rows)
end

module Database = struct
  type t = {
    name: string;
    tables: (string, CsvTable.t) Hashtbl.t;
  }

  let create name = { name; tables = Hashtbl.create 10 }

  let add_table db table_name table =
    db.tables |> Hashtbl.add table_name table

  let get_table db table_name =
    try Some (Hashtbl.find db.tables table_name)
    with Not_found -> None
end

module Environment = struct
  type t = {
    current_db: Database.t option;
  }

  let create () = { current_db = None }

  let use_database env db_name =
    match env.current_db with
    | Some db -> if db.name = db_name then env else { env with current_db = Some (Database.create db_name) }
    | None -> { env with current_db = Some (Database.create db_name) }
end

let execute_sql env sql =
  let open Angstrom in
  match parse_only sql_statement (String.to_buffer sql) with
  | Ok "EXIT" -> env
  | Ok sql ->
      let env' =
        match String.split_on_char ' ' sql with
        | ["CREATE"; "DATABASE"; db_name] ->
            let db = Database.create db_name in
            { env with Environment.current_db = Some db }
        | ["USE"; "DATABASE"; db_name] ->
            match env.Environment.current_db with
            | Some db -> if db.Database.name = db_name then env else Environment.use_database env db_name
            | None -> Environment.use_database env db_name
        | ["CREATE"; "TABLE"; table_name; "("; column_name; column_type; ")"] ->
            match env.Environment.current_db with
            | Some db ->
                let headers = [column_name] in
                let table = CsvTable.create headers [] in
                Database.add_table db table_name table;
                env
            | None -> env
        | ["SHOW"; "TABLES"] ->
            match env.Environment.current_db with
            | Some db ->
                let tables = Hashtbl.fold (fun table_name _ acc -> table_name :: acc) db.Database.tables [] in
                List.iter print_endline tables;
                env
            | None -> env
        | ["INSERT"; "INTO"; table_name; "VALUES"; "("; values; ")"] ->
            match env.Environment.current_db with
            | Some db ->
                match Database.get_table db table_name with
                | Some table ->
                    let row = String.split_on_char ',' values in
                    let table' = { table with CsvTable.rows = row :: table.CsvTable.rows } in
                    Database.add_table db table_name table';
                    env
                | None -> env
            | None -> env
        | ["SELECT"; "*"; "FROM"; table_name] ->
            match env.Environment.current_db with
            | Some db ->
                match Database.get_table db table_name with
                | Some table ->
                    let rows = List.rev table.CsvTable.rows in
                    List.iter (fun row -> print_endline (String.concat "," row)) rows;
                    env
                | None -> env
            | None -> env
        | ["DROP"; "TABLE"; table_name] ->
            match env.Environment.current_db with
            | Some db ->
                Hashtbl.remove db.Database.tables table_name;
                env
            | None -> env
        | ["DROP"; "DATABASE"; db_name] ->
            match env.Environment.current_db with
            | Some db ->
                if db.Database.name = db_name then
                  { env with Environment.current_db = None }
                else
                  env
            | None -> env
        | _ -> env
      in
      env'
  | Error err -> failwith ("Parse error: " ^ err)


let rec repl env =
  print_endline "SQL> ";
  match read_line () with
  | None -> env
  | Some line ->
      let env' = execute_sql env line in
      repl env'
