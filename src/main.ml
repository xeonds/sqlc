open Cmdliner
open Db_engine

(* 定义文件名参数 *)
let filename =
  let doc = "Input .sql file name" in
  Arg.(value & pos 0 (some string) None & info [] ~docv:"FILENAME" ~doc)

(* 读取文件内容的函数 *)
let read_file filename =
  try
    let ch = open_in filename in
    let content = really_input_string ch (in_channel_length ch) in
    close_in ch;
    Some content
  with _ -> None

(* 交互式终端 *)
let rec repl () =
  try
    Printf.printf ">>> ";
    let line = read_line () in
    let lexbuf = Lexing.from_string line in
    let parsed_expr = Parser.program Lexer.token lexbuf in
    let result = QueryEngine.execute parsed_expr in
    Printf.printf "%s\n" (Types.string_of_table result);
    repl ()
  with
  | Lexer.Lexing_error msg -> Printf.printf "Lexer error: %s\n" msg; repl ()
  | Parsing.Parse_error -> Printf.printf "Parser error\n"; repl ()
  | End_of_file -> ()

let main filename =
  match filename with
  | None -> 
      Printf.printf "Welcome to the SQL REPL!\n";
      repl()
  | Some file ->
      match read_file file with
      | Some content -> (
          (* 按行执行.sql文件的内容，遇到错误就报错并进入repl *)
          let lexbuf = Lexing.from_string content in
          try
            while true do
              let parsed_expr = Parser.program Lexer.token lexbuf in
              let result = QueryEngine.execute parsed_expr in
              Printf.printf "%s\n" (Types.string_of_table result);
            done
          with
          | Lexer.Lexing_error msg -> Printf.printf "Lexer error: %s\n" msg; repl ()
          | Parsing.Parse_error -> Printf.printf "Parser error\n"; repl ()
          | End_of_file -> ())
      | None ->
          Printf.printf "Error: Unable to read file '%s'\n" file

(* 命令行配置 *)
let cmd =
  let doc = "A program that reads and processes a file" in
  let info = Cmd.info "sql" ~doc ~version:"1.0.0" in
  Cmd.v info Term.(const main $ filename)

(* 运行程序 *)
let () = exit (Cmd.eval cmd)