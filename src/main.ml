open Printf
open Lexing

let parse_with_error lexbuf =
  try
    let result = Parser.main Lexer.token lexbuf in
    Some(result)
  with
  | Lexer.Lexing_error msg ->
      eprintf "Lexing error: %s\n%!" msg;
      None
  | Parsing.Parse_error ->
      eprintf "At offset %d: syntax error.\n%!" (Lexing.lexeme_start lexbuf);
      None

let rec repl () =
  printf "> ";
  flush stdout;
  let input = read_line () in
  let lexbuf = from_string input in
  match parse_with_error lexbuf with
  | Some(ast) ->
      printf "Parsed: %s\n" (Ast.show_expr ast); (* 确保在 ast.ml 文件中实现 show_expr 函数 *)
      repl ()
  | None -> repl ()

let () = repl ()
