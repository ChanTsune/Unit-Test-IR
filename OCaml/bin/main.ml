include Yaml_to_ast
include Utils

let convert_and_write input output =
  let () = print_endline input in
  let () = print_endline output in
  let inputFile = Fpath.(v input) in
  let outputFile = Fpath.(v output) in
  let parsed = Yaml_unix.of_file_exn inputFile in
  let a = parse_node parsed
  in
  let _ = a in let _ = outputFile in
  let ocaml_structures = Convert.structure_of_ir_node a in
  (* let _ = Ast_invariants.structure ocaml_structures in *)
  (* let () = print_ast_as_code ocaml_structures in *)
  (* let () = print_ast ocaml_structures in *)
  let str = Ocaml_common.Pprintast.string_of_structure ocaml_structures in
  let _ = Bos.OS.File.write outputFile str in
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


let main () =
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

let _ = main ()
