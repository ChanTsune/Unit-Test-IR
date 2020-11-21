include Ast_type
include Utils
open Parsetree
open Asttypes

let rec structure_of_ir_node n:structure =
  match n with
  | File f -> file_node_to f
  | _ -> exit_with "structure_of_ir_node"

and file_node_to n =
  let x = Longident.parse "Ounit2" in
  let m_exp = Ast_helper.Mod.ident (Location.mknoloc x) in
  let opn = Ast_helper.Opn.mk m_exp in
  Ast_helper.Str.open_ opn ::
  (n.file_body |> List.map decl_node_to)

and decl_node_to n =
  match n with
  | Var v -> var_node_to v
  | Func f -> func_node_to f
  | Class c -> class_node_to c
  | Suite s -> suite_node_to s
  | Case c -> case_node_to c

and var_node_to n =
  let value = unwrap n.var_value in
  Ast_helper.Str.value Nonrecursive [
    Ast_helper.Vb.mk (Ast_helper.Pat.var (Location.mknoloc n.var_name)) (expr_node_to value)
  ]
and func_node_to n =
  let _ = n in
  let _ = print_endline "Func node skipped!!" in
  Ast_helper.Str.value Nonrecursive [

  ]
and class_node_to n =
let _ = n in
let _ = print_endline "Class node skipped!!" in
Ast_helper.Str.class_ [

]

and suite_node_to n =
  let expr_desc_list = n.suite_cases
   |> List.map case_node_to_value_binding
   |> List.map (fun x -> x.pvb_expr)
   |> List.map (fun x -> x.pexp_desc)
    in
  let ident = Ast_helper.Exp.ident (Location.mknoloc (Longident.parse ">:::")) in
  let suite_expr = Ast_helper.Exp.apply ident [
    (Nolabel, (Ast_helper.Exp.constant (Ast_helper.Const.string n.suite_name)));
    (Nolabel, (make_list_expression expr_desc_list));
  ] in
  Ast_helper.Str.value Nonrecursive [
    Ast_helper.Vb.mk (Ast_helper.Pat.var (Location.mknoloc (n.suite_name |> String.uncapitalize_ascii))) suite_expr;
  ]

  and case_node_to n =
match n with
| CaseBlock _ -> exit_with "case node"

and case_node_to_value_binding n =
  match n with
  | CaseBlock c -> case_block_node_to c

and case_block_node_to n =
  let ident = Ast_helper.Exp.ident (Location.mknoloc (Longident.parse ">::")) in
  let case_expr = Ast_helper.Exp.apply ident [
    (Nolabel, (Ast_helper.Exp.constant (Ast_helper.Const.string n.case_block_name)));
    (Nolabel, (block_node_to n.case_block_body));
  ] in
  Ast_helper.Vb.mk (Ast_helper.Pat.var (Location.mknoloc n.case_block_name)) case_expr

and block_node_to ?(pattern=Ast_helper.Pat.any ()) n =
  let to_seqence list =
    let rec iter list expr =
      match list with
      |hd::tl -> begin match expr with
                      | {
                        pexp_desc = Pexp_let (rec_flag , value_binding_list , {pexp_desc = Pexp_unreachable;pexp_loc = _;pexp_loc_stack = _;pexp_attributes = _;});
                        pexp_loc = loc;
                        pexp_loc_stack = loc_stack;
                        pexp_attributes = attributes;
                        } -> {
                        pexp_desc = Pexp_let (rec_flag , value_binding_list , iter tl hd);
                        pexp_loc = loc;
                        pexp_loc_stack = loc_stack;
                        pexp_attributes = attributes;
                        }
                      | _ -> Ast_helper.Exp.sequence expr (iter tl hd)
                  end
      |[] -> expr
    in
    match list with
    | [] -> unit_expression
    | [expr] -> expr
    | hd::tl -> iter tl hd
    in
  let lst = n.block_body |> List.map stmt_node_to in
    Ast_helper.Exp.fun_ Nolabel (*expression option*) None pattern (to_seqence lst)

and stmt_node_to n:expression =
match n with
| ExprStmt e -> expr_node_to e.expr
| DeclStmt d -> decl_node_as_expr d.decl
| Return r -> return_node_to r
| For f -> for_node_to f
| Throw _ -> exit_with "throw node"
| Try _ -> exit_with "try node"
| Catch _ -> exit_with "catch node"


and decl_node_as_expr n =
let decl = decl_node_to n in
match decl with
| {pstr_desc = pstr;pstr_loc = _;} -> match pstr with
| Pstr_value (rec_flag, vblist) ->
  Ast_helper.Exp.let_ rec_flag vblist (Ast_helper.Exp.unreachable ())
| Pstr_class _ ->
let () = print_endline "Unsupported class decl found in stmt." in
 (Ast_helper.Exp.constant (Ast_helper.Const.string (Pprintast.string_of_structure [decl])))
| _ -> exit_with "unsupported decl in stmt!"



and for_node_to n =
let v = Ast_helper.Pat.var (Location.mknoloc n.for_value.var_name) in
Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "List.iter"))) [
  (Nolabel, block_node_to ~pattern:v n.for_body);
  (Nolabel, expr_node_to n.for_generator);
]

and return_node_to n =
let _ = n in
let _ = print_endline "return node skipped!!" in
expr_node_to n.return_value

and expr_node_to n =
match n with
| Name n -> name_node_to n
| Constant c -> constant_node_to c
| List l -> list_node_to l
| Tuple t -> tuple_node_to t
| BinOp b -> binop_node_to b
| UnaryOp u -> unaryop_node_to u
| Subscript s -> subscript_node_to s
| Call c -> call_node_to c
| Assert a -> assert_node_to a

and name_node_to n = Ast_helper.Exp.ident (Location.mknoloc (Longident.parse n.name_name))
and constant_node_to n =
match n.constant_kind with
| String
| Bytes -> Ast_helper.Exp.constant (Ast_helper.Const.string n.constant_value)
| Integer -> Ast_helper.Exp.constant (Ast_helper.Const.integer n.constant_value)
| Float -> Ast_helper.Exp.constant (Ast_helper.Const.float n.constant_value)
| Null -> Ast_helper.Exp.construct (Location.mknoloc (Longident.parse "None")) None
| Boolean -> Ast_helper.Exp.constant (Pconst_integer (n.constant_value, None)) (* TODO: bool *)

and list_node_to n =
  let exp_desc_list = n.list_values 
  |> List.map expr_node_to 
  |> List.map (fun x -> x.pexp_desc)
  in
 make_list_expression exp_desc_list
and tuple_node_to n =
  let exp_desc_list = n.tuple_values
  |> List.map expr_node_to in
  Ast_helper.Exp.tuple exp_desc_list

and binop_node_to n =
  match n.binop_kind with
  | Assign ->
    Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse ":="))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Add ->
    Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "+"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Sub ->
    Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "-"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Dot -> 
      let name = match n.binop_right with
      |Name n -> n.name_name
      | _ -> raise (Invalid_argument "BinOp right node must be a Name node!") in
      Ast_helper.Exp.send (expr_node_to n.binop_left) (Location.mknoloc name)
  | Mul -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "*"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Div -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "/"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Mod -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "mod"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Left_shift -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "lsl"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Right_shift -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "lsr"))) [ (* TODO: asr 算術シフト・論理シフトの区別 *)
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | Not_equal -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "<>"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]
  | In ->
      Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "List.mem"))) [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]

and unaryop_node_to n =
match n.unaryop_value with
| Constant {constant_kind=Integer; constant_value=x}
 ->
  begin
  match n.unaryop_kind with
  | Minus -> constant_node_to {constant_kind=Integer; constant_value="-"^x}
  | Plus -> constant_node_to {constant_kind=Integer; constant_value="+"^x}
  end
| Constant {constant_kind=Float; constant_value=x}
->
  begin
    match n.unaryop_kind with
    | Minus -> constant_node_to {constant_kind=Float; constant_value="-"^x}
    | Plus -> constant_node_to {constant_kind=Float; constant_value="+"^x}
  end
| _ ->
begin match n.unaryop_kind with
| Minus -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "-"))) [
  (Nolabel, (expr_node_to n.unaryop_value))
]
| Plus -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "+"))) [
  (Nolabel, (expr_node_to n.unaryop_value))
]
end
and subscript_node_to n =
Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "List.nth"))) [
  (Nolabel, expr_node_to n.subscript_value);
  (Nolabel, expr_node_to n.subscript_index);
]

and call_node_to n =
Ast_helper.Exp.apply (expr_node_to n.call_value) (List.map call_arg_node_to n.call_args)

and call_arg_node_to n = 
let lab = match n.call_arg_name with
| Some a -> Labelled a
| None -> Nolabel in
let exp = expr_node_to n.call_arg_value in
lab, exp

and assert_node_to n =
match n.assert_kind with
| Equal e -> assert_equal_node_to e
| Failure f -> assert_failure_node_to f

and assert_equal_node_to n =
Ast_helper.Exp.apply (Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "assert_equal"))) [
  (Nolabel, expr_node_to n.assert_equal_actual);
  (Nolabel, expr_node_to n.assert_equal_expected);
]

and assert_failure_node_to n =
let e = match n.assert_failure_error with | Some s -> s| None -> "AnyError" in
let args = n.assert_failure_args |> List.map expr_node_to |> List.map (fun x -> (Nolabel, x)) in
let fnc = n.assert_failure_func |> expr_node_to in
let f_call = Ast_helper.Exp.apply fnc args in
let arg_f_call = Ast_helper.Exp.fun_ Nolabel None (Ast_helper.Pat.any ()) f_call in
let opt_args =
match n.assert_failure_message with
| Some s -> [(Optional "msg" , Ast_helper.Exp.constant (Ast_helper.Const.string s))]
| None -> []
in
(* let _ =  in *)
let args = opt_args @ [(Nolabel, Ast_helper.Exp.construct (Location.mknoloc (Longident.parse e)) None); (Nolabel, arg_f_call)] in
Ast_helper.Exp.apply ( Ast_helper.Exp.ident (Location.mknoloc (Longident.parse "assert_raises"))) args

(* assert_raises ?msg="" (fun () -> f_call ) *)