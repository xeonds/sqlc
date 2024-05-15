(* ast.ml *)

(* 表达式类型 *)
type expr =
  | CreateDatabase of string
  | UseDatabase of string
  | CreateTable of string * string list
  | ShowDatabases
  | ShowTables
  | InsertInto of string * string list * string list
  | Select of string list * string * condition option
  | Update of string * string * int * string
  | Delete of string * string
  | DropTable of string
  | DropDatabase of string
  | Exit

(* 条件类型 *)
and condition =
  | LessThan of string * int
  | GreaterThan of string * int
  | LessEqual of string * int
  | GreaterEqual of string * int
  | NotEqual of string * int
  | Equal of string * int

(* 用于调试的辅助函数，用于将表达式转换为字符串 *)
let rec show_expr = function
  | CreateDatabase name -> Printf.sprintf "CreateDatabase(%s)" name
  | UseDatabase name -> Printf.sprintf "UseDatabase(%s)" name
  | CreateTable (name, cols) -> Printf.sprintf "CreateTable(%s, [%s])" name (String.concat "; " cols)
  | ShowTables -> "ShowTables"
  | ShowDatabases -> "ShowDatabases"
  | InsertInto (table, cols, vals) -> Printf.sprintf "InsertInto(%s, [%s], [%s])" table (String.concat "; " cols) (String.concat "; " vals)
  | Select (cols, table, cond) -> Printf.sprintf "Select([%s], %s, %s)" (String.concat "; " cols) table (show_opt_cond cond)
  | Update (table, col, value, cond) -> Printf.sprintf "Update(%s, %s, %d, %s)" table col value cond
  | Delete (table, cond) -> Printf.sprintf "Delete(%s, %s)" table cond
  | DropTable name -> Printf.sprintf "DropTable(%s)" name
  | DropDatabase name -> Printf.sprintf "DropDatabase(%s)" name
  | Exit -> "Exit"

and show_opt_cond = function
  | Some cond -> show_condition cond
  | None -> "None"

and show_condition = function
  | LessThan (col, value) -> Printf.sprintf "LessThan(%s, %d)" col value
  | GreaterThan (col, value) -> Printf.sprintf "GreaterThan(%s, %d)" col value
  | LessEqual (col, value) -> Printf.sprintf "LessEqual(%s, %d)" col value
  | GreaterEqual (col, value) -> Printf.sprintf "GreaterEqual(%s, %d)" col value
  | NotEqual (col, value) -> Printf.sprintf "NotEqual(%s, %d)" col value
  | Equal (col, value) -> Printf.sprintf "Equal(%s, %d)" col value
