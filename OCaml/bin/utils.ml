let print_yaml y =
  Yaml.pp Format.std_formatter y

let print_ast_as_code s =
  let str = Pprintast.string_of_structure s in
  print_endline str

let print_ast s =
  Printast.structure 0 Format.std_formatter s

let exit_with msg = print_endline msg ;exit 1

let make_list_expression expr_list =
  let expr_desc_list = expr_list |> List.rev in
  let join = Location.mknoloc (Longident.parse "::") in
  let braket = Ast_helper.Exp.construct (Location.mknoloc (Longident.parse "[]")) None in

  let rec iter list result =
    match list with
    | hd::tl ->
       iter tl (Ast_helper.Exp.construct 
        join
        (Some (Ast_helper.Exp.tuple [
                  hd;
                  result;
            ]))
      )
    | [] -> result
  in
  iter expr_desc_list braket

let unit_expression = Ast_helper.Exp.construct (Location.mknoloc (Longident.parse "()")) None

let unwrap v = match v with| Some s -> s| None -> raise (Invalid_argument "optional unwrap faied.")
let safe_apply f v = match v with| Some s -> Some (f s) | None -> None
