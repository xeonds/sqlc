open Ast
open Eval
(* Main function to parse and evaluate *)
let main () =
  try
    while true do
      print_string "SQL > ";
      flush stdout;
      let input = read_line () in
      match Angstrom.parse_string ~consume:All statement_parser input with
      | Error msg -> print_endline ("Error: " ^ msg)
      | Ok stmt -> eval_ast stmt
    done
  with End_of_file -> ()

let _ = main ()