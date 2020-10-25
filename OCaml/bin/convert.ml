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
  let opn = make_open_declaration m_exp Fresh in
  make_structure_item (Pstr_open opn) ::
  (n.file_body |> List.map decl_node_to)

and decl_node_to n =
  match n with
  | Var v -> var_node_to v
  | Func f -> func_node_to f
  | Class c -> class_node_to c
  | Suite s -> suite_node_to s
  | Case c -> case_node_to c

and var_node_to n = let _ = n in exit_with "Var node"
and func_node_to n = let _ = n in exit_with "Func node"
and class_node_to n = let _ = n in exit_with "Class node"
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

and block_node_to n =
  let to_seqence list =
    let rec iter list expr =
      match list with
      |hd::tl -> make_expression (Pexp_sequence (expr, iter tl hd))
      |[] -> expr
    in
    match list with
    | [] -> unit_expression
    | [expr] -> expr
    | hd::tl -> iter tl hd
    in
  let lst = n.block_body |> List.map stmt_node_to in
    make_expression (Pexp_fun (Nolabel, (*expression option*) None, make_pattern Ppat_any , (to_seqence lst)))

and stmt_node_to n:expression =
match n with
| ExprStmt e -> expr_node_to e.expr
| DeclStmt _ -> exit_with "stm node"
| Return _ -> exit_with "return node"
| For _ -> exit_with "for node"
| Throw _ -> exit_with "throw node"
| Try _ -> exit_with "try node"
| Catch _ -> exit_with "catch node"

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
 
 and list_node_to n = let _ = n in exit_with "list reached!!"
and tuple_node_to n = let _ = n in exit_with "tuple reached!!"
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
  | _ -> let _ = n in exit_with "binop reached!!"
and unaryop_node_to n = let _ = n in exit_with "unaryop reached!!"
and subscript_node_to n = let _ = n in exit_with "subscript reached!!"
and call_node_to n = let _ = n in exit_with "call reached!!"

and assert_node_to n =
match n.assert_kind with
| Equal e -> assert_equal_node_to e

and assert_equal_node_to n = 
make_expression (Pexp_apply ((make_expression (Pexp_ident (make_loc (Longident.parse "assert_equal")))),[
  (Nolabel, expr_node_to n.assert_equal_actual);
  (Nolabel, expr_node_to n.assert_equal_excepted);
]))
