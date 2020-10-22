open Parsetree

let print_yaml y =
  Yaml.pp Format.std_formatter y

let print_ast_as_code s =
  let str = Ocaml_common.Pprintast.string_of_structure s in
  print_endline str

let print_ast s =
  Printast.structure 0 Format.std_formatter s


let make_structure_item ?(loc=Location.none) pstr = {
  pstr_desc = pstr;
  pstr_loc = loc;
}

let make_value_binding ?(attrs=[]) ?(loc=Location.none) ptn expr = {
    pvb_pat = ptn;
    pvb_expr = expr;
    pvb_attributes = attrs;
    pvb_loc = loc;
}

let make_pattern ?(attrs=[]) ?(loc=Location.none) ?(loc_stack=[]) pat_desc = {
  ppat_desc = pat_desc;
  ppat_loc = loc;
  ppat_loc_stack = loc_stack;
  ppat_attributes = attrs;
}

let make_expression ?(attrs=[]) ?(loc=Location.none) ?(loc_stack=[]) exp_desc = {
  pexp_desc = exp_desc;
  pexp_loc = loc;
  pexp_loc_stack = loc_stack;
  pexp_attributes = attrs;
}
