{
open Parser

exception Lexing_error of string
}

let whitespace = [' ' '\t' '\n' '\r']+
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let alphanum = alpha | digit

rule token = parse
  | whitespace { token lexbuf } (* Ignore whitespace *)
  | "CREATE" { CREATE }
  | "USE"   { USE }
  | "SHOW"  { SHOW }
  | "INSERT" { INSERT }
  | "INTO"  { INTO }
  | "SELECT" { SELECT }
  | "UPDATE" { UPDATE }
  | "SET"   { SET }
  | "DROP"  { DROP }
  | "DELETE" { DELETE }
  | "FROM"   { FROM }
  | "WHERE"  { WHERE }
  | "EXIT"   { EXIT }
  | "DATABASE" { DATABASE }
  | "DATABASES" { DATABASES }
  | "TABLES" { TABLES }
  | "TABLE" { TABLE }
  | "VALUES" { VALUES }
  | "INT" { INT_TYPE }
  | "STRING" { STRING_TYPE }
  | "FLOAT" { FLOAT_TYPE }
  | "BOOL" { BOOL_TYPE }
  | "*"      { STAR }
  | ","      { COMMA }
  | "="      { EQUALS }
  | "<"      { LESS }
  | ">"      { GREATER }
  | "<="     { LESS_EQUAL }
  | ">="     { GREATER_EQUAL }
  | "!="     { NOT_EQUAL }
  | "+"      { PLUS }
  | "-"      { MINUS }
  | "*"      { TIMES }
  | "/"      { DIVIDE }
  | ";"      { SEMICOLON }
  | "("      { LPAREN }
  | ")"      { RPAREN }
  | digit+ as num { INT (int_of_string num) }
  | digit+ "." digit* as num { FLOAT (float_of_string num) }
  | "\"" [^ '\"']* "\"" as str { STRING (String.sub str 1 (String.length str - 2)) }
  | "true" { BOOL true }
  | "false" { BOOL false }
  | alpha (alphanum | '_')* as id { IDENTIFIER id }
  | eof     { EOF }
  | _ as c  { raise (Lexing_error (Printf.sprintf "Unexpected character: %c" c)) }
