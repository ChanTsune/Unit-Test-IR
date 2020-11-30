open OUnit2

let suite = "suite" >::: [
    String_test.tests;
    Operator_test.tests;
    Slice_test.tests;
  ]

let () = run_test_tt_main suite;;
