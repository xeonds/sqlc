(* ast.ml *)
type expr =
  | CreateDatabase of string
  | UseDatabase of string
  | CreateTable of string * string list
  | ShowTables
  | InsertInto of string * string list * string list
  | Select of string list * string * expr option
  | Update of string * string * int * string
  | Delete of string * string
  | DropTable of string
  | DropDatabase of string
  | Exit

type condition =
  | LessThan of string * int
  | GreaterThan of string * int
  | LessEqual of string * int
  | GreaterEqual of string * int
  | NotEqual of string * int
  | Equal of string * int
