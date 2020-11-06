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
  let m = Pmod_ident (make_loc x) in
  let m_exp = make_module_expr m in
  let opn = Ast_helper.Opn.mk m_exp in
  make_structure_item (Pstr_open opn) ::
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
  make_structure_item (Pstr_value (Nonrecursive, [
    make_value_binding (Ast_helper.Pat.var (make_loc n.var_name)) (expr_node_to value)
  ]))
and func_node_to n =
  let _ = n in
  let _ = print_endline "Func node skipped!!" in
  make_structure_item (Pstr_value (Nonrecursive, []))
and class_node_to n =
let _ = n in
let _ = print_endline "Class node skipped!!" in
make_structure_item (Pstr_class [])

and suite_node_to n =
  let expr_desc_list = n.suite_cases
   |> List.map case_node_to_value_binding
   |> List.map (fun x -> x.pvb_expr)
   |> List.map (fun x -> x.pexp_desc)
    in

  let ident = make_expression (Pexp_ident (make_loc (Longident.parse ">:::"))) in
  let suite_expr = make_expression (Pexp_apply (ident, [
    (Nolabel, (make_expression (Pexp_constant (Pconst_string (n.suite_name, None)))));
    (Nolabel, (make_list_expression expr_desc_list));
  ])) in
  make_structure_item (Pstr_value (Nonrecursive, [
    make_value_binding (make_pattern (Ppat_var (make_loc (n.suite_name |> String.uncapitalize_ascii)))) suite_expr;
  ]))

  and case_node_to n =
match n with
| CaseBlock _ -> exit_with "case node"

and case_node_to_value_binding n =
  match n with
  | CaseBlock c -> case_block_node_to c

and case_block_node_to n =
  let ident = make_expression (Pexp_ident (make_loc (Longident.parse ">::"))) in
  let case_expr = make_expression (Pexp_apply (ident, [
    (Nolabel, (make_expression (Pexp_constant (Pconst_string (n.case_block_name, None)))));
    (Nolabel, (block_node_to n.case_block_body));
  ])) in
  make_value_binding (make_pattern (Ppat_var (make_loc n.case_block_name))) case_expr

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
                      | _ -> make_expression (Pexp_sequence (expr, iter tl hd))
                  end
      |[] -> expr
    in
    match list with
    | [] -> unit_expression
    | [expr] -> expr
    | hd::tl -> iter tl hd
    in
  let lst = n.block_body |> List.map stmt_node_to in
    make_expression (Pexp_fun (Nolabel, (*expression option*) None, pattern , (to_seqence lst)))

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
|Pstr_value (rec_flag, vblist)-> 
make_expression (Pexp_let (rec_flag, vblist, make_expression Pexp_unreachable))
|Pstr_class _ -> 
let () = print_endline "Unsupported class decl found in stmt." in
 (Ast_helper.Exp.constant (Ast_helper.Const.string (Pprintast.string_of_structure [decl])))
| _ -> exit_with "unsupported decl in stmt!"



and for_node_to n =
let v = Ast_helper.Pat.var (make_loc n.for_value.var_name) in
Ast_helper.Exp.apply (Ast_helper.Exp.ident (make_loc (Longident.parse "List.iter"))) [
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

and name_node_to n = make_expression (Pexp_ident (make_loc (Longident.parse n.name_name)))
and constant_node_to n =
match n.constant_kind with
| String
| Bytes -> make_expression (Pexp_constant (Pconst_string (n.constant_value, None)))
| Integer ->
 make_expression (Pexp_constant (Pconst_integer (n.constant_value, None)))
| Float -> let _ = print_endline ("const " ^ n.constant_value ^ "reached!!") in
 make_expression (Pexp_constant (Pconst_float (n.constant_value, None)))
| Null -> make_expression (Pexp_construct (make_loc (Longident.parse "None"), None))
| Boolean ->
  let _ = print_endline ("const " ^ n.constant_value ^ "reached!!") in
 make_expression (Pexp_constant (Pconst_integer (n.constant_value, None)))
 
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
    make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse ":=")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Add ->
    make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "+")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Sub ->
    make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "-")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Dot -> 
      let name = match n.binop_right with
      |Name n -> n.name_name
      | _ -> raise (Invalid_argument "BinOp right node must be a Name node!") in
      Ast_helper.Exp.send (expr_node_to n.binop_left) (make_loc name)
  | Mul -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "*")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Div -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "/")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Mod -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "mod")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Left_shift -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "lsl")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Right_shift -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "lsr")))), [ (* TODO: asr 算術シフト・論理シフトの区別 *)
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | Not_equal -> make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "<>")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))
  | In ->
      make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "List.mem")))), [
      (Nolabel, expr_node_to n.binop_left);
      (Nolabel, expr_node_to n.binop_right);
    ]))

and unaryop_node_to n = match n.unaryop_kind with
| Minus -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (make_loc (Longident.parse "-"))) [ (* TODO: ~- *)
  (Nolabel, (expr_node_to n.unaryop_value))
]
| Plus -> Ast_helper.Exp.apply (Ast_helper.Exp.ident (make_loc (Longident.parse "+"))) [ (* TODO: ~+ *)
  (Nolabel, (expr_node_to n.unaryop_value))
]
and subscript_node_to n =
Ast_helper.Exp.apply (Ast_helper.Exp.ident (make_loc (Longident.parse "List.nth"))) [
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
make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "assert_equal")))),[
  (Nolabel, expr_node_to n.assert_equal_actual);
  (Nolabel, expr_node_to n.assert_equal_excepted);
]))

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
let args = opt_args @ [(Nolabel, Ast_helper.Exp.construct (make_loc (Longident.parse e)) None); (Nolabel, arg_f_call)] in
Ast_helper.Exp.apply ( Ast_helper.Exp.ident (make_loc (Longident.parse "assert_raises"))) args

(* assert_raises ?msg="" (fun () -> f_call ) *)