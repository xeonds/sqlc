type column = string * string (* column name and type *)
and table = string * column list (* table name and its columns *)
and expr = 
    | CreateTable of table
    | InsertInto of string * string list * string list (* table name, columns, values *)
    | SelectFrom of string list * string * string option (* columns, table name, optional condition *)
;;