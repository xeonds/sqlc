/* parser.mly */
/* Simple SQL statement parser */
/* Tokens */
%token <string> IDENTIFIER FILE
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

%start program
%type <Db_engine.Types.statement> program

%% /* Grammar rules and actions */

program:
  | statement SEMICOLON { $1 }
  | EOF { Exit }

statement:
  | SELECT columns FROM FILE opt_join opt_where { Select($2, $4, $5, $6) }
  | CREATE TABLE FILE LPAREN table_columns RPAREN { CreateTable($3, $5) }
  | SHOW TABLES { ShowTables }
  | INSERT INTO FILE LPAREN columns RPAREN VALUES values { InsertInto($3, $5, $8) }
  | UPDATE FILE SET IDENTIFIER EQUALS value opt_where { Update($2, $4, $6, $7) }
  | DELETE FROM FILE opt_where { DeleteFrom($3, $4) }
  | DROP TABLE FILE { DropTable $3 }
  | EXIT { Exit }

opt_join:
  | JOIN FILE ON expr { Some ($2, $4) }
  | { None }

opt_where:
  | WHERE expr { Some $2 }
  | { None }

table_columns:
  | column_def COMMA table_columns { $1 :: $3 }
  | column_def { [$1] }

column_def:
  | IDENTIFIER dtype { ($1, $2) }

columns:
  | STAR { ["*"] }
  | IDENTIFIER COMMA columns { $1 :: $3 }
  | IDENTIFIER { [$1] }

dtype:
  | INT_TYPE { Int }
  | STRING_TYPE { String }
  | FLOAT_TYPE { Float }
  | BOOL_TYPE { Bool}

values:
  | LPAREN values_def RPAREN values { $2 :: $4 }
  | LPAREN values_def RPAREN { [$2] }

values_def:
  | value COMMA values_def { $1 :: $3 }
  | value { [$1] }

value:
  | INT { VInt $1 }
  | STRING { VString $1 }
  | FLOAT { VFloat $1 }
  | BOOL { VBool $1 }

expr:
  | value { Literal $1 }
  | IDENTIFIER { Column $1 }
  | expr PLUS expr { BinOp($1, "+", $3) }
  | expr MINUS expr { BinOp($1, "-", $3) }
  | expr TIMES expr { BinOp($1, "*", $3) }
  | expr DIVIDE expr { BinOp($1, "/", $3) }
  | expr MOD expr { BinOp($1, "%", $3) }
  | expr EQUALS expr { BinOp($1, "=", $3) }
  | expr LESS expr { BinOp($1, "<", $3) }
  | expr GREATER expr { BinOp($1, ">", $3) }
  | expr LESS_EQUAL expr { BinOp($1, "<=", $3) }
  | expr GREATER_EQUAL expr { BinOp($1, ">=", $3) }
  | expr NOT_EQUAL expr { BinOp($1, "<>", $3) }
  | expr AND expr { BinOp($1, "AND", $3) }
  | expr OR expr { BinOp($1, "OR", $3) }
  | LPAREN expr RPAREN { $2 }
  | NOT expr { Call("NOT", [$2]) }
  | IDENTIFIER LPAREN expr_list RPAREN { Call($1, $3) }

expr_list:
  | expr COMMA expr_list { $1 :: $3 }
  | expr { [$1] }
