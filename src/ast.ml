type data_type = IntType | StringType | FloatType | BoolType

type value =
  | IntValue of int
  | StringValue of string
  | FloatValue of float
  | BoolValue of bool

type expr =
  | CreateDatabase of string
  | UseDatabase of string
  | CreateTable of string * (string * data_type) list
  | ShowTables
  | ShowDatabases
  | InsertInto of string * string list * value list
  | Select of string list * string * (condition option)
  | Update of string * string * value * (condition option)
  | Delete of string * (condition option)
  | DropTable of string
  | DropDatabase of string
  | Exit
and condition =
  | LessThan of string * value
  | GreaterThan of string * value
  | LessEqual of string * value
  | GreaterEqual of string * value
  | NotEqual of string * value
  | Equal of string * value

(* Show parsed expressions *)
let rec show_expr = function
  | CreateDatabase name -> "CreateDatabase " ^ name
  | UseDatabase name -> "UseDatabase " ^ name
  | CreateTable (name, columns) -> "CreateTable " ^ name ^ " (" ^ (String.concat ", " (List.map show_column columns)) ^ ")"
  | ShowTables -> "ShowTables"
  | ShowDatabases -> "ShowDatabases"
  | InsertInto (name, columns, values) -> "InsertInto " ^ name ^ " (" ^ (String.concat ", " columns) ^ ") VALUES (" ^ (String.concat ", " (List.map show_value values)) ^ ")"
  | Select (columns, table, opt_where) -> "Select " ^ (String.concat ", " columns) ^ " FROM " ^ table ^ (match opt_where with Some(cond) -> " WHERE " ^ show_condition cond | None -> "")
  | Update (table, column, value, opt_where) -> "Update " ^ table ^ " SET " ^ column ^ " = " ^ show_value value ^ (match opt_where with Some(cond) -> " WHERE " ^ show_condition cond | None -> "")
  | Delete (table, opt_where) -> "Delete FROM " ^ table ^ (match opt_where with Some(cond) -> " WHERE " ^ show_condition cond | None -> "")
  | DropTable name -> "DropTable " ^ name
  | DropDatabase name -> "DropDatabase " ^ name
  | Exit -> "Exit"
and show_column (name, data_type) = name ^ " " ^ (match data_type with
  | IntType -> "INT"
  | StringType -> "STRING"
  | FloatType -> "FLOAT"
  | BoolType -> "BOOL")
and show_value = function
  | IntValue v -> string_of_int v
  | StringValue v -> "\"" ^ v ^ "\""
  | FloatValue v -> string_of_float v
  | BoolValue v -> string_of_bool v
and show_condition = function
  | LessThan (col, value) -> col ^ " < " ^ show_value value
  | GreaterThan (col, value) -> col ^ " > " ^ show_value value
  | LessEqual (col, value) -> col ^ " <= " ^ show_value value
  | GreaterEqual (col, value) -> col ^ " >= " ^ show_value value
  | NotEqual (col, value) -> col ^ " != " ^ show_value value
  | Equal (col, value) -> col ^ " = " ^ show_value value

(* Generate OCaml code *)
let rec generate_code = function
  | CreateDatabase name -> Printf.sprintf "create_database \"%s\"" name
  | UseDatabase name -> Printf.sprintf "use_database \"%s\"" name
  | CreateTable (name, columns) ->
    let cols = columns |> List.map (fun (col, typ) -> Printf.sprintf "(\"%s\", %s)" col (string_of_data_type typ)) |> String.concat "; " in
    Printf.sprintf "create_table \"%s\" [%s]" name cols
  | ShowTables -> "show_tables ()"
  | ShowDatabases -> "show_databases ()"
  | InsertInto (table, cols, vals) ->
    let cols_str = String.concat "; " (List.map (Printf.sprintf "\"%s\"") cols) in
    let vals_str = String.concat "; " (List.map string_of_value vals) in
    Printf.sprintf "insert_into \"%s\" [%s] [%s]" table cols_str vals_str
  | Select (cols, table, cond) ->
    let cols_str = String.concat "; " (List.map (Printf.sprintf "\"%s\"") cols) in
    let cond_str = match cond with
      | Some c -> generate_condition_code c
      | None -> "None" in
    Printf.sprintf "select [%s] \"%s\" %s" cols_str table cond_str
  | Update (table, col, value, cond) ->
    let value_str = string_of_value value in
    let cond_str = match cond with
      | Some c -> generate_condition_code c 
      | None -> "None" in
    Printf.sprintf "update \"%s\" \"%s\" %s %s" table col value_str cond_str
  | Delete (table, cond) ->
    let cond_str = match cond with 
      | Some c -> generate_condition_code c
      | None -> "None" in
    Printf.sprintf "delete \"%s\" %s" table cond_str
  | DropTable name -> Printf.sprintf "drop_table \"%s\"" name
  | DropDatabase name -> Printf.sprintf "drop_database \"%s\"" name
  | Exit -> "exit_program ()"
and string_of_value = function
  | IntValue i -> string_of_int i
  | StringValue s -> Printf.sprintf "\"%s\"" s
  | FloatValue f -> string_of_float f
  | BoolValue b -> string_of_bool b
and string_of_data_type = function
  | IntType -> "IntType"
  | StringType -> "StringType"
  | FloatType -> "FloatType"
  | BoolType -> "BoolType"
and generate_condition_code = function
  | LessThan (col, value) -> Printf.sprintf "LessThan(\"%s\", %s)" col (string_of_value value)
  | GreaterThan (col, value) -> Printf.sprintf "GreaterThan(\"%s\", %s)" col (string_of_value value)
  | LessEqual (col, value) -> Printf.sprintf "LessEqual(\"%s\", %s)" col (string_of_value value)
  | GreaterEqual (col, value) -> Printf.sprintf "GreaterEqual(\"%s\", %s)" col (string_of_value value)
  | NotEqual (col, value) -> Printf.sprintf "NotEqual(\"%s\", %s)" col (string_of_value value)
  | Equal (col, value) -> Printf.sprintf "Equal(\"%s\", %s)" col (string_of_value value)
