include Ast_type


let get_dict_node_param key y =
  List.find (fun x -> let (k,_) = x in k = key) y

let get_node_type y =
let _, node_type = get_dict_node_param "Node" y in
match node_type with
| `String s -> s
| _ -> raise Not_found

let rec parse_node (y:Yaml.value) =
  match y with
  | `O o -> begin
    let node_type = get_node_type o in
    if node_type = "File" then
      let _, v = get_dict_node_param "Version" o in
      let v = match v with
      | `Float f -> int_of_float f
      | _ -> raise (Invalid_argument "Dose not match as file node") in
      let _, b = get_dict_node_param "Body" o in
      let c = match b with
       | `A a -> List.map parse_decl a
       | _ -> raise (Invalid_argument "Dose not match as file node") in
      File {file_version = v;file_body = c}
    else if node_type = "Block" then
      let _, b = get_dict_node_param "Body" o in
      let c = match b with
      | `A a -> List.map parse_stmt a
      | _ -> raise (Invalid_argument "Dose not match as file node") in
      Block {block_body = c}
    else
      raise (Invalid_argument "Dose not match as file node")
    end
  | _ -> raise (Invalid_argument "Dose not match as file node")

and parse_stmt y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    if node_type = "Expr" then
      let _,expr = get_dict_node_param "Expr" o in
     ExprStmt {expr = parse_expr expr}
    else
     raise (Invalid_argument "Dose not match as stmt node")
   end
| _ -> raise (Invalid_argument "Dose not match as stmt node")

and parse_decl y =
match y with
| _ -> raise (Invalid_argument "Dose not match as decl node")

and parse_expr y =
match y with
| _ -> raise (Invalid_argument "Dose not match as expr node")

let parse y =
  match y with
  | `Null -> Constant { constant_kind = Null; constant_value = "null"}
  | `String s -> Constant {constant_kind = String; constant_value = s}
  | `Bool b -> Constant {constant_kind = Boolean; constant_value = string_of_bool b}
  | `Float f -> Constant {constant_kind = Float; constant_value = string_of_float f}
  | `O o -> begin 
    if List.exists (fun x -> let (k,_) = x in k = "Node") o then
      Constant { constant_kind = Null; constant_value = "null"}
    else
      Constant { constant_kind = Null; constant_value = "null"}
    end
  | `A _ -> exit 2

  let convert_and_write input output =
  let () = print_endline input in
  let () = print_endline output in
  let inputFile = Fpath.(v input) in
  let outputFile = Fpath.(v output) in
  let parsed = Yaml_unix.of_file_exn inputFile in
  let a = parse_node parsed
  in
  let _ = a in
  let () = Yaml.pp Format.std_formatter parsed in
  let _ = Bos.OS.File.write outputFile "" in 
  ()


let main argc argv =
  if argc < 3 then
    exit 1
  else
    begin
      let input = (Array.get argv 1) in
      let output = (Array.get argv 2) in
      convert_and_write input output
    end

let () = main (Array.length Sys.argv) Sys.argv
