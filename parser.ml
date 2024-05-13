type token =
  | IDENTIFIER of (
# 3 "parser.mly"
        string
# 6 "parser.ml"
)
  | INT of (
# 4 "parser.mly"
        int
# 11 "parser.ml"
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

open Parsing
let _ = parse_error;;
# 1 "parser.mly"
 open Ast 
# 31 "parser.ml"
let yytransl_const = [|
  259 (* CREATE *);
  260 (* TABLE *);
  261 (* INSERT *);
  262 (* INTO *);
  263 (* SELECT *);
  264 (* FROM *);
  265 (* WHERE *);
  266 (* LPAREN *);
  267 (* RPAREN *);
  268 (* COMMA *);
  269 (* SEMICOLON *);
  270 (* VALUES *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* IDENTIFIER *);
  258 (* INT *);
    0|]

let yylhs = "\255\255\
\001\000\001\000\001\000\002\000\002\000\003\000\003\000\004\000\
\004\000\000\000"

let yylen = "\002\000\
\007\000\011\000\006\000\003\000\001\000\003\000\001\000\002\000\
\000\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\010\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\008\000\003\000\001\000\000\000\000\000\000\000\000\000\000\000\
\000\000\006\000\002\000"

let yydgoto = "\002\000\
\006\000\010\000\031\000\022\000"

let yysindex = "\007\000\
\253\254\000\000\005\255\251\254\010\255\000\000\011\255\012\255\
\002\255\007\255\006\255\008\255\010\255\016\255\010\255\010\255\
\000\000\013\255\009\255\014\255\018\255\015\255\017\255\019\255\
\000\000\000\000\000\000\021\255\022\255\020\255\023\255\022\255\
\024\255\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\255\254\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\025\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\028\255\000\000\000\000\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\246\255\245\255\000\000"

let yytablesize = 39
let yytable = "\003\000\
\008\000\004\000\017\000\005\000\019\000\020\000\005\000\001\000\
\007\000\005\000\009\000\011\000\012\000\013\000\014\000\015\000\
\018\000\016\000\025\000\023\000\034\000\021\000\000\000\030\000\
\024\000\000\000\000\000\026\000\000\000\027\000\029\000\032\000\
\028\000\033\000\000\000\000\000\035\000\009\000\007\000"

let yycheck = "\003\001\
\006\001\005\001\013\000\007\001\015\000\016\000\008\001\001\000\
\004\001\011\001\001\001\001\001\001\001\012\001\008\001\010\001\
\001\001\010\001\001\001\011\001\032\000\009\001\255\255\002\001\
\011\001\255\255\255\255\013\001\255\255\013\001\010\001\012\001\
\014\001\011\001\255\255\255\255\013\001\013\001\011\001"

let yynames_const = "\
  CREATE\000\
  TABLE\000\
  INSERT\000\
  INTO\000\
  SELECT\000\
  FROM\000\
  WHERE\000\
  LPAREN\000\
  RPAREN\000\
  COMMA\000\
  SEMICOLON\000\
  VALUES\000\
  EOF\000\
  "

let yynames_block = "\
  IDENTIFIER\000\
  INT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'columns) in
    Obj.repr(
# 15 "parser.mly"
                                                            ( CreateTable(_3, _5) )
# 132 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 6 : 'columns) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : 'values) in
    Obj.repr(
# 16 "parser.mly"
                                                                                       ( InsertInto(_3, _5, _9) )
# 141 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'columns) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_where) in
    Obj.repr(
# 17 "parser.mly"
                                                       ( SelectFrom(_2, _4, _5) )
# 150 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'columns) in
    Obj.repr(
# 20 "parser.mly"
                             ( [_1] @ _3 )
# 158 "parser.ml"
               : 'columns))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 21 "parser.mly"
               ( [_1] )
# 165 "parser.ml"
               : 'columns))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'values) in
    Obj.repr(
# 24 "parser.mly"
                     ( string_of_int _1 :: _3 )
# 173 "parser.ml"
               : 'values))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 25 "parser.mly"
        ( [string_of_int _1] )
# 180 "parser.ml"
               : 'values))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 28 "parser.mly"
                     ( Some _2 )
# 187 "parser.ml"
               : 'opt_where))
; (fun __caml_parser_env ->
    Obj.repr(
# 29 "parser.mly"
    ( None )
# 193 "parser.ml"
               : 'opt_where))
(* Entry main *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let main (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.expr)
