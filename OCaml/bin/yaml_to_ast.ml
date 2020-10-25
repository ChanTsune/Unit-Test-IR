include Ast_type
include Utils

exception TypeError

let raise_ir_parse_error msg y =
  let s = Yaml.to_string_exn y in
  raise (Invalid_argument (msg ^ "\n" ^ s))

let case_of_decl decl = match decl with| Case c -> c |_ -> raise TypeError

let get_dict_node_param key y =
  List.find (fun x -> let (k,v) = x in
  let _ = v in
   (* print_endline (k ^"=="^ key);
   print_yaml v; *)
   k = key
   )
  y

let get_dict_node_value key y = let _,v = get_dict_node_param key y in v

let unwrap v = match v with| Some s -> s| None -> raise (Invalid_argument "optional unwrap faied.")

let string_of_yaml_value y =
  match y with
  |`String s -> Some s
  |_ -> None

let list_of_yaml_value y =
  match y with
  |`A a -> Some a
  |_ -> None

let bool_of_yaml_value y =
  match y with
  | `Bool b -> Some b
  |_ -> None

let float_of_yaml_value y =
  match y with
  | `Float f -> Some f
  | _ -> None

let object_of_yaml_value y =
  match y with
  |`O o -> Some o
  |_ -> None

let string_of_yaml_value_exn y = unwrap (string_of_yaml_value y)
let list_of_yaml_value_exn y = unwrap (list_of_yaml_value y)
let bool_of_yaml_value_exn y = unwrap (bool_of_yaml_value y)
let float_of_yaml_value_exn y = unwrap (float_of_yaml_value y)
let object_of_yaml_value_exn y = unwrap (object_of_yaml_value y)


let get_node_type y =
let node_type = get_dict_node_value "Node" y in
match node_type with
| `String s -> s
| _ -> raise Not_found

let rec parse_node (y:Yaml.value) =
  match y with
  | `O o -> begin
    let node_type = get_node_type o in
    if node_type = "File" then
      let v = get_dict_node_value "Version" o in
      let v = int_of_float (float_of_yaml_value_exn v) in
      let b = get_dict_node_value "Body" o 
      |> list_of_yaml_value_exn |> List.map parse_decl in
      File {file_version = v;file_body = b}
    else if node_type = "Block" then
      Block (parse_block o)
    else
      raise_ir_parse_error "Dose not match as file node" y
    end
  | _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as file node" y

and parse_block o =
  let body = get_dict_node_value "Body" o
  |> list_of_yaml_value_exn
  |> List.map object_of_yaml_value_exn
  |> List.map parse_stmt
  in {block_body = body}
and parse_stmt o =
    let node_type = get_node_type o in
    match node_type with
    | "Expr" ->
      let expr = get_dict_node_value "Expr" o in
      ExprStmt {expr = parse_expr expr}
    | "Decl" ->
      let decl = get_dict_node_value "Decl" o in
      DeclStmt {decl = parse_decl decl}
    | "Return" ->
      let v = get_dict_node_value "Value" o in
      Return {return_value = parse_expr v}
    | "For" ->
      let v = get_dict_node_value "Value" o |> object_of_yaml_value_exn in
      let g = get_dict_node_value "Generator" o in
      let b = get_dict_node_value "Body" o |> object_of_yaml_value_exn in
      For {for_value = parse_var v; for_generator = parse_expr g; for_body = parse_block b}
    | _ -> raise_ir_parse_error "Dose not match as any stmt node" (`O o)

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
      let name = get_dict_node_value "Name" o 
      |> string_of_yaml_value_exn 
      in
      let setup = get_dict_node_value "SetUp" o 
      |> list_of_yaml_value_exn 
      |> List.map parse_expr 
      in
      let cases = get_dict_node_value "Cases" o 
      |> list_of_yaml_value_exn 
      |> List.map parse_decl 
      |> List.map case_of_decl
      in
      let tear_down = get_dict_node_value "TearDown" o 
      |> list_of_yaml_value_exn 
      |> List.map parse_expr
      in
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

and parse_name o = 
let name = get_dict_node_value "Name" o |> string_of_yaml_value_exn in
Name {name_name=name}

and parse_call o = 
  let value = get_dict_node_value "Value" o in
  let args = get_dict_node_value "Args" o 
  |> list_of_yaml_value_exn
  |> List.map object_of_yaml_value_exn
  |> List.map parse_call_args
  in
  Call {call_value=parse_expr value;call_args=args}

and parse_call_args o =
let name = get_dict_node_value "Name" o |> string_of_yaml_value in
let value = get_dict_node_value "Value" o in
{call_arg_name= name;call_arg_value= parse_expr value}

and parse_expr y =
match y with
  | `O o -> begin
    let node_type = get_node_type o in
    match node_type with
    |"Name" -> parse_name o
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
    let kind = match get_dict_node_value "Kind" o |> string_of_yaml_value_exn with
    | "ASSIGN" -> Assign
    | "ADD" -> Add
    | "SUB" -> Sub
    | "MUL" -> Mul
    | "DIV" -> Div
    | "MOD" -> Mod
    | "DOT" -> Dot
    | "LEFT_SHIFT" -> Left_shift
    | "RIGHT_SHIFT" -> Right_shift
    | "NOT_EQUAL" -> Not_equal
    | "IN" -> In
    |_ -> raise Not_found in
    let left = get_dict_node_value "Left" o in
    let left = parse_expr left in
    let r = get_dict_node_value "Right" o in
    let right = parse_expr r in
    BinOp {binop_left=left; binop_right=right; binop_kind=kind}
    |"Call" -> parse_call o
    |"Assert" -> parse_assert o
    | x -> let _ = print_endline ("Unsuppoted expr " ^ x) in
      Constant { constant_kind = Null; constant_value = "null"}
      (* |_ -> raise_ir_parse_error "Dose not match as any expr node" y *)
   end
| _ -> raise_ir_parse_error "Invalid Yaml.value passed! Dose not match as any expr node" y

and parse_assert o =
  let k = get_dict_node_value "Kind" o
  |> object_of_yaml_value_exn in
  Assert (parse_assert_kind k)

and parse_assert_kind o =
  {assert_kind = match get_node_type o with
  | "Equal" -> 
  begin
    let e = get_dict_node_value "Excepted" o in
    let a = get_dict_node_value "Actual" o in
    let msg = get_dict_node_value "Message" o |> string_of_yaml_value in
    Equal {assert_equal_excepted=parse_expr e; assert_equal_actual=parse_expr a; assert_equal_message = msg}
  end
  | x -> exit_with ("Unsupported assert " ^ x)
}
