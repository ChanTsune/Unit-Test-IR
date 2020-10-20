include Ast_type

exception TypeError

let raise_ir_parse_error msg y =
  let s = Yaml.to_string_exn y in
  raise (Invalid_argument (msg ^ "\n" ^ s))

let case_of_decl decl = match decl with| Case c -> c |_ -> raise TypeError

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
      Block (parse_block o)
    else
      raise_ir_parse_error "Dose not match as file node" y
    end
  | _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as file node" y

and parse_block o =
  let c = match get_dict_node_param "Body" o with
  | _, `A a -> a |> List.map parse_stmt
  | _ -> raise (Invalid_argument "Dose not match as block node")
  in {block_body = c}
and parse_stmt y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    match node_type with
    | "Expr" ->
      let _,expr = get_dict_node_param "Expr" o in
      ExprStmt {expr = parse_expr expr}
    | "Decl" ->
      let _, decl = get_dict_node_param "Decl" o in
      DeclStmt {decl = parse_decl decl}
    | _ -> raise_ir_parse_error "Dose not match as any stmt node" y
   end
| _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as stmt node" y

and parse_decl y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    match node_type with
    | "Suite" ->
      let name = match get_dict_node_param "Name" o with
       | _,`String s -> s
       | _ -> raise TypeError in
      let setup = match get_dict_node_param "SetUp" o with
       | _,`A a -> List.map parse_expr a
       | _ -> raise TypeError in
      let cases = match get_dict_node_param "Cases" o with
      | _, `A a -> a |> List.map parse_decl |> List.map case_of_decl
      | _ -> raise TypeError in
      let tear_down = match get_dict_node_param "TearDown" o with
      | _, `A a -> List.map parse_expr a
      | _ -> raise TypeError in
      Suite {suite_name = name; suite_set_up = setup; suite_cases = cases; suite_tear_down = tear_down}
    | "CaseBlock" ->
      let name = match get_dict_node_param "Name" o with
      | _, `String s -> s
      | _ -> raise TypeError in
      let block = match get_dict_node_param "Body" o with
      | _, `O o -> parse_block o
      |_ -> raise TypeError in
      Case (CaseBlock {case_block_name=name;case_block_body=block})
    | _ -> raise_ir_parse_error "Dose not match as any decl node" y
   end
| _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as any decl node" y

and parse_expr y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    match node_type with
    |_ -> raise_ir_parse_error "Dose not match as any expr node" y
   end
| _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as any expr node" y

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
