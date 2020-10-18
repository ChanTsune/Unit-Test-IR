include Ast_type

let parse y =
match y with
  | `Null -> Constant { constant_kind = Null; constant_value = "null"}
  | `String s -> Constant {constant_kind = String; constant_value = s}
  | `Bool b -> Constant {constant_kind = Boolean; constant_value = string_of_bool b}
  | `Float f -> Constant {constant_kind = Float; constant_value = string_of_float f}
  | `O o -> begin 
    if List.exists (fun x -> let (k,_) = x in k = "Node") o then
      Constant { constant_kind = Null; constant_value = "null"}
    else
      Constant { constant_kind = Null; constant_value = "null"}
    end
  | `A _ -> exit 2

  let convert_and_write input output =
  let () = print_endline input in
  let () = print_endline output in
  let inputFile = Fpath.(v input) in
  let outputFile = Fpath.(v output) in
  let parsed = Yaml_unix.of_file_exn inputFile in
  let a = parse parsed
  in
  let _ = a in
  let () = Yaml.pp Format.std_formatter parsed in
  let _ = Bos.OS.File.write outputFile "" in 
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
