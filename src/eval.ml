open Csv
open Ast

(* 当前使用的数据库路径 *)
let current_db = ref None

(* 创建数据库目录 *)
let create_database db_name =
  if Sys.file_exists db_name then
    Printf.printf "Database %s already exists.\n" db_name
  else
    Unix.mkdir db_name 0o755

(* 切换数据库 *)
let use_database db_name =
  if Sys.file_exists db_name && Sys.is_directory db_name then
    current_db := Some db_name
  else
    Printf.printf "Database %s does not exist.\n" db_name

(* 创建表（CSV文件） *)
let create_table table_name columns =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      Printf.printf "Table %s already exists.\n" table_name
    else
      let csv = Csv.to_channel (open_out table_path) in
      let col_names, col_types = List.split columns in
      Csv.output_record csv col_names;
      Csv.output_record csv (List.map(fun t -> match t with
        | IntType -> "INT"
        | StringType -> "STRING"
        | FloatType -> "FLOAT"
        | BoolType -> "BOOL") col_types);
      Csv.close_out csv
  | None -> Printf.printf "No database selected.\n"

(* 显示当前数据库中的表 *)
let show_tables () =
  match !current_db with
  | Some db_name -> let files = Sys.readdir db_name in Array.iter (fun f -> if Filename.check_suffix f ".csv" then Printf.printf "%s\n" (Filename.chop_suffix f ".csv")) files
  | None -> Printf.printf "No database selected.\n"

(* 显示所有数据库 *)
let show_databases () =
  match Sys.readdir "." with
  | files -> Array.iter (fun f -> if Sys.is_directory f then Printf.printf "%s\n" f) files
  | exception Sys_error msg -> Printf.printf "Error: %s\n" msg

(* 将value转换为字符串 *)
let value_to_string = function
  | IntValue v -> string_of_int v
  | StringValue v -> v
  | FloatValue v -> string_of_float v
  | BoolValue v -> string_of_bool v

(* 条件表达式求值 *)
let rec eval_cond cond row headers = match cond with
  | LessThan (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) < v
    | i, FloatValue v -> float_of_string (List.nth row i) < v
    | _, _ -> false)
  | GreaterThan (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) > v
    | i, FloatValue v -> float_of_string (List.nth row i) > v
    | _, _ -> false)
  | LessEqual (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) <= v
    | i, FloatValue v -> float_of_string (List.nth row i) <= v
    | _, _ -> false)
  | GreaterEqual (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) >= v
    | i, FloatValue v -> float_of_string (List.nth row i) >= v
    | _, _ -> false)
  | Equal (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) = v
    | i, FloatValue v -> float_of_string (List.nth row i) = v
    | i, StringValue v -> List.nth row i = v
    | i, BoolValue v -> bool_of_string (List.nth row i) = v)
  | NotEqual (col, value) -> (match List.assoc col (List.mapi (fun i h -> (h, i)) headers), value with
    | i, IntValue v -> int_of_string (List.nth row i) <> v
    | i, FloatValue v -> float_of_string (List.nth row i) <> v
    | i, StringValue v -> List.nth row i <> v
    | i, BoolValue v -> bool_of_string (List.nth row i) <> v)
  | And (cond1, cond2) -> (eval_cond cond1 row headers) && (eval_cond cond2 row headers)
  | Or (cond1, cond2) -> (eval_cond cond1 row headers) || (eval_cond cond2 row headers)
  | Not cond -> not (eval_cond cond row headers)

(* 插入数据到表中 *)
let insert_into table_name columns values =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let csv = Csv.to_channel (open_out_gen [Open_append] 0o666 table_path) in
      Csv.output_record csv (List.map value_to_string values);
      Csv.close_out csv
    else Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 选择数据（简化实现） *)
let select columns table_name condition =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let csv = Csv.of_channel (open_in table_path) in
      (* Read header *)
      let headers = Csv.next csv in
      let _ = Csv.next csv in
      let col_indices = List.map (fun col -> List.assoc col (List.mapi (fun i h -> (h, i)) headers)) (match columns with 
        | [] -> headers
        | _ -> columns) in
      (* Filter and print rows *)
      Csv.iter ~f:(fun row ->
        let selected_values = List.map (fun i -> List.nth row i) col_indices in
        let row_match_cond = match condition with
          | None -> true
          | Some cond -> (eval_cond cond row headers) in
        if row_match_cond then Printf.printf "%s\n" (String.concat ", " selected_values)
        else ()) csv;
      Csv.close_in csv
    else Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 更新数据 *)
let update_table table_name column value condition =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let data_origin = Csv.load table_path in
      let headers = List.hd data_origin in
      let types = List.hd (List.tl data_origin) in
      let records = List.tl (List.tl data_origin) in
      let col_index = List.assoc column (List.mapi (fun i h -> (h, i)) headers) in
      let data_updated = List.mapi (fun i row -> 
        let row_match_cond = match condition with
          | None -> true
          | Some cond -> (eval_cond cond row headers) in
        if row_match_cond then List.mapi (fun j v -> if j == col_index then value_to_string value else v) row
        else row) records in
      let csv = Csv.to_channel (open_out table_path) in
      Csv.output_record csv headers;
      Csv.output_record csv types;
      List.iter (fun row -> Csv.output_record csv row) data_updated;
      Csv.close_out csv
    else Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 删除数据 *)
let delete_from table_name condition =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let data_origin = Csv.load table_path in
      let headers = List.hd data_origin in
      let types = List.hd (List.tl data_origin) in
      let records = List.tl (List.tl data_origin) in
      let data_deleted = List.mapi (fun i row -> if (
        match condition with
        | None -> true
        | Some cond -> (eval_cond cond row headers)
      ) then None else Some row) records in
      let csv = Csv.to_channel (open_out table_path) in
      Csv.output_record csv headers;
      Csv.output_record csv types;
      List.iter (fun row -> match row with
        | Some r -> Csv.output_record csv r
        | None -> ()) data_deleted;
      Csv.close_out csv
    else Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 删除数据库目录 *)
let drop_database db_name =
  if Sys.file_exists db_name then
    Sys.command (Printf.sprintf "rm -rf %s" db_name) |> ignore
  else Printf.printf "Database %s does not exist.\n" db_name

(* 删除表（CSV文件） *)
let drop_table table_name =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then Sys.remove table_path
    else Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 退出程序 *)
let exit_program () =
  Printf.printf "Exiting...\n";
  exit 0

(* 评估表达式 *)
let eval_expr = function
  | CreateDatabase name -> create_database name
  | UseDatabase name -> use_database name
  | CreateTable (name, cols) -> create_table name cols
  | ShowDatabases -> show_databases ()
  | ShowTables -> show_tables ()
  | InsertInto (table, cols, vals) -> insert_into table cols vals
  | Select (cols, table, cond) -> select cols table cond
  | Update (table, col, value, cond) -> update_table table col value cond
  | Delete (table, cond) -> delete_from table cond
  | DropTable name -> drop_table name
  | DropDatabase name -> drop_database name
  | Exit -> exit_program ()

(* 主程序循环 *)
let rec main_loop () =
  try
    Printf.printf ">>> ";
    let line = read_line () in
    let lexbuf = Lexing.from_string line in
    let parsed_expr = Parser.main Lexer.token lexbuf in
    eval_expr parsed_expr;
    main_loop ()
  with
  | Lexer.Lexing_error msg -> Printf.printf "Lexer error: %s\n" msg; main_loop ()
  | Parsing.Parse_error -> Printf.printf "Parser error\n"; main_loop ()
  | End_of_file -> ()

(* 程序入口 *)
let () = main_loop ()
