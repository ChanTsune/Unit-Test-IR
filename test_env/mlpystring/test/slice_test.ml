open OUnit2

let test_adjust_index = "adjust index for slice" >::
(fun _ -> 
  assert_equal 
    (Mlpystring.adjust_index None None (Some 1) 20)
    (0, 20, 1, 20)
)

let tests = "slice_tests" >::: [
  test_adjust_index;
]
