(* Implement the evaluator *)
open Printf
open Csv

(* Define a type for table *)
type table = {
  name: string;
  columns: (string * column_type) list;
  data: string list list;
}

(* Define a type for database *)
type database = {
  name: string;
  tables: table list;
}

(* Placeholder functions for database operations *)
let create_database db_name = { name = db_name; tables = [] }
let find_database db_name = (* Implement logic to find the database folder *)

let use_database db_name =
  match find_database db_name with
  | Some db -> db
  | None -> failwith "Database not found"

let create_table db table_name columns =
  let db = use_database db in
  if List.exists (fun t -> t.name = table_name) db.tables then
    failwith "Table already exists"
  else
    let new_table = { name = table_name; columns = columns; data = [] } in
    { db with tables = new_table :: db.tables }

let rec find_table db table_name =
  match db.tables with
  | [] -> None
  | t :: ts -> if t.name = table_name then Some t else find_table { db with tables = ts } table_name

let show_tables () =
  let db = use_database "" in
  List.iter (fun t -> printf "%s\n" t.name) db.tables

let insert_into_table db table_name values =
  let db = use_database db in
  match find_table db table_name with
  | Some table ->
    if List.length values <> List.length table.columns then
      failwith "Number of values does not match number of columns"
    else
      let row = List.map2 (fun (col_name, _) value -> value) table.columns values in
      let updated_table = { table with data = row :: table.data } in
      { db with tables = updated_table :: List.filter (fun t -> t.name <> table_name) db.tables }
  | None -> failwith "Table not found"

let select_from_table db table_name columns =
  let db = use_database db in
  match find_table db table_name with
  | Some table ->
    let rec filter_columns row =
      match columns with
      | [] -> []
      | col :: cols ->
        match List.assoc_opt col table.columns with
        | Some _ -> (
            match List.assoc_opt col row with
            | Some value -> value :: filter_columns row cols
            | None -> failwith "Column not found in row"
          )
        | None -> failwith "Column not found in table"
    in
    List.map (fun row -> filter_columns row) table.data
  | None -> failwith "Table not found"

let update_table db table_name updates =
  let db = use_database db in
  match find_table db table_name with
  | Some table ->
    let rec update_row row =
      match updates with
      | [] -> row
      | (col, value) :: rest ->
        let updated_row =
          match List.assoc_opt col table.columns with
          | Some _ -> (col, value) :: List.filter (fun (c, _) -> c <> col) row
          | None -> failwith "Column not found in table"
        in
        update_row updated_row rest
    in
    let updated_data = List.map (fun row -> update_row row updates) table.data in
    let updated_table = { table with data = updated_data } in
    { db with tables = updated_table :: List.filter (fun t -> t.name <> table_name) db.tables }
  | None -> failwith "Table not found"

let drop_table db table_name =
  let db = use_database db in
  match find_table db table_name with
  | Some _ ->
    { db with tables = List.filter (fun t -> t.name <> table_name) db.tables }
  | None -> failwith "Table not found"

let drop_database db_name = None
  

(* Implement the evaluator *)
let rec eval_statement statement = match statement with
  | CreateDatabase db_name -> create_database db_name
  | UseDatabase db_name -> use_database db_name
  | CreateTable (table_name, columns) -> create_table "" table_name columns
  | ShowTables -> show_tables (); use_database ""
  | Insert (table_name, values) -> insert_into_table "" table_name values; use_database ""
  | Select (columns) -> select_from_table "" columns; use_database ""
  | Update (table_name, updates) -> update_table "" table_name updates; use_database ""
  | DropTable table_name -> drop_table "" table_name; use_database ""
  | DropDatabase db_name -> drop_database db_name
  | Exit -> exit 0

let eval_ast ast =
  match ast with
  | statement -> eval_statement statement
