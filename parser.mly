(* parser.mly *)
%{
  type expr =
    | Int of int
    | Ident of string

  type condition = Condition of string * expr

  type column =
    | Column of string * string
    | ColumnId of string

  type command =
    | CreateDatabase of string
    | UseDatabase of string
    | CreateTable of string * column list
    | ShowTables
    | InsertInto of string * column list * expr list
    | Select of column list * string
    | Update of string * (string * expr) list * condition
    | DropTable of string
    | DropDatabase of string
    | Exit
%}

%token <string> ID
%token <int> INT
%token CREATE DATABASE USE TABLE SHOW TABLES INSERT INTO VALUES SELECT UPDATE SET DROP EXIT
%token LPAREN RPAREN COMMA EQ

%start program
%type <command list> program

%%

program:
    | commands { $1 }

commands:
    | command { [$1] }
    | command commands { $1 :: $2 }

command:
    | CREATE DATABASE ID { CreateDatabase $3 }
    | USE DATABASE ID { UseDatabase $3 }
    | CREATE TABLE ID LPAREN columns RPAREN { CreateTable ($3, $5) }
    | SHOW TABLES { ShowTables }
    | INSERT INTO ID LPAREN columns RPAREN VALUES LPAREN values RPAREN { InsertInto ($3, $5, $9) }
    | SELECT columns FROM ID { Select ($2, $4) }
    | UPDATE ID SET column EQ expr WHERE condition { Update ($2, $5, $8) }
    | DROP TABLE ID { DropTable $3 }
    | DROP DATABASE ID { DropDatabase $3 }
    | EXIT { Exit }

columns:
    | column { [$1] }
    | column COMMA columns { $1 :: $3 }

column:
    | ID TYPE { Column ($1, $2) }
    | ID { ColumnId $1 }

values:
    | value { [$1] }
    | value COMMA values { $1 :: $3 }

value:
    | INT { Int $1 }
    | ID { Ident $1 }

expr:
    | INT { Int $1 }
    | ID { Ident $1 }

condition:
    | ID EQ INT { Condition ($1, Int $3) }
