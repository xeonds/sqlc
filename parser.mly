%{ open Ast %}

%token <string> IDENTIFIER
%token <int> INT
%token CREATE TABLE INSERT INTO SELECT FROM WHERE
%token LPAREN RPAREN COMMA SEMICOLON VALUES
%token EOF

%start main
%type <Ast.expr> main

%%

main:
  | CREATE TABLE IDENTIFIER LPAREN columns RPAREN SEMICOLON { CreateTable($3, $5) }
  | INSERT INTO IDENTIFIER LPAREN columns RPAREN VALUES LPAREN values RPAREN SEMICOLON { InsertInto($3, $5, $9) }
  | SELECT columns FROM IDENTIFIER opt_where SEMICOLON { SelectFrom($2, $4, $5) }

columns:
  | IDENTIFIER COMMA columns { [$1] @ $3 }
  | IDENTIFIER { [$1] }

values:
  | INT COMMA values { string_of_int $1 :: $3 }
  | INT { [string_of_int $1] }

opt_where:
  | WHERE IDENTIFIER { Some $2 }
  | { None }
