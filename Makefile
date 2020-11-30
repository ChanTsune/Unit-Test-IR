# INPUT=sample_data/string_tests.py
INPUT=sample_data/test_sample.py
OUTPUT=sample_data/test_sample.yaml

ir_gen:
	cd python && python main.py ../${INPUT} ../${OUTPUT}

run_kotlin_only:
	cd ./kotlin && ./gradlew run --args="-i ../${OUTPUT} -o ../sample_data/test_sample.kt"

run_kotlin: ir_gen run_kotlin_only

run_swift_only:
	cd ./swift && swift run utir-swift -i ../${OUTPUT} -o ../sample_data/test_string.swift

run_swift: ir_gen run_swift_only

run_ocaml_only:
	cd ./OCaml && dune exec utir -- -i ../${OUTPUT} -o ../sample_data/test_string.ml

run_ocaml: ir_gen run_ocaml_only

run: ir_gen run_kotlin_only run_swift_only run_ocaml_only
