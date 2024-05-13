type token =
  | IDENTIFIER of (
# 3 "parser.mly"
        string
# 6 "parser.mli"
)
  | INT of (
# 4 "parser.mly"
        int
# 11 "parser.mli"
)
  | CREATE
  | TABLE
  | INSERT
  | INTO
  | SELECT
  | FROM
  | WHERE
  | LPAREN
  | RPAREN
  | COMMA
  | SEMICOLON
  | VALUES
  | EOF

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.expr
