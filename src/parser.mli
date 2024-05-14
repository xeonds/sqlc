type token =
  | IDENTIFIER of (
# 7 "parser.mly"
        string
# 6 "parser.mli"
)
  | INT of (
# 8 "parser.mly"
        int
# 11 "parser.mli"
)
  | CREATE
  | USE
  | SHOW
  | INSERT
  | INTO
  | SELECT
  | UPDATE
  | SET
  | DROP
  | DELETE
  | FROM
  | WHERE
  | EXIT
  | DATABASE
  | TABLES
  | TABLE
  | VALUES
  | LPAREN
  | RPAREN
  | COMMA
  | SEMICOLON
  | STAR
  | EQUALS
  | LESS
  | GREATER
  | LESS_EQUAL
  | GREATER_EQUAL
  | NOT_EQUAL
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | EOF

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
