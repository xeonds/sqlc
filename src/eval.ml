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
  if Sys.file_exists db_name && Sys.is_directory db_name then (
    current_db := Some db_name;
    Printf.printf "Switched to database %s.\n" db_name)
  else
    Printf.printf "Database %s does not exist.\n" db_name

(* 类型名转类型 *)
let type_of_name = function
  | "INT" -> IntType
  | "STRING" -> StringType
  | "FLOAT" -> FloatType
  | "BOOL" -> BoolType
  | _ -> raise (Invalid_argument "Invalid type")

(* 类型转类型名 *)
let name_of_type = function
  | IntType -> "INT"
  | StringType -> "STRING"
  | FloatType -> "FLOAT"
  | BoolType -> "BOOL"

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
let string_of_value = function
  | IntValue v -> string_of_int v
  | StringValue v -> v
  | FloatValue v -> string_of_float v
  | BoolValue v -> string_of_bool v

let value_of_string = function
  | "true" -> BoolValue true
  | "false" -> BoolValue false
  | s -> match int_of_string_opt s with
    | Some i -> IntValue i
    | None -> match float_of_string_opt s with
      | Some f -> FloatValue f
      | None -> StringValue s

let type_of_string string = match value_of_string string with
  | IntValue _ -> IntType
  | StringValue _ -> StringType
  | FloatValue _ -> FloatType
  | BoolValue _ -> BoolType

let type_of_data data = match data with
  | IntValue _ -> IntType
  | StringValue _ -> StringType
  | FloatValue _ -> FloatType
  | BoolValue _ -> BoolType

(* 条件表达式 *)

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
      let csvIn = Csv.of_channel (open_in table_path) in
      let csvOut = Csv.to_channel (open_out_gen [Open_append] 0o666 table_path) in
      let headers = Csv.next csvIn in
      let types = List.map2 (fun h t -> (h, type_of_name t)) headers (Csv.next csvIn) in
      List.iteri (fun row value -> Csv.output_record csvOut (List.map (fun header -> 
        match List.assoc_opt header (List.mapi (fun i h -> (h, i)) columns) with
        | Some index -> (
          let _,t = List.nth types index in
          let tt = type_of_data (List.nth value index) in 
          if t != tt then Printf.printf "Type mismatch for row %d, column %s\n; Replaced with default value" row header;
          if t == tt then string_of_value(List.nth value index)
            else string_of_value (match t with
              | IntType -> IntValue 0
              | FloatType -> FloatValue 0.0
              | StringType -> StringValue ""
              | BoolType -> BoolValue false))
        | None -> string_of_value (match List.assoc header types with
          | IntType -> IntValue 0
          | FloatType -> FloatValue 0.0
          | StringType -> StringValue ""
          | BoolType -> BoolValue false)) headers)) values;
      Csv.close_in csvIn;
      Csv.close_out csvOut;
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
      let data_updated = List.mapi (fun _ row -> 
        let row_match_cond = match condition with
          | None -> true
          | Some cond -> (eval_cond cond row headers) in
        if row_match_cond then List.mapi (fun j v -> if j == col_index then string_of_value value else v) row
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
      let data_deleted = List.mapi (fun _ row -> if (
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
