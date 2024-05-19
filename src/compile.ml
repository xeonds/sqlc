(* compile.ml *)

let compile_to_ocaml ast output_file =
  let code = Ast.generate_code ast in
  let oc = open_out output_file in
  Printf.fprintf oc "open Eval\n";
  Printf.fprintf oc "let () =\n";
  Printf.fprintf oc "  %s\n" code;
  close_out oc;
  let _ = Sys.command (Printf.sprintf "ocamlfind ocamlc -package csv -package unix -linkpkg -o %s %s" (Filename.chop_suffix output_file ".ml") output_file) in
  ()

(* Main function to compile SQL from a file *)
let () =
  if Array.length Sys.argv <> 3 then
    Printf.printf "Usage: %s <input.sql> <output.ml>\n" Sys.argv.(0)
  else
    let input_file = Sys.argv.(1) in
    let output_file = Sys.argv.(2) in
    let input = In_channel.read_all input_file in
    let lexbuf = Lexing.from_string input in
    let parsed_expr = Parser.main Lexer.token lexbuf in
    compile_to_ocaml parsed_expr output_file
