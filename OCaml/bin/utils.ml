open Parsetree
open Asttypes

let print_yaml y =
  Yaml.pp Format.std_formatter y

let print_ast_as_code s =
  let str = Pprintast.string_of_structure s in
  print_endline str

let print_ast s =
  Printast.structure 0 Format.std_formatter s

let exit_with msg = print_endline msg ;exit 1

let make_loc ?(loc=Location.none) txt = {
  txt=txt;
  loc=loc
}

let make_structure_item ?(loc=Location.none) pstr = {
  pstr_desc = pstr;
  pstr_loc = loc;
}

let make_module_binding ?(attrs=[]) ?(loc=Location.none) ?(name={ txt = ""; loc = Location.none; }) module_expr =
    {
     pmb_name=name;
     pmb_expr = module_expr;
     pmb_attributes=attrs;
     pmb_loc=loc;
    }

let make_module_expr ?(attrs=[]) ?(loc=Location.none) mod_desc = {
  pmod_desc = mod_desc;
  pmod_loc =loc;
  pmod_attributes = attrs;
}

let make_value_binding ?(attrs=[]) ?(loc=Location.none) ptn expr = {
    pvb_pat = ptn;
    pvb_expr = expr;
    pvb_attributes = attrs;
    pvb_loc = loc;
}

let make_list_expression expr_desc_list =
  let expr_desc_list = expr_desc_list |> List.rev in
  let join = make_loc (Longident.parse "::") in
  let braket = (Pexp_construct ((make_loc (Longident.parse "[]")), None)) in

  let rec iter list result =
    match list with
    | hd::tl -> iter tl (
      Pexp_construct (
        join,
        Some (Ast_helper.Exp.tuple [
                  Ast_helper.Exp.mk hd;
                  Ast_helper.Exp.mk result;
            ]
          )
        )
      )
    |[]-> result
  in
  let list = iter expr_desc_list braket in
  Ast_helper.Exp.mk list

let unit_expression = Ast_helper.Exp.construct (make_loc (Longident.parse "()")) None

let unwrap v = match v with| Some s -> s| None -> raise (Invalid_argument "optional unwrap faied.")
