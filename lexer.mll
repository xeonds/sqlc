{
  open Parser
}

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']
let identifier = letter (letter|digit|'_')*

rule token = parse
  | [' ' '\t' '\n']      { token lexbuf } (* Ignore whitespace and newline *)
  | "CREATE"             { CREATE }
  | "TABLE"              { TABLE }
  | "INSERT"             { INSERT }
  | "INTO"               { INTO }
  | "SELECT"             { SELECT }
  | "FROM"               { FROM }
  | "WHERE"              { WHERE }
  | '('                   { LPAREN }
  | ')'                   { RPAREN }
  | '='                   { EQUAL }
  | '<'                   { LESS }
  | "<="                  { LESS_EQUAL }
  | "<>"                  { NOT_EQUAL }
  | '>'                   { GREATER }
  | ">="                  { GREATER_EQUAL }
  | ','                   { COMMA }
  | ';'                   { SEMICOLON }
  | identifier as id      { IDENTIFIER(id) }
  | digit+ as num         { INT(int_of_string num) }
  | eof                   { EOF }
  | _                     { failwith ("Unexpected character: " ^ Lexing.lexeme lexbuf) }
and read_comment buf = parse
  | "*/"                  { Buffer.contents buf }
  | _                     { Buffer.add_string buf (Lexing.lexeme lexbuf); read_comment buf lexbuf }
and read_line_comment = parse
  | '\n'                  { () }
  | _                     { read_line_comment lexbuf }