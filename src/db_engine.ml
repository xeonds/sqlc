module Types = struct  
  type dtype = String | Int | Bool | Float  
  type value = VString of string | VInt of int | VBool of bool | VFloat of float  

  let cast_value dtype value =
    match dtype with
    | String -> VString value
    | Int -> VInt (int_of_string value)
    | Bool -> VBool (bool_of_string value)
    | Float -> VFloat (float_of_string value)

  let cast_type = function
    | String -> "string"
    | Int -> "int"
    | Bool -> "bool"
    | Float -> "float"

  let type_of_string = function
    | "string" -> String
    | "int" -> Int
    | "bool" -> Bool
    | "float" -> Float
    | _ -> failwith "Invalid type"
  
  let string_of_value = function
    | VString s -> s
    | VInt i -> string_of_int i
    | VBool b -> string_of_bool b
    | VFloat f -> string_of_float f

  let default_value = function
    | String -> VString ""
    | Int -> VInt 0
    | Bool -> VBool false
    | Float -> VFloat 0.0
    
  type field_spec = {  
    name : string;  
    dtype : dtype;  
  }  
  
  type table = {  
    schema : field_spec list;  
    mutable data : value list list;  
    path : string;  
  }  

  type expr =
    | Literal of value
    | Column of string
    | BinOp of expr * string * expr
    | Call of string * expr list

  type statement =
    | Select of string list * string * (string * expr) option * expr option
    | CreateTable of string * (string * dtype) list
    | InsertInto of string * string list * value list list
    | Update of string * string * value * expr option
    | DeleteFrom of string * expr option
    | ShowTables
    | DropTable of string
    | LoadObject of expr
    | StoreObject of expr
    | Exit

  type eval =
    | Select of string list * table * expr option
    | Join of table * table * expr
    | CreateTable of string * (string * dtype) list
    | InsertInto of table * string list * value list list
    | Update of table * string * value * expr option
    | DeleteFrom of table * expr option
    | ShowTables
    | DropTable of string
    | LoadObject of expr
    | StoreObject of expr
    | Exit

  let string_of_table tbl =  
    let header = List.map (fun f -> f.name ^ ":" ^ cast_type f.dtype) tbl.schema |> String.concat "," in  
    let rows = List.map (fun row ->  
      List.map string_of_value row |> String.concat ","  
    ) tbl.data |> String.concat "\n" in  
    header ^ "\n" ^ rows
end  
  
module Database = struct
  open Types

  let init_db db_name = 
    if Sys.file_exists db_name then
      failwith "Database already exists"
    else
      Unix.mkdir db_name 0o777

  let load_table path =  
    let ic = open_in path in  
    let schema =  
      input_line ic  
      |> String.split_on_char ','  
      |> List.map (fun s ->
         match String.split_on_char ':' s with
         | [name; "string"] -> {name; dtype=String}
         | [name; "int"] -> {name; dtype=Int}
         | [name; "bool"] -> {name; dtype=Bool}
         | [name; "float"] -> {name; dtype=Float}
         | _ -> failwith "Invalid header format")
    in  
    let data =  
      let rec read_lines acc =  
        try  
          let line = input_line ic |> String.split_on_char ',' in  
          let row = List.map2 (fun f v -> cast_value f.dtype v) schema line in
          read_lines (row::acc)
        with End_of_file -> List.rev acc  
      in  
      read_lines []  
    in  
    close_in ic;  
    {schema; data; path}  
  
  let save_table tbl =  
    let oc = open_out tbl.path in  
    let schema_str =  List.map (fun f -> f.name ^ ":" ^ cast_type f.dtype) tbl.schema |> String.concat "," in  
    output_string oc (schema_str ^ "\n");  
    List.iter (fun row ->  
      let line = List.map (function  
        | VString s -> s  
        | VInt i -> string_of_int i  
        | VBool b -> string_of_bool b  
        | VFloat f -> string_of_float f)  
        row  
      |> String.concat ","  
      in  
      output_string oc (line ^ "\n")  
    ) tbl.data;  
    close_out oc  
  
  (* append new line in memory *)
  (* need manual writeback *)
  let append_row tbl (row: value list) = 
    if List.length row <> List.length tbl.schema then
      failwith "Row length does not match table schema"
    else
      (* check if each item's type in row matches the corresponding position's tbl.scheme's type *)
      List.iter2 (fun f v -> 
        match f.dtype, v with
        | String, VString _ | Int, VInt _ | Bool, VBool _ | Float, VFloat _ -> ()
        | _ -> failwith "Type mismatch") tbl.schema row;
    tbl.data <- row::tbl.data
end

module ObjectStorage = struct  
  let hash_content data =  
    Digest.string data |> Digest.to_hex  

  (* hash filename & storage it to folder *)
  let store_file ~user_dir filename content =  
    let hash_name = hash_content filename in  
    let object_path = Filename.concat user_dir hash_name in  
    let oc = open_out_bin object_path in  
    output_string oc content;  
    close_out oc;  
    hash_name  
  
  let retrieve_file ~user_dir hash =  
    let path = Filename.concat user_dir hash in  
    if Sys.file_exists path then  
      let ic = open_in_bin path in  
      let content = really_input_string ic (in_channel_length ic) in  
      close_in ic;  
      Some content  
    else None  
end  

module Engine = struct
  open Types

  (* expr evaluate *)
  let eval_cond cond row field_specs = 
    let rec eval_expr = function
      | Literal v -> v
      | Column name -> List.assoc name (List.combine (List.map (fun f -> f.name) field_specs) row)
      | BinOp (e1, op, e2) -> (
          let v1 = eval_expr e1 in
          let v2 = eval_expr e2 in
          match op with
          | "+" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VInt (i1 + i2)
            | VFloat f1, VFloat f2 -> VFloat (f1 +. f2)
            | _ -> failwith "Type mismatch")
          | "-" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VInt (i1 - i2)
            | VFloat f1, VFloat f2 -> VFloat (f1 -. f2)
            | _ -> failwith "Type mismatch")
          | "*" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VInt (i1 * i2)
            | VFloat f1, VFloat f2 -> VFloat (f1 *. f2)
            | _ -> failwith "Type mismatch")
          | "/" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VInt (i1 / i2)
            | VFloat f1, VFloat f2 -> VFloat (f1 /. f2)
            | _ -> failwith "Type mismatch")
          | "%" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VInt (i1 mod i2)
            | _ -> failwith "Type mismatch")
          | "=" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 = i2)
            | VFloat f1, VFloat f2 -> VBool (f1 = f2)
            | VBool b1, VBool b2 -> VBool (b1 = b2)
            | VString s1, VString s2 -> VBool (s1 = s2)
            | _ -> failwith "Type mismatch")
          | "<" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 < i2)
            | VFloat f1, VFloat f2 -> VBool (f1 < f2)
            | _ -> failwith "Type mismatch")
          | ">" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 > i2)
            | VFloat f1, VFloat f2 -> VBool (f1 > f2)
            | _ -> failwith "Type mismatch")
          | "<=" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 <= i2)
            | VFloat f1, VFloat f2 -> VBool (f1 <= f2)
            | _ -> failwith "Type mismatch")
          | ">=" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 >= i2)
            | VFloat f1, VFloat f2 -> VBool (f1 >= f2)
            | _ -> failwith "Type mismatch")
          | "<>" | "!=" -> (match v1, v2 with
            | VInt i1, VInt i2 -> VBool (i1 <> i2)
            | VFloat f1, VFloat f2 -> VBool (f1 <> f2)
            | VBool b1, VBool b2 -> VBool (b1 <> b2)
            | VString s1, VString s2 -> VBool (s1 <> s2)
            | _ -> failwith "Type mismatch")
          | "AND" -> (match v1, v2 with
            | VBool b1, VBool b2 -> VBool (b1 && b2)
            | _ -> failwith "Type mismatch")
          | "OR" -> (match v1, v2 with
            | VBool b1, VBool b2 -> VBool (b1 || b2)
            | _ -> failwith "Type mismatch")
          | _ -> failwith "Unsupported operator")
      | Call (name, args) -> (
          match name with
          | "if" -> (match args with
            | [cond; e1; e2] -> (match eval_expr cond with
              | VBool true -> eval_expr e1
              | VBool false -> eval_expr e2
              | _ -> failwith "Type mismatch")
            | _ -> failwith "Invalid number of arguments")
          | "not" -> (match args with
            | [e] -> (match eval_expr e with
              | VBool b -> VBool (not b)
              | _ -> failwith "Type mismatch")
            | _ -> failwith "Invalid number of arguments")
          | _ -> failwith "Unsupported function")
    in
    eval_expr cond |> function
    | VBool b -> b
    | _ -> failwith "Type mismatch"

  (** 执行查询语句返回结果表 *)
  let execute = function
    | Select (cols, table, where) ->
        let rows = match where with
          | None -> table.data
          | Some cond -> List.filter (fun row -> eval_cond cond row table.schema) table.data in
        let filtered = 
          if List.mem "*" cols then rows
          else
            List.map (fun row -> List.map (fun col -> List.assoc col (List.combine (List.map (fun f -> f.name) table.schema) row)) cols) rows in
        {table with data=filtered}
    | Join (left, right, on) ->
      let left_col, right_col = match on with
        | BinOp (Column c, "=", Column c') when List.mem c (List.map (fun f -> f.name) left.schema) && List.mem c' (List.map (fun f -> f.name) right.schema) -> c, c'
        | _ -> failwith "Invalid join condition" in
      let left_index = List.assoc left_col (List.mapi (fun i f -> (f.name, i)) left.schema) in
      let right_index = List.assoc right_col (List.mapi (fun i f -> (f.name, i)) right.schema) in
      let right_map = List.fold_left (fun acc row ->
        let key = List.nth row right_index in
        let values = try List.assoc key acc with Not_found -> [] in
        (key, row :: values) :: List.remove_assoc key acc) [] right.data in
      let joined = List.fold_left (fun acc row1 ->
        let key = List.nth row1 left_index in
        match List.assoc_opt key right_map with
        | Some rows2 -> List.rev_append (List.map (fun row2 -> row1 @ row2) rows2) acc
        | None -> acc) [] left.data in
      {schema=left.schema @ right.schema; data=List.rev joined; path = ""}
    | CreateTable (name, cols) -> 
      let table_path = name ^ ".csv" in
      if Sys.file_exists table_path then
        failwith "Table already exists"
      else
        let schema = List.map (fun (name, dtype) -> {name; dtype}) cols in
        let tbl = {schema; data=[]; path=table_path} in
        Database.save_table tbl;
        tbl
    | ShowTables -> 
        let rec print_tree path prefix =
          let entries = Sys.readdir path |> Array.to_list |> List.sort String.compare in
          List.iteri (fun i entry ->
            let is_last = i = List.length entries - 1 in
            let new_prefix = prefix ^ (if is_last then "└── " else "├── ") in
            let full_path = Filename.concat path entry in
            if Sys.is_directory full_path then begin
              Printf.printf "%s%s/\n" new_prefix entry;
              print_tree full_path (prefix ^ (if is_last then "    " else "│   "))
            end else if Filename.check_suffix entry ".csv" then begin
              let ic = open_in full_path in
              let first_row = try input_line ic with End_of_file -> "" in
              let line_count = ref 0 in
              try while true do ignore (input_line ic); incr line_count done
              with End_of_file -> close_in ic;
              Printf.printf "%s%s (First row: %s, Lines: %d)\n" new_prefix entry first_row !line_count
            end else
              Printf.printf "%s%s\n" new_prefix entry
          ) entries
        in
        print_tree "." "";
        {schema=[]; data=[]; path=""}
    | InsertInto (table, cols, vals) -> 
        let rows = List.map (fun row -> 
          List.map (fun f -> 
            match List.assoc_opt f.name (List.combine cols row) with
            | Some v -> v
            | None -> default_value f.dtype
            ) table.schema
          ) vals in
        List.iter (fun row -> Database.append_row table row) rows;
        table
    | Update (table, col, value, cond) -> 
        let col_index = List.assoc col (List.mapi (fun i f -> (f.name, i)) table.schema) in
        let data_updated = List.map (fun row -> 
          if (match cond with
            | None -> true
            | Some c -> eval_cond c row table.schema) then
            List.mapi (fun i v -> if i == col_index then value else v) row else row
            ) table.data in
        table.data <- data_updated;
        table
    | DeleteFrom (table, cond) ->
        let data_deleted = List.filter (fun row -> match cond with
          | None -> true
          | Some c -> not (eval_cond c row table.schema)) table.data in
        table.data <- data_deleted;
        table
    | DropTable name -> 
        Sys.remove name;
        {schema=[]; data=[]; path=name}
    | LoadObject expr -> 
        (* placeholder, don't use *)
        let path = match expr with
          | Literal (VString s) -> s
          | _ -> failwith "Invalid argument" in
        let content = ObjectStorage.retrieve_file ~user_dir:"." path in
        (match content with
          | Some data -> 
              let tbl = Database.load_table data in
              tbl
          | None -> failwith "Object not found")
    | StoreObject expr ->
        (* placeholder, don't use *)
        let tbl = match expr with
          | Literal (VString s) -> Database.load_table s
          | _ -> failwith "Invalid argument" in
        let path = ObjectStorage.store_file ~user_dir:"." tbl.path (tbl.path ^ ".csv") in
        Database.append_row tbl [VString path];
        Database.save_table tbl;
        tbl
    | Exit -> exit 0
end
