(* Grammar for SQL language *)
type column_type = Int | Char of int

type statement =
  | CreateDatabase of string
  | UseDatabase of string
  | CreateTable of string * (string * column_type) list
  | ShowTables
  | Insert of string * string list
  | Select of string list
  | Update of string * (string * string) list
  | DropTable of string
  | DropDatabase of string
  | Exit

(* Define the AST data structure *)
type ast = statement

(* Parser using Angstrom *)
open Angstrom

let ws = skip_while (function ' ' | '\t' | '\n' | '\r' -> true | _ -> false)
let lexeme p = p <* ws

let keyword k = lexeme (string k)

let identifier =
  lexeme (take_while1 (function 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' -> true | _ -> false))

let create_database_parser = keyword "CREATE DATABASE" *> lift (fun db_name -> CreateDatabase db_name) identifier
let use_database_parser = keyword "USE DATABASE" *> lift (fun db_name -> UseDatabase db_name) identifier
let create_table_parser =
  let column_type_parser =
    choice [
      keyword "INT" *> return Int;
      keyword "CHAR" *> lift (fun n -> Char n) (keyword "(" *> take_while1 (function '0'..'9' -> true | _ -> false) <* keyword ")")
    ]
  in
  let column_parser = lift2 (fun name col_type -> (name, col_type)) identifier column_type_parser in
  keyword "CREATE TABLE" *> lift2 (fun table_name columns -> CreateTable (table_name, columns)) identifier (keyword "(" *> sep_by (keyword ",") column_parser <* keyword ")")
let show_tables_parser = keyword "SHOW TABLES" *> return ShowTables
let insert_parser = keyword "INSERT INTO" *> lift2 (fun table_name values -> Insert (table_name, values)) identifier (keyword "VALUES" *> keyword "(" *> sep_by (keyword ",") identifier <* keyword ")")
(* Define parsers for other statements similarly *)

let statement_parser =
  choice [
    create_database_parser;
    use_database_parser;
    (* Add parsers for other statements *)
  ]