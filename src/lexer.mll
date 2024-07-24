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
  | digit+ as num { INT (int_of_string num) }
  | digit+ "." digit* as num { FLOAT (float_of_string num) }
  | (alpha | '_') (alphanum | '_')* as id { 
    match String.lowercase_ascii id with
    | "create" -> CREATE 
    | "use"   -> USE 
    | "show"  -> SHOW 
    | "insert" -> INSERT 
    | "into"  -> INTO 
    | "select" -> SELECT 
    | "update" -> UPDATE 
    | "set"   -> SET 
    | "drop"  -> DROP 
    | "delete" -> DELETE 
    | "from"   -> FROM 
    | "where"  -> WHERE 
    | "exit"   -> EXIT 
    | "database" -> DATABASE 
    | "databases" -> DATABASES 
    | "tables" -> TABLES 
    | "table" -> TABLE 
    | "values" -> VALUES 
    | "int" -> INT_TYPE 
    | "string" -> STRING_TYPE 
    | "float" -> FLOAT_TYPE 
    | "bool" -> BOOL_TYPE 
    | "and" -> AND 
    | "or" -> OR 
    | "not" -> NOT 
    | "true" -> BOOL true 
    | "false" -> BOOL false 
    | _ -> IDENTIFIER id
  }
  | '"'[^'"']*'"' as str { STRING (String.sub str 1 (String.length str - 2)) }
  | "*"     { STAR }
  | ","     { COMMA }
  | ";"     { SEMICOLON }
  | "."     { DOT }
  | "="     { EQUALS }
  | "<"     { LESS }
  | ">"     { GREATER }
  | "<="    { LESS_EQUAL }
  | ">="    { GREATER_EQUAL }
  | "<>"    { NOT_EQUAL }
  | "+"     { PLUS }
  | "-"     { MINUS }
  | "/"     { DIVIDE }
  | "%"     { MOD }
  | "("     { LPAREN }
  | ")"     { RPAREN }
  | eof     { EOF }
  | _ as c  { raise (Lexing_error (Printf.sprintf "Unexpected character: %c" c)) }
