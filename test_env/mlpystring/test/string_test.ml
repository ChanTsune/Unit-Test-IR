open OUnit2

let test_slice = "slice string" >::
  (fun _ -> assert_equal (Mlpystring.slice "012345" (Some 0) None (Some 2)) "024" )

let test_repeat = "repeat string" >::
 (fun _ -> assert_equal (Mlpystring.repeat "123" 2) "123123")

let test_char_of_string = "cast char to string" >::
 (fun _ -> assert_equal (Mlpystring.char_of_string '1') "1")

let test_at = "get char" >::
 (fun _ -> assert_equal (Mlpystring.at "012345" 0) '0')

let test_center = "centerlize string" >::
  (fun _ -> assert_equal (Mlpystring.center "aaa" 5) " aaa ")

(* TODO: Test *)

let test_capitalize = "capitalize" >::
 (fun _ -> assert_equal (Mlpystring.capitalize "abc") "Abc")
let test_count = "count" >::
 (fun _ -> assert_equal (Mlpystring.count "abc" "a") 1)
let test_endswith = "endswith" >::
 (fun _ -> assert_equal (Mlpystring.endswith "abc" "c") true)

let test_find = "find" >::: [
  "find empty from empty" >:: (fun _ -> assert_equal (Mlpystring.find "" "") 0);
  "find char from empty" >:: (fun _ -> assert_equal (Mlpystring.find "" "0") (-1));
  "find string from empty" >:: (fun _ -> assert_equal (Mlpystring.find "" "12") (-1));
  "find empty from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "") 0);
  "find char from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "0") 0);
  "find string from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "01") 0);
  "find string from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "23") 2);
  "find string with start from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "0" ~start:(Some 1)) 10);
  "find string with end from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "90" ~stop:(Some (-1))) (-1));
  "find string with start and end from string" >:: (fun _ -> assert_equal (Mlpystring.find "01234567890" "0" ~start:(Some 1) ~stop:(Some (-1))) (-1));
]

let test_get = "get" >::
 (fun _ -> assert_equal (Mlpystring.get "abc" 0) 'a')
let test_isalnum = "isalnum" >::
 (fun _ -> assert_equal (Mlpystring.isalnum "abc") true)
let test_isalpha = "isalpha" >::
 (fun _ -> assert_equal (Mlpystring.isalpha "abc") true)
let test_isascii = "isascii" >::
 (fun _ -> assert_equal (Mlpystring.isascii "abc") true)
let test_isdecimal = "isdecimal" >::
 (fun _ -> assert_equal (Mlpystring.isdecimal "012") true)
let test_isdigit = "isdigit" >::
 (fun _ -> assert_equal (Mlpystring.isdigit "012") true)
let test_islower = "islower" >::
 (fun _ -> assert_equal (Mlpystring.islower "abc") true)
let test_isnumeric = "isnumeric" >::
 (fun _ -> assert_equal (Mlpystring.isnumeric "012") true)
let test_isprintable = "isprintable" >::
 (fun _ -> assert_equal (Mlpystring.isprintable "21") true)
let test_isspace = "isspace" >::
 (fun _ -> assert_equal (Mlpystring.isspace " ") true)
let test_isupper = "isupper" >::
 (fun _ -> assert_equal (Mlpystring.isupper "A") true)
let test_ljust = "ljust" >::
 (fun _ -> assert_equal (Mlpystring.ljust "12" 3) "12 ")
let test_lower = "lower" >::
 (fun _ -> assert_equal (Mlpystring.lower "ABC") "abc")
let test_lstrip = "lstrip" >::
 (fun _ -> assert_equal (Mlpystring.lstrip " a") "a")
let test_join = "join" >::
 (fun _ -> assert_equal (Mlpystring.join "a" ["b";"c"]) "bac")
let test_rjust = "rjust" >::
 (fun _ -> assert_equal (Mlpystring.rjust "12" 3) " 12")
let test_rstrip = "rstrip" >::
 (fun _ -> assert_equal (Mlpystring.rstrip "12 ") "12")
let test_replace = "replace" >::
 (fun _ -> assert_equal (Mlpystring.replace "123" "2" "4") "143")
let test_split = "split" >::
 (fun _ -> assert_equal (Mlpystring.split "1,2" ",") ["1"; "2"])
let test_strip = "strip" >::
 (fun _ -> assert_equal (Mlpystring.strip " 12 ") "12")
let test_partition = "partition" >::
 (fun _ -> assert_equal (Mlpystring.partition "1,2" ",") ["1"; ","; "2"])
let test_splitlines = "splitlines" >::
 (fun _ -> assert_equal (Mlpystring.splitlines "line") ["line"])
let test_index = "index" >::
 (fun _ -> assert_equal (Mlpystring.index "0" "0") 0)

let tests = "all_tests" >::: [
  test_slice;
  test_repeat;
  test_char_of_string;
  test_at;
  test_center;
  test_capitalize;
  test_count;
  test_endswith;
  test_find;
  test_get;
  test_isalnum;
  test_isalpha;
  test_isascii;
  test_isdecimal;
  test_isdigit;
  test_islower;
  test_isnumeric;
  test_isprintable;
  test_isspace;
  test_isupper;
  test_ljust;
  test_lower;
  test_lstrip;
  test_join;
  test_rjust;
  test_rstrip;
  test_replace;
  test_split;
  test_strip;
  test_partition;
  test_splitlines;
  test_index;
]
