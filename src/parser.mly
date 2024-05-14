/* parser.mly */
/* Simple SQL statement parser */

%{ 
  open Ast
%}

/* Tokens */
%token <string> IDENTIFIER
%token <int> INT
%token CREATE USE SHOW INSERT INTO SELECT UPDATE SET DROP DELETE FROM WHERE EXIT
%token DATABASE TABLES TABLE VALUES
%token LPAREN RPAREN COMMA SEMICOLON
%token STAR EQUALS LESS GREATER LESS_EQUAL GREATER_EQUAL NOT_EQUAL PLUS MINUS TIMES DIVIDE
%token EOF

%start main
%type <Ast.expr> main

%% /* Grammar rules and actions */

main:
  | statement { $1 }
  | statement SEMICOLON { $1 }

statement:
  | SELECT columns FROM IDENTIFIER opt_where SEMICOLON { Select($2, $4, $5) }
  | CREATE DATABASE IDENTIFIER SEMICOLON { CreateDatabase $3 }
  | USE DATABASE IDENTIFIER SEMICOLON { UseDatabase $3 }
  | CREATE TABLE IDENTIFIER LPAREN columns RPAREN SEMICOLON { CreateTable($3, $5) }
  | SHOW TABLES SEMICOLON { ShowTables }
  | INSERT INTO IDENTIFIER LPAREN columns RPAREN VALUES LPAREN values RPAREN SEMICOLON { InsertInto($3, $5, $9) }
  | UPDATE IDENTIFIER SET IDENTIFIER EQUALS INT WHERE IDENTIFIER SEMICOLON { Update($2, $4, $6, $8) }
  | DELETE FROM IDENTIFIER WHERE IDENTIFIER SEMICOLON { Delete($3, $5) }
  | DROP TABLE IDENTIFIER SEMICOLON { DropTable $3 }
  | DROP DATABASE IDENTIFIER SEMICOLON { DropDatabase $3 }
  | EXIT SEMICOLON { Exit }

columns:
  | IDENTIFIER COMMA columns { [$1] @ $3 }
  | IDENTIFIER { [$1] }

values:
  | INT COMMA values { string_of_int $1 :: $3 }
  | INT { [string_of_int $1] }

opt_where:
  | WHERE condition { Some $2 }
  | { None }

condition:
  | IDENTIFIER LESS INT { LessThan($1, $3) }
  | IDENTIFIER GREATER INT { GreaterThan($1, $3) }
  | IDENTIFIER LESS_EQUAL INT { LessEqual($1, $3) }
  | IDENTIFIER GREATER_EQUAL INT { GreaterEqual($1, $3) }
  | IDENTIFIER NOT_EQUAL INT { NotEqual($1, $3) }
  | IDENTIFIER EQUALS INT { Equal($1, $3) }