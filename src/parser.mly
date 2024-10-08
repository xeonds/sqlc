/* parser.mly */
/* Simple SQL statement parser */

%{
  open Ast
%}

/* Tokens */
%token <string> IDENTIFIER
%token <int> INT
%token <string> STRING
%token <float> FLOAT
%token <bool> BOOL
%token CREATE USE SHOW INSERT INTO SELECT UPDATE SET DROP DELETE FROM WHERE EXIT
%token DATABASES DATABASE TABLES TABLE VALUES JOIN ON AS
%token BEGIN TRANSACTION COMMIT ROLLBACK LOCK UNLOCK
%token VIEW INDEX LOG
%token LPAREN RPAREN COMMA SEMICOLON
%token STAR DOT MOD EQUALS LESS GREATER LESS_EQUAL GREATER_EQUAL NOT_EQUAL PLUS MINUS TIMES DIVIDE
%token EOF
%token INT_TYPE STRING_TYPE FLOAT_TYPE BOOL_TYPE
%token AND OR NOT ORDER BY LIMIT

%start main
%type <Ast.expr> main

%% /* Grammar rules and actions */

main:
  | statement SEMICOLON { $1 }
  | EOF { Exit }

statement:
  | SELECT columns FROM IDENTIFIER opt_where { Select($2, $4, $5) }
  | CREATE DATABASE IDENTIFIER { CreateDatabase $3 }
  | USE DATABASE IDENTIFIER { UseDatabase $3 }
  | CREATE TABLE IDENTIFIER LPAREN table_columns RPAREN { CreateTable($3, $5) }
  | SHOW TABLES { ShowTables }
  | SHOW DATABASES { ShowDatabases }
  | INSERT INTO IDENTIFIER LPAREN columns RPAREN VALUES values { InsertInto($3, $5, $8) }
  | UPDATE IDENTIFIER SET IDENTIFIER EQUALS value opt_where { Update($2, $4, $6, $7) }
  | DELETE FROM IDENTIFIER opt_where { Delete($3, $4) }
  | DROP TABLE IDENTIFIER { DropTable $3 }
  | DROP DATABASE IDENTIFIER { DropDatabase $3 }
  | EXIT { Exit }

table_columns:
  | column_def COMMA table_columns { $1 :: $3 }
  | column_def { [$1] }

column_def:
  | IDENTIFIER data_type { ($1, $2) }

columns:
  | STAR { [] }
  | IDENTIFIER COMMA columns { $1 :: $3 }
  | IDENTIFIER { [$1] }

values:
  | LPAREN values_def RPAREN values { $2 :: $4 }
  | LPAREN values_def RPAREN { [$2] }

values_def:
  | value COMMA values_def { $1 :: $3 }
  | value { [$1] }

value:
  | INT { IntValue $1 }
  | STRING { StringValue $1 }
  | FLOAT { FloatValue $1 }
  | BOOL { BoolValue $1 }

data_type:
  | INT_TYPE { IntType }
  | STRING_TYPE { StringType }
  | FLOAT_TYPE { FloatType }
  | BOOL_TYPE { BoolType }

opt_where:
  | WHERE condition { Some $2 }
  | { None }

condition:
  | LPAREN condition RPAREN { $2 }
  | NOT condition { Not $2 }
  | condition AND condition { And($1, $3) }
  | condition OR condition { Or($1, $3) }
  | IDENTIFIER LESS value { LessThan($1, $3) }
  | IDENTIFIER GREATER value { GreaterThan($1, $3) }
  | IDENTIFIER LESS_EQUAL value { LessEqual($1, $3) }
  | IDENTIFIER GREATER_EQUAL value { GreaterEqual($1, $3) }
  | IDENTIFIER NOT_EQUAL value { NotEqual($1, $3) }
  | IDENTIFIER EQUALS value { Equal($1, $3) }
