open Eval

(* 主程序循环 *)
let rec repl () =
  try
    Printf.printf ">>> ";
    let line = read_line () in
    let lexbuf = Lexing.from_string line in
    let parsed_expr = Parser.main Lexer.token lexbuf in
    eval_expr parsed_expr;
    repl ()
  with
  | Lexer.Lexing_error msg -> Printf.printf "Lexer error: %s\n" msg; repl ()
  | Parsing.Parse_error -> Printf.printf "Parser error\n"; repl ()
  | End_of_file -> ()

(* 程序入口 *)
let () = repl ()

