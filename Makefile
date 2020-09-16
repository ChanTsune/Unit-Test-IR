# INPUT=sample_data/string_tests.py
INPUT=sample_data/test_sample.py
OUTPUT=sample_data/test_sample.json

ir_gen:
	python main.py ${INPUT} ${OUTPUT}

run_kotlin: ir_gen
	cd ./kotlin && ./gradlew run --args="../${OUTPUT}"
