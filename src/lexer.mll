{ open Parser }

let whitespace = [' ' '\t' '\n' '\r']+
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let alphanum = alpha | digit

rule read = parse
  | whitespace { read lexbuf } (* Ignore whitespace *)
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
  | "TABLES" { TABLES }
  | "TABLE" { TABLE }
  | "VALUES" { VALUES }
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
  | alpha (alphanum | '_')* as id { IDENTIFIER id }
  | eof     { EOF }
  | _ as c  { raise (Lexing_error (Printf.sprintf "Unexpected character: %c" c)) }
