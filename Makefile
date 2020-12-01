PYTHON_SOURCE=sample_data/string_tests.py
IR_DIST=sample_data/test_sample.yaml
OCAML_DIST=test_env/mlpystring/test/AutoGenerate.ml
KOTLIN_DIST=test_env/ktPyString/src/test/kotlin/ktPyString/AutoGenerate.kt
SWIFT_DIST=test_env/SwiftyPyString/Tests/SwiftyPyStringTests/AutoGenerate.swift

ir_gen:
	cd python && python main.py ../${PYTHON_SOURCE} ../${IR_DIST}

run_kotlin_only:
	cd ./kotlin && ./gradlew run --args="-i ../${IR_DIST} -o ../${KOTLIN_DIST}"

run_kotlin: ir_gen run_kotlin_only

run_swift_only:
	cd ./swift && swift run utir-swift -i ../${IR_DIST} -o ../${SWIFT_DIST}

run_swift: ir_gen run_swift_only

run_ocaml_only:
	cd ./OCaml && dune exec utir -- -i ../${IR_DIST} -o ../${OCAML_DIST}

run_ocaml: ir_gen run_ocaml_only

run: ir_gen run_kotlin_only run_swift_only run_ocaml_only


world:
	docker-compose build
	cd test_env/ktPyString && docker-compose build
	cd test_env/SwiftyPyString && docker-compose build
	cd test_env/mlpystring && docker-compose build
