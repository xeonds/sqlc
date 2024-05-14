open Lexer
open Parser

let parse str =
  let lexbuf = Lexing.from_string str in
  try
    main Sql_lexer.read lexbuf
  with
  | Lexing_error msg -> Printf.printf "Lexing error: %s\n" msg
  | Parsing.Parse_error -> Printf.printf "Parsing error\n"

let rec repl () =
  print_string "sql> ";
  flush stdout;
  match read_line () with
  | exception End_of_file -> ()
  | line ->
    parse line;
    repl ()

let () = repl ()
