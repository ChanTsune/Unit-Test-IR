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
  let body = match get_dict_node_param "Body" o with
  | _, `A a -> a |> List.map parse_stmt
  | _ -> raise (Invalid_argument "Dose not match as block node")
  in {block_body = body}
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
    | "Return" ->
      let _, v = get_dict_node_param "Value" o in
      Return {return_value = parse_expr v}
    | "For" ->
      let v = match get_dict_node_param "Value" o with|_,`O o -> o|_ -> raise TypeError in
      let _,g = get_dict_node_param "Generator" o in
      let b = match get_dict_node_param "Body" o with|_,`O o -> o|_ -> raise TypeError in
      For {for_value = parse_var v; for_generator = parse_expr g; for_body = parse_block b}
    | _ -> raise_ir_parse_error "Dose not match as any stmt node" y
   end
| _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as stmt node" y

and parse_var o =
  let name = match get_dict_node_param "Name" o with
  | _,`String s -> s
  | _ -> raise TypeError in
  let type_ = match get_dict_node_param "Type" o with
  | _,`String s -> Some s
  | _ -> None in
  let value = match get_dict_node_param "Value" o with
  | _,`O o -> Some (parse_expr (`O o))
  | _ -> None in
   {var_name=name; var_type=type_; var_value=value}

and parse_func_arg o =
   let field = match get_dict_node_param "Field" o with
   |_,`O o -> parse_var o
   |_ -> raise TypeError in
   let vararg = match get_dict_node_param "Vararg" o with
   |_,`Bool b -> b
   |_ -> raise TypeError in
   {arg_field=field; arg_vararg=vararg}

and parse_func o =
  let name = match get_dict_node_param "Name" o with
  | _,`String s -> s
  | _ -> raise TypeError in
  let args = match get_dict_node_param "Args" o with
  |_, `A a -> a |> List.map (fun x -> match x with| `O o -> parse_func_arg o|_ -> raise TypeError)
  | _ -> raise TypeError in
  let body = match get_dict_node_param "Body" o with
  |_, `O o -> parse_block o
  |_ -> raise TypeError in
  {func_name=name; func_args=args; func_body=body}
and parse_decl y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    match node_type with
    | "Var" -> Var (parse_var o)
    | "Func" -> Func (parse_func o)
    | "Class" ->
      let name = match get_dict_node_param "Name" o with
       | _,`String s -> s
       | _ -> raise TypeError in
      let bases = match get_dict_node_param "Bases" o with
        | _,`A a -> a |> List.map (fun x -> match x with| `String s -> s |_ -> raise TypeError)
        | _ -> raise TypeError in
      let constractors = match get_dict_node_param "Constractors" o with
      | _, `A a -> a |> List.map (fun x -> match x with| `O o -> parse_func o|_ -> raise TypeError)
      | _ -> raise TypeError in
      let fields = match get_dict_node_param "Fields" o with
      | _, `A a -> a |> List.map parse_decl
      |_ -> raise TypeError in
      Class {class_name=name; class_bases=bases; class_constractors=constractors; class_fields=fields}
    | "Suite" ->
      let name = match get_dict_node_param "Name" o with
       | _,`String s -> s
       | _ -> raise TypeError in
      let setup = match get_dict_node_param "SetUp" o with
       | _,`A a -> a |> List.map parse_expr
       | _ -> raise TypeError in
      let cases = match get_dict_node_param "Cases" o with
      | _, `A a -> a |> List.map parse_decl |> List.map case_of_decl
      | _ -> raise TypeError in
      let tear_down = match get_dict_node_param "TearDown" o with
      | _, `A a -> a |> List.map parse_expr 
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
    |"Constant" ->
    let kind = match get_dict_node_param "Kind" o with
    | _,`String "STRING" -> String
    | _,`String "INTEGER" -> Integer
    |_ -> Null in
    let value = match get_dict_node_param "Value" o with
    |_,`String s -> s
    |_ -> raise TypeError in
      Constant { constant_kind = kind; constant_value = value}
    |"BinOp" ->
    let kind = match get_dict_node_param "Kind" o with
    |_,`String "ASSIGN" -> Assign
    |_ -> raise Not_found in
    let _,left = get_dict_node_param "Left" o in
    let left = parse_expr left in
    let _,r = get_dict_node_param "Right" o in
    let right = parse_expr r in
    BinOp {binop_left=left; binop_right=right; binop_kind=kind}
    | _ -> Constant { constant_kind = Null; constant_value = "null"}
      (* |_ -> raise_ir_parse_error "Dose not match as any expr node" y *)
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
