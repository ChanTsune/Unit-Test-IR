open OUnit2
open Mlpystring

let test_repeat = "repeat string operator" >::
 (fun _ -> assert_equal ("123" *$ 2) "123123")

let test_add_char = "add char operator" >::
  (fun _ -> assert_equal ("0" $^ '0') "00")

let test_add_string = "add string operator" >::
  (fun _ -> assert_equal ('0' ^$ "0") "00")

let tests = "operator_tests" >::: [
  test_repeat;
  test_add_char;
  test_add_string;
]
