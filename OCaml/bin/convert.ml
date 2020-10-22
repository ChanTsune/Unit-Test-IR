include Ast_type
include Utils
open Parsetree
(* open Asttypes *)

let rec convert n:structure =
  match n with
  | File f -> file_node_to f
  | _ -> exit 1

and file_node_to n =
  n.file_body |> List.map decl_node_to

and decl_node_to n =
  match n with
  | _ -> exit 1
