(* lexer.mll *)
{
  open Parser
}

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']
let id = letter (letter | digit | '_')*

rule token = parse
  | [' ' '\t' '\n']      { token lexbuf }
  | "CREATE"             { CREATE }
  | "DATABASE"           { DATABASE }
  | "USE"                { USE }
  | "TABLE"              { TABLE }
  | "SHOW"               { SHOW }
  | "TABLES"             { TABLES }
  | "INSERT"             { INSERT }
  | "INTO"               { INTO }
  | "VALUES"             { VALUES }
  | "SELECT"             { SELECT }
  | "UPDATE"             { UPDATE }
  | "SET"                { SET }
  | "DROP"               { DROP }
  | "EXIT"               { EXIT }
  | '('                  { LPAREN }
  | ')'                  { RPAREN }
  | ','                  { COMMA }
  | '='                  { EQ }
  | id as value          { ID(value) }
  | digit+ as value      { INT(int_of_string value) }
