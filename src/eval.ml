open Csv
open Ast

(* 当前使用的数据库路径 *)
let current_db = ref None

(* 创建数据库目录 *)
let create_database db_name =
  let dir_name = db_name in
  if Sys.file_exists dir_name then
    Printf.printf "Database %s already exists.\n" db_name
  else
    Unix.mkdir dir_name 0o755

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
      let oc = open_out table_path in
      let csv = Csv.to_channel oc in
      let col_names = List.map (fun (name, _) -> name) columns in
      Csv.output_record csv col_names;
      Csv.close_out csv
  | None -> Printf.printf "No database selected.\n"

(* 显示当前数据库中的表 *)
let show_tables () =
  match !current_db with
  | Some db_name ->
    let files = Sys.readdir db_name in
    Array.iter (fun f -> if Filename.check_suffix f ".csv" then Printf.printf "%s\n" (Filename.chop_suffix f ".csv")) files
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

(* 插入数据到表中 *)
let insert_into table_name columns values =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let oc = open_out_gen [Open_append] 0o666 table_path in
      let csv = Csv.to_channel oc in
      let values_as_strings = List.map value_to_string values in
      Csv.output_record csv values_as_strings;
      Csv.close_out csv
    else
      Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 选择数据（简化实现） *)
let select columns table_name condition =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      let ic = open_in table_path in
      let csv = Csv.of_channel ic in
      (* Read header *)
      let headers = Csv.next csv in
      let col_indices = List.map (fun col -> List.assoc col (List.mapi (fun i h -> (h, i)) headers)) columns in
      (* Filter and print rows *)
      Csv.iter ~f:(fun row ->
        let selected_values = List.map (fun i -> List.nth row i) col_indices in
        Printf.printf "%s\n" (String.concat ", " selected_values)
      ) csv;
      Csv.close_in csv
    else
      Printf.printf "Table %s does not exist.\n" table_name
  | None -> Printf.printf "No database selected.\n"

(* 删除数据库目录 *)
let drop_database db_name =
  let dir_name = db_name in
  if Sys.file_exists dir_name then
    Sys.command (Printf.sprintf "rm -rf %s" dir_name) |> ignore
  else
    Printf.printf "Database %s does not exist.\n" db_name

(* 删除表（CSV文件） *)
let drop_table table_name =
  match !current_db with
  | Some db_name ->
    let table_path = Filename.concat db_name (table_name ^ ".csv") in
    if Sys.file_exists table_path then
      Sys.remove table_path
    else
      Printf.printf "Table %s does not exist.\n" table_name
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
  | Update (table, col, value, cond) -> (* 实现Update逻辑 *) ()
  | Delete (table, cond) -> (* 实现Delete逻辑 *) ()
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
let () =
  main_loop ()
