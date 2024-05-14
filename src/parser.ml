type token =
  | IDENTIFIER of (
# 7 "parser.mly"
        string
# 6 "parser.ml"
)
  | INT of (
# 8 "parser.mly"
        int
# 11 "parser.ml"
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

open Parsing
let _ = parse_error;;
# 4 "parser.mly"
 open Ast 
# 51 "parser.ml"
let yytransl_const = [|
  259 (* CREATE *);
  260 (* USE *);
  261 (* SHOW *);
  262 (* INSERT *);
  263 (* INTO *);
  264 (* SELECT *);
  265 (* UPDATE *);
  266 (* SET *);
  267 (* DROP *);
  268 (* DELETE *);
  269 (* FROM *);
  270 (* WHERE *);
  271 (* EXIT *);
  272 (* DATABASE *);
  273 (* TABLES *);
  274 (* TABLE *);
  275 (* VALUES *);
  276 (* LPAREN *);
  277 (* RPAREN *);
  278 (* COMMA *);
  279 (* SEMICOLON *);
  280 (* STAR *);
  281 (* EQUALS *);
  282 (* LESS *);
  283 (* GREATER *);
  284 (* LESS_EQUAL *);
  285 (* GREATER_EQUAL *);
  286 (* NOT_EQUAL *);
  287 (* PLUS *);
  288 (* MINUS *);
  289 (* TIMES *);
  290 (* DIVIDE *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* IDENTIFIER *);
  258 (* INT *);
    0|]

let yylhs = "\255\255\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\002\000\002\000\003\000\003\000\004\000\
\004\000\000\000"

let yylen = "\002\000\
\004\000\004\000\007\000\003\000\011\000\006\000\009\000\006\000\
\004\000\004\000\002\000\003\000\001\000\003\000\001\000\002\000\
\000\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\018\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\011\000\
\000\000\000\000\000\000\004\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\001\000\000\000\002\000\000\000\012\000\
\000\000\000\000\010\000\009\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\016\000\006\000\000\000\
\008\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\
\007\000\000\000\000\000\014\000\005\000"

let yydgoto = "\002\000\
\012\000\019\000\064\000\049\000"

let yysindex = "\009\000\
\253\254\000\000\254\254\002\255\003\255\014\255\021\255\022\255\
\001\255\011\255\004\255\000\000\024\255\025\255\027\255\006\255\
\029\255\009\255\019\255\023\255\033\255\034\255\035\255\000\000\
\015\255\017\255\016\255\000\000\020\255\021\255\040\255\041\255\
\026\255\028\255\030\255\000\000\021\255\000\000\021\255\000\000\
\031\255\018\255\000\000\000\000\045\255\032\255\036\255\046\255\
\037\255\048\255\038\255\039\255\044\255\000\000\000\000\042\255\
\000\000\000\000\047\255\051\255\052\255\043\255\049\255\053\255\
\000\000\052\255\050\255\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\250\254\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\054\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\055\255\000\000\
\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\230\255\238\255\000\000"

let yytablesize = 77
let yytable = "\003\000\
\004\000\005\000\006\000\040\000\007\000\008\000\013\000\009\000\
\010\000\001\000\046\000\011\000\047\000\013\000\013\000\014\000\
\021\000\015\000\022\000\016\000\017\000\018\000\020\000\023\000\
\025\000\026\000\024\000\027\000\028\000\029\000\030\000\031\000\
\032\000\033\000\034\000\035\000\037\000\036\000\038\000\039\000\
\041\000\042\000\050\000\045\000\048\000\051\000\054\000\068\000\
\043\000\056\000\044\000\062\000\052\000\063\000\000\000\060\000\
\053\000\000\000\000\000\055\000\057\000\058\000\059\000\000\000\
\000\000\065\000\061\000\000\000\000\000\000\000\066\000\000\000\
\069\000\067\000\000\000\015\000\017\000"

let yycheck = "\003\001\
\004\001\005\001\006\001\030\000\008\001\009\001\013\001\011\001\
\012\001\001\000\037\000\015\001\039\000\016\001\021\001\018\001\
\016\001\016\001\018\001\017\001\007\001\001\001\001\001\013\001\
\001\001\001\001\023\001\001\001\023\001\001\001\022\001\013\001\
\010\001\001\001\001\001\001\001\020\001\023\001\023\001\020\001\
\001\001\001\001\025\001\014\001\014\001\001\001\001\001\066\000\
\023\001\002\001\023\001\001\001\021\001\002\001\255\255\014\001\
\021\001\255\255\255\255\023\001\023\001\023\001\019\001\255\255\
\255\255\023\001\020\001\255\255\255\255\255\255\022\001\255\255\
\023\001\021\001\255\255\021\001\023\001"

let yynames_const = "\
  CREATE\000\
  USE\000\
  SHOW\000\
  INSERT\000\
  INTO\000\
  SELECT\000\
  UPDATE\000\
  SET\000\
  DROP\000\
  DELETE\000\
  FROM\000\
  WHERE\000\
  EXIT\000\
  DATABASE\000\
  TABLES\000\
  TABLE\000\
  VALUES\000\
  LPAREN\000\
  RPAREN\000\
  COMMA\000\
  SEMICOLON\000\
  STAR\000\
  EQUALS\000\
  LESS\000\
  GREATER\000\
  LESS_EQUAL\000\
  GREATER_EQUAL\000\
  NOT_EQUAL\000\
  PLUS\000\
  MINUS\000\
  TIMES\000\
  DIVIDE\000\
  EOF\000\
  "

let yynames_block = "\
  IDENTIFIER\000\
  INT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 21 "parser.mly"
                                         ( CreateDatabase _3 )
# 215 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 22 "parser.mly"
                                      ( UseDatabase _3 )
# 222 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'columns) in
    Obj.repr(
# 23 "parser.mly"
                                                            ( CreateTable(_3, _5) )
# 230 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    Obj.repr(
# 24 "parser.mly"
                          ( ShowTables )
# 236 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 6 : 'columns) in
    let _9 = (Parsing.peek_val __caml_parser_env 2 : 'values) in
    Obj.repr(
# 25 "parser.mly"
                                                                                       ( InsertInto(_3, _5, _9) )
# 245 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'columns) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_where) in
    Obj.repr(
# 26 "parser.mly"
                                                       ( Select(_2, _4, _5) )
# 254 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _8 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 27 "parser.mly"
                                                                           ( Update(_2, _4, _6, _8) )
# 264 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 28 "parser.mly"
                                                      ( Delete(_3, _5) )
# 272 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 29 "parser.mly"
                                    ( DropTable _3 )
# 279 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 30 "parser.mly"
                                       ( DropDatabase _3 )
# 286 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    Obj.repr(
# 31 "parser.mly"
                   ( Exit )
# 292 "parser.ml"
               : unit))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'columns) in
    Obj.repr(
# 34 "parser.mly"
                             ( [_1] @ _3 )
# 300 "parser.ml"
               : 'columns))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 35 "parser.mly"
               ( [_1] )
# 307 "parser.ml"
               : 'columns))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'values) in
    Obj.repr(
# 38 "parser.mly"
                     ( string_of_int _1 :: _3 )
# 315 "parser.ml"
               : 'values))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 39 "parser.mly"
        ( [string_of_int _1] )
# 322 "parser.ml"
               : 'values))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 42 "parser.mly"
                     ( Some _2 )
# 329 "parser.ml"
               : 'opt_where))
; (fun __caml_parser_env ->
    Obj.repr(
# 43 "parser.mly"
    ( None )
# 335 "parser.ml"
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
   (Parsing.yyparse yytables 1 lexfun lexbuf : unit)
