
full_gen:
	python main.py sample_data/string_tests.py sample_data/string_tests.json

test_gen:
	python main.py sample_data/test_sample.py sample_data/test_sample.json

run_kotlin: test_gen
	cd ./kotlin && ./gradlew run --args="../sample_data/test_sample.json"
