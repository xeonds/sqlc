module Web = struct
  open Lwt
  open Cohttp
  open Cohttp_lwt_unix
  open Lwt.Syntax

  (* 请求数据类型 *)
  type request_data = 
    | JSON of Yojson.Safe.t
    | Text of string
    | FormFile of (string * string)  (* (字段名, 临时路径) *)
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
    handler: (string list -> request_data -> response_data Lwt.t);
  }

  (* Web服务状态 *)
  type service = {
    routes: route list ref;
    mutable middlewares: (Request.t -> request_data Lwt.t -> (Request.t * request_data) Lwt.t) list;
  }

  (* 路由解析器 *)
  let parse_path path =
    let segments = 
      path |> Uri.path 
      |> String.split_on_char '/'
      |> List.filter (fun s -> s <> "")
    in
    List.map (function
      | s when String.length s > 0 && s.[0] = ':' -> Dynamic (String.sub s 1 (String.length s - 1))
      | "*" -> Wildcard
      | s -> Static s
    ) segments

  (* 路由匹配 *)
  let rec match_route pattern path =
    match (pattern, path) with
    | [], [] -> Some []
    | Wildcard::_, _ -> Some []
    | Dynamic name::pt, hd::phd ->
        (match match_route pt phd with
         | Some params -> Some ((name, hd)::params)
         | None -> None)
    | Static a::pt, b::phd when a = b -> match_route pt phd
    | _ -> None

  (* 请求处理器 *)
  let handle_request service req body =
    let path = req |> Request.uri |> Uri.path in
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
             Server.respond ~headers:(Header.init_with "Content-Type" "application/json") ~body `OK
         | TextResponse t ->
             Server.respond_string ~headers:(Header.init_with "Content-Type" "text/plain") t
         | FileResponse path ->
             let body = Cohttp_lwt.Body.of_string (read_file path) in
             Server.respond ~headers:(Header.init_with "Content-Type" (mime_type path)) ~body `OK
         | BinaryResponse b ->
             Server.respond ~headers:(Header.init_with "Content-Type" "application/octet-stream") 
               ~body:(Cohttp_lwt.Body.of_bytes b) `OK)
    | None ->
        Server.respond_string ~status:`Not_found "Route not found"

  (* RESTful路由注册 *)
  let add_route service meth path handler =
    let pattern = parse_path (Uri.of_string path) in
    service.routes := {method_=meth; path=pattern; handler} :: !(service.routes)

  (* 中间件系统 *)
  let add_middleware service middleware =
    service.middlewares <- middleware :: service.middlewares

  (* 示例中间件 *)
  let logging_middleware req data =
    let%lwt () = Logs_lwt.info (fun m -> m "Request: %s %s" 
      (Code.string_of_method req.Request.meth)
      (req.Request.uri |> Uri.path)) in
    Lwt.return (req, data)

  (* 启动服务 *)
  let start service port =
    let callback _conn req body = 
      handle_request service req body
    in
    Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ())
end
