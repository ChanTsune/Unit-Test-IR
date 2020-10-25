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
  let () = print_ast_as_code ocaml_structures in
  let () = print_ast ocaml_structures in
  let str = Ocaml_common.Pprintast.string_of_structure ocaml_structures in
  let _ = Bos.OS.File.write outputFile str in
  ()


let main argc argv =
  if argc < 3 then
    exit 1
  else
    begin
      let input = (Array.get argv 1) in
      let output = (Array.get argv 2) in
      convert_and_write input output
    end

let () = main (Array.length Sys.argv) Sys.argv



