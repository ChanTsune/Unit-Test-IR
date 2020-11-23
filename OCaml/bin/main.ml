include Yaml_to_ast
include Ast_type
include Utils

let method_call_to_function_call_rewriter =
  { Rewriter.default_rewriter with
    call_rewriter = (fun rw c ->
    match c with
    | {call_value=BinOp {binop_left=Constant {constant_kind=String;constant_value=_} as l;binop_kind=Dot;binop_right=r}; call_args=args}
     -> {call_value=r|> rw.expr_rewriter rw; call_args={call_arg_name=None;call_arg_value=l}::args |> List.map (fun x -> rw.call_arg_rewriter rw x)}
    | _ -> c
    )
  }

let read_ir_yaml input = 
  let inputFile = Fpath.(v input) in
  let raw_yaml = Yaml_unix.of_file_exn inputFile in
  parse_node raw_yaml

let write_ocaml_file output structures =
  let outputFile = Fpath.(v output) in
  let str = Pprintast.string_of_structure structures in
  Bos.OS.File.write outputFile str


let convert_and_write input output =
  let () = print_endline input in
  let () = print_endline output in
  let ir_node = read_ir_yaml input in
  let ir_node = Rewriter.rewrite ir_node method_call_to_function_call_rewriter
  in
  let _ = ir_node in
  let ocaml_structures = Convert.structure_of_ir_node ir_node in
  (* let _ = Ast_invariants.structure ocaml_structures in *)
  (* let () = print_ast_as_code ocaml_structures in *)
  (* let () = print_ast ocaml_structures in *)
  let _ = write_ocaml_file output ocaml_structures in
  ()


let main argc argv =
  if argc < 3 then
    exit_with "too few arguments. must be bigger than 2"
  else
    begin
      let input = (Array.get argv 1) in
      let output = (Array.get argv 2) in
      convert_and_write input output
    end

let () = main (Array.length Sys.argv) Sys.argv


(* let main () =
  let s = Compile_common.parse_impl {
  source_file = "/Users/tsunekwataiki/Documents/GitHub/mlpystring/test/test.ml";
  module_name = "My_Module";
  output_prefix = "prefix_";
  env = Env.empty;
  ppf_dump = Format.std_formatter;
  tool_name = "my_tool";
  native = false;
  }
  in
  (* Ocaml_common.Ast_helper.lid *)
  let _ = print_ast s in
  let _ = List.iter (fun _ -> ()) s in
  print_ast_as_code s

let _ = main () *)
