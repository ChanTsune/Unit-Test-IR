include Ast_type
include Utils
open Parsetree
open Asttypes

let rec convert n:structure =
  match n with
  | File f -> file_node_to f
  | _ -> exit 1

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

and var_node_to n = let _ = n in exit 1
and func_node_to n = let _ = n in exit 1
and class_node_to n = let _ = n in exit 1
and suite_node_to n =
let _ = n in
let case_names = n.suite_cases |> List.map (fun x -> match x with| CaseBlock c -> c.case_block_name) in
let _ = case_names in
  make_structure_item (Pstr_value (Nonrecursive, []))
and case_node_to n =
match n with
| CaseBlock _ -> exit 1
