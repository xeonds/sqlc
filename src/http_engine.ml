module Web = struct
  open Lwt
  open Cohttp
  open Cohttp_lwt_unix
  open Lwt.Syntax

  (* 请求数据类型 *)
  type request_data = 
    | JSON of Yojson.Safe.t
    | Text of string
    | FormFile of (string * string) list  (* (字段名, 临时路径) *)
    | Binary of string

  (* 响应数据类型 *)
  type response_data =
    | JsonResponse of Yojson.Safe.t
    | TextResponse of string
    | FileResponse of string  (* 文件路径 *)
    | BinaryResponse of bytes

  (* RESTful路由类型 *)
  type route_pattern =
    | Static of string
    | Dynamic of string  (* :id形式 *)
    | Wildcard

  type route = {
    method_: Code.meth;
    path: route_pattern list;
    handler: ((string * string)list -> request_data -> response_data Lwt.t);
  }

  (* Web服务状态 *)
  type service = {
    routes: route list ref;
    mutable middlewares: (Request.t -> request_data -> (Request.t * request_data) Lwt.t) list;
  }

  (* 路由解析器:路径串 string 转 route_pattern list *)
  let parse_path path =
    let split = path |> Uri.path 
    |> String.split_on_char '/'
    |> List.filter (fun s -> s <> "") in
    List.map (fun s ->
      match s.[0] with
      | ':' -> Dynamic (String.sub s 1 (String.length s - 1))
      | '*' -> Wildcard
      | _ -> Static s
    ) split

  (* 路由匹配，在所有 pattern 中找到匹配请求 path 的 pattern *)
  let rec match_route pattern path =
    match (pattern, path) with
    | [], [] -> Some []
    | Wildcard::_, _ -> Some []
    | Dynamic name::pt, Static hd::phd ->
        (* 匹配该动态域之后的部分是否有其他参数，将它们跟在该字段后返回 *)
        (match match_route pt phd with
         | Some params -> Some ((name, hd)::params)
         | None -> None)
    | Static a::pt, Static b::phd when a = b -> match_route pt phd
    | _ -> None

  (* 请求处理器 *)
  let handle_request service req body =
    let parse_multipart req body =
      let open Cohttp_lwt.Body in
      let%lwt body = to_string body in
      let boundary = req |> Request.headers |> fun h -> Header.get h "content-type" |> Option.get in
      let boundary = String.split_on_char '=' boundary |> List.tl |> String.concat "=" in
      let boundary = "--" ^ boundary in
      let parts = Re.Str.(split (regexp_string boundary) body) in
      let parts = List.filter (fun s -> s <> "" && s <> "--") parts in
      let parse_part part =
        let lines = String.split_on_char '\n' part in
        let lines = List.filter (fun s -> s <> "") lines in
        let header = List.hd lines in
        let header = String.split_on_char ';' header in
        let header = List.map (fun s -> String.trim s) header in
        let header = List.map (fun s -> String.split_on_char '=' s) header in
        let header = List.filter_map (function
          | [k; v] -> Some (k, v)
          | _ -> None
        ) header in
        let header = List.to_seq header |> Hashtbl.of_seq in
        let content = List.tl lines |> String.concat "\n" in
        let name = Hashtbl.find header "name" in
        let filename = Hashtbl.find_opt header "filename" in
        match filename with
        | Some _filename ->
            let tmp_path = Filename.temp_file "upload" "tmp" in
            Lwt_io.with_file ~mode:Lwt_io.output tmp_path (fun oc -> Lwt_io.write oc content)
            >|= fun () -> (name, tmp_path)
        | None -> Lwt.return (name, content)
      in
      Lwt_list.map_p parse_part parts
    in
    let path = req |> Request.uri in
    let meth = req |> Request.meth in
    let%lwt req_data = 
      match Request.headers req |> Header.get_media_type with
      | Some "application/json" -> 
          body |> Cohttp_lwt.Body.to_string >|= Yojson.Safe.from_string >|= fun j -> JSON j
      | Some "text/plain" ->
          body |> Cohttp_lwt.Body.to_string >|= fun s -> Text s
      | Some "multipart/form-data" ->
          (* 实现文件上传解析 *)
          parse_multipart req body >|= fun files -> FormFile files
      | _ -> 
          body |> Cohttp_lwt.Body.to_string >|= fun s -> Text s
    in

    (* 应用中间件 *)
    (* TODO: 给请求参数叠进去 *)
    let%lwt (req, req_data) = 
      List.fold_left (fun acc m -> acc >>= fun (r, d) -> m r d) 
        (Lwt.return (req, req_data)) service.middlewares 
    in

    (* 查找匹配路由 *)
    let matched = List.find_opt (fun r ->
      r.method_ = meth &&
      match match_route r.path (parse_path path) with
      | Some _ -> true
      | None -> false
    ) !(service.routes) in

    match matched with
    | Some route ->
        let params = match_route route.path (parse_path path) |> Option.get in
        let%lwt resp = route.handler params req_data in
        (match resp with
         | JsonResponse j ->
             let body = Yojson.Safe.to_string j |> Cohttp_lwt.Body.of_string in
             Server.respond ~status:`OK ~headers:(Header.init_with "Content-Type" "application/json") ~body ()
         | TextResponse t ->
             Server.respond_string ~headers:(Header.init_with "Content-Type" "text/plain") ~status:`OK ~body:t ()
         | FileResponse path ->
             let%lwt body = Lwt_io.(with_file ~mode:input path read) >|= Cohttp_lwt.Body.of_string in
             let mime_type path =
               match Filename.extension path with
               | ".html" -> "text/html"
               | ".css" -> "text/css"
               | ".js" -> "application/javascript"
               | ".json" -> "application/json"
               | ".png" -> "image/png"
               | ".jpg" | ".jpeg" -> "image/jpeg"
               | ".gif" -> "image/gif"
               | _ -> "application/octet-stream"
             in
             Server.respond ~status:`OK ~headers:(Header.init_with "Content-Type" (mime_type path)) ~body ()
         | BinaryResponse b ->
             Server.respond ~headers:(Header.init_with "Content-Type" "application/octet-stream") 
               ~body:(Cohttp_lwt.Body.of_string (Bytes.to_string b)) ~status:`OK ())
    | None ->
        Server.respond_string ~status:`Not_found ~body:"Route not found" ()

  (* RESTful路由注册 *)
  let add_route service meth path handler =
    let pattern = parse_path (Uri.of_string path) in
    service.routes := {method_=meth; path=pattern; handler} :: !(service.routes)

  (* 中间件系统 *)
  let add_middleware service middleware =
    service.middlewares <- middleware :: service.middlewares

  (* 日志中间件 *)
  let logging_middleware req data =
    let%lwt () = Logs_lwt.info (fun m -> m "Request: %s %s" 
      (Code.string_of_method req.Request.meth)
      (Request.uri req |> Uri.path)) in
    Lwt.return (req, data)

  (* CORS中间件 *)
  let cors_middleware req data =
    let headers = Header.init_with "Access-Control-Allow-Origin" "*"
      |> fun h -> Header.add h "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      |> fun h -> Header.add h "Access-Control-Allow-Headers" "Content-Type" in
    Lwt.return (req, data)

  (* 服务创建 *)

  (* 启动服务 *)
  let start service port =
    let callback _conn req body = 
      handle_request service req body
    in
    Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ())
end
