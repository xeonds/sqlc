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
  | InsertInto of string * string list * value list list
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
  | And of condition * condition
  | Or of condition * condition
  | Not of condition