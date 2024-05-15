type data_type = 
  | IntType 
  | StringType 
  | FloatType 
  | BoolType

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
  | Update of string * string * value * string
  | Delete of string * string
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

let rec show_expr = function
  | CreateDatabase name -> "CreateDatabase " ^ name
  | UseDatabase name -> "UseDatabase " ^ name
  | CreateTable (name, columns) -> 
      "CreateTable " ^ name ^ " (" ^ (String.concat ", " (List.map show_column columns)) ^ ")"
  | ShowTables -> "ShowTables"
  | ShowDatabases -> "ShowDatabases"
  | InsertInto (name, columns, values) ->
      "InsertInto " ^ name ^ " (" ^ (String.concat ", " columns) ^ ") VALUES (" ^ (String.concat ", " (List.map show_value values)) ^ ")"
  | Select (columns, table, opt_where) ->
      "Select " ^ (String.concat ", " columns) ^ " FROM " ^ table ^ (match opt_where with Some(cond) -> " WHERE " ^ show_condition cond | None -> "")
  | Update (table, column, value, cond) ->
      "Update " ^ table ^ " SET " ^ column ^ " = " ^ show_value value ^ " WHERE " ^ cond
  | Delete (table, cond) ->
      "Delete FROM " ^ table ^ " WHERE " ^ cond
  | DropTable name -> "DropTable " ^ name
  | DropDatabase name -> "DropDatabase " ^ name
  | Exit -> "Exit"

and show_column (name, data_type) =
  name ^ " " ^ (match data_type with
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
