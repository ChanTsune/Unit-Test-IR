include Utils
open Ast_type

type rewriter = {
 node_rewriter : (rewriter -> Ast_type.node -> Ast_type.node);
 file_rewriter : (rewriter -> Ast_type.file -> Ast_type.file);
 block_rewriter : (rewriter -> Ast_type.block -> Ast_type.block);
 decl_rewriter : (rewriter -> Ast_type.decl -> Ast_type.decl);
 expr_rewriter : (rewriter -> Ast_type.expr -> Ast_type.expr);
 stmt_rewriter : (rewriter -> Ast_type.stmt -> Ast_type.stmt);
 expr_stmt_rewriter : (rewriter -> Ast_type.expr_stmt -> Ast_type.expr_stmt);
 decl_stmt_rewriter : (rewriter -> Ast_type.decl_stmt -> Ast_type.decl_stmt);
 return_rewriter : (rewriter -> Ast_type.return -> Ast_type.return);
 for_rewriter : (rewriter -> Ast_type.for_ -> Ast_type.for_);
 throw_rewriter : (rewriter -> Ast_type.throw -> Ast_type.throw);
 try_rewriter : (rewriter -> Ast_type.try_ -> Ast_type.try_);
 catch_rewriter : (rewriter -> Ast_type.catch -> Ast_type.catch);
 var_rewriter : (rewriter -> Ast_type.var -> Ast_type.var);
 func_rewriter : (rewriter -> Ast_type.func -> Ast_type.func);
 arg_rewriter : (rewriter -> Ast_type.arg -> Ast_type.arg);
 class_rewriter : (rewriter -> Ast_type.class_ -> Ast_type.class_);
 suite_rewriter : (rewriter -> Ast_type.suite -> Ast_type.suite);
 case_rewriter : (rewriter -> Ast_type.case -> Ast_type.case);
 case_block_rewriter : (rewriter -> Ast_type.case_block -> Ast_type.case_block);
 name_rewriter : (rewriter -> Ast_type.name -> Ast_type.name);
 constant_rewriter : (rewriter -> Ast_type.constant -> Ast_type.constant);
 list_rewriter : (rewriter -> Ast_type.list_ -> Ast_type.list_);
 tuple_rewriter : (rewriter -> Ast_type.tuple -> Ast_type.tuple);
 binop_rewriter : (rewriter -> Ast_type.binop -> Ast_type.binop);
 unaryop_rewriter : (rewriter -> Ast_type.unaryop -> Ast_type.unaryop);
 subscript_rewriter : (rewriter -> Ast_type.subscript -> Ast_type.subscript);
 call_rewriter : (rewriter -> Ast_type.call -> Ast_type.call);
 call_arg_rewriter : (rewriter -> Ast_type.call_arg -> Ast_type.call_arg);
 assert_rewriter : (rewriter -> Ast_type.assert_ -> Ast_type.assert_);
 assert_equal_rewriter : (rewriter -> Ast_type.assert_equal -> Ast_type.assert_equal);
 assert_failure_rewriter : (rewriter -> Ast_type.assert_failure -> Ast_type.assert_failure);
}
let rewrite node rewriter = rewriter.node_rewriter rewriter node

let _any_rewriter rewriter any_node = let _ = rewriter in any_node

let default_node_rewriter rw n =
  match n with
  | Ast_type.File f -> Ast_type.File (rw.file_rewriter rw f)
  | Ast_type.Block b -> Ast_type.Block (rw.block_rewriter rw b)
  | Ast_type.Decl d -> Ast_type.Decl (rw.decl_rewriter rw d)
  | Ast_type.Expr e -> Ast_type.Expr (rw.expr_rewriter rw e)

let default_file_rewriter rw n =
  { n with file_body=n.file_body |> List.map (fun x -> rw.decl_rewriter rw x)}

let default_block_rewriter rw n =
  { block_body=n.block_body |> List.map (fun x -> rw.stmt_rewriter rw x) }

let default_stmt_rewriter rw n =
  match n with
  | Ast_type.ExprStmt e -> Ast_type.ExprStmt (rw.expr_stmt_rewriter rw e)
  | Ast_type.DeclStmt d -> Ast_type.DeclStmt (rw.decl_stmt_rewriter rw d)
  | Ast_type.Return r -> Ast_type.Return (rw.return_rewriter rw r)
  | Ast_type.For f -> Ast_type.For (rw.for_rewriter rw f)
  | Ast_type.Throw t -> Ast_type.Throw (rw.throw_rewriter rw t)
  | Ast_type.Try t -> Ast_type.Try (rw.try_rewriter rw t)
  | Ast_type.Catch t -> Ast_type.Catch (rw.catch_rewriter rw t)

let default_expr_stmt_rewriter rw n =
  { expr=n.expr |> rw.expr_rewriter rw}

let default_decl_stmt_rewriter rw n =
  {decl=n.decl |> rw.decl_rewriter rw}

let default_return_rewriter rw n =
  {return_value=n.return_value |> rw.expr_rewriter rw}

let default_for_rewriter rw n =
  {
    for_value=n.for_value |> rw.var_rewriter rw;
    for_generator=n.for_generator |> rw.expr_rewriter rw;
    for_body=n.for_body |> rw.block_rewriter rw;
  }

let default_throw_rewriter rw n =
  { throw_value=n.throw_value |> rw.expr_rewriter rw; }

let default_try_rewriter rw n =
  { 
    try_block=n.try_block |> rw.block_rewriter rw;
    try_catch=n.try_catch |> rw.catch_rewriter rw;
  }

let default_catch_rewriter rw n =
  {
    catch_block=n.catch_block |> rw.block_rewriter rw;
    catch_catch=n.catch_catch |> safe_apply (fun x -> rw.catch_rewriter rw x);
  }

let default_decl_rewriter rw n =
  match n with
  | Ast_type.Var v -> Ast_type.Var (rw.var_rewriter rw v)
  | Ast_type.Func f -> Ast_type.Func (rw.func_rewriter rw f)
  | Ast_type.Class c -> Ast_type.Class (rw.class_rewriter rw c)
  | Ast_type.Suite s -> Ast_type.Suite (rw.suite_rewriter rw s)
  | Ast_type.Case c -> Ast_type.Case (rw.case_rewriter rw c)

let default_var_rewriter rw n =
  {n with var_value=n.var_value |> safe_apply (fun x -> rw.expr_rewriter rw x)}

let default_func_rewriter rw n =
  {n with
   func_args=n.func_args |> List.map (fun x -> rw.arg_rewriter rw x);
   func_body=n.func_body |> rw.block_rewriter rw;
   }

let default_arg_rewriter rw n =
  {n with arg_field=n.arg_field |> rw.var_rewriter rw}

let default_class_rewriter rw n =
  {n with
    class_constractors=n.class_constractors |> List.map (fun x -> rw.func_rewriter rw x);
    class_fields=n.class_fields |> List.map (fun x -> rw.decl_rewriter rw x);
  }

let default_suite_rewriter rw n =
  { n with
    suite_set_up=n.suite_set_up |> List.map (fun x-> rw.expr_rewriter rw x);
    suite_cases=n.suite_cases |> List.map (fun x -> rw.case_rewriter rw x);
    suite_tear_down=n.suite_tear_down |> List.map (fun x -> rw.expr_rewriter rw x);
  }

let default_case_rewriter rw n =
  match n with
  | Ast_type.CaseBlock c -> Ast_type.CaseBlock (rw.case_block_rewriter rw c)

let default_case_block_rewriter rw n =
  {n with case_block_body=n.case_block_body |> rw.block_rewriter rw}

let default_expr_rewriter rw n =
  match n with
| Ast_type.Name n -> Ast_type.Name (rw.name_rewriter rw n)
| Ast_type.Constant c -> Ast_type.Constant (rw.constant_rewriter rw c)
| Ast_type.List l -> Ast_type.List (rw.list_rewriter rw l)
| Ast_type.Tuple t -> Ast_type.Tuple (rw.tuple_rewriter rw t)
| Ast_type.BinOp b -> Ast_type.BinOp (rw.binop_rewriter rw b)
| Ast_type.UnaryOp u -> Ast_type.UnaryOp (rw.unaryop_rewriter rw u)
| Ast_type.Subscript s -> Ast_type.Subscript (rw.subscript_rewriter rw s)
| Ast_type.Call c -> Ast_type.Call (rw.call_rewriter rw c)
| Ast_type.Assert a -> Ast_type.Assert (rw.assert_rewriter rw a)

let default_name_rewriter rw n = _any_rewriter rw n

let default_constant_rewriter rw n = _any_rewriter rw n

let default_list_rewriter rw n =
  { list_values=n.list_values |> List.map (fun x->rw.expr_rewriter rw x) }

let default_tuple_rewriter rw n =
  { tuple_values=n.tuple_values |> List.map (fun x->rw.expr_rewriter rw x) }

let default_binop_rewriter rw n =
  { n with
    binop_left=n.binop_left |> rw.expr_rewriter rw;
    binop_right=n.binop_right |> rw.expr_rewriter rw;
  }

let default_unaryop_rewriter rw n =
  { n with unaryop_value=n.unaryop_value |> rw.expr_rewriter rw; }

let default_subscript_rewriter rw n =
  { 
    subscript_value=n.subscript_value |> rw.expr_rewriter rw;
    subscript_index=n.subscript_index |> rw.expr_rewriter rw;
  }

let default_call_rewriter rw n =
  {
    call_value=n.call_value |> rw.expr_rewriter rw;
    call_args=n.call_args |> List.map (fun x -> rw.call_arg_rewriter rw x);
  }

let default_call_arg_rewriter rw n =
  { n with call_arg_value=n.call_arg_value |> rw.expr_rewriter rw}


let default_assert_rewriter rw n =
  {
    assert_kind=match n.assert_kind with
  | Ast_type.Equal a -> Ast_type.Equal (rw.assert_equal_rewriter rw a)
  | Ast_type.Failure a -> Ast_type.Failure (rw.assert_failure_rewriter rw a)
}
  
let default_assert_equal_rewriter rw n =
  {n with
   assert_equal_expected=n.assert_equal_expected |> rw.expr_rewriter rw;
   assert_equal_actual=n.assert_equal_actual |> rw.expr_rewriter rw;
  }

let default_assert_failure_rewriter rw n =
  { n with
    assert_failure_func=n.assert_failure_func |> rw.expr_rewriter rw;
    assert_failure_args=n.assert_failure_args |> List.map (fun x -> rw.expr_rewriter rw x);
  }

let default_rewriter = {
 node_rewriter = default_node_rewriter;
 file_rewriter = default_file_rewriter;
 block_rewriter = default_block_rewriter;
 decl_rewriter = default_decl_rewriter;
 expr_rewriter = default_expr_rewriter;
 stmt_rewriter = default_stmt_rewriter;
 expr_stmt_rewriter = default_expr_stmt_rewriter;
 decl_stmt_rewriter = default_decl_stmt_rewriter;
 return_rewriter = default_return_rewriter;
 for_rewriter = default_for_rewriter;
 throw_rewriter = default_throw_rewriter;
 try_rewriter = default_try_rewriter;
 catch_rewriter = default_catch_rewriter;
 var_rewriter = default_var_rewriter;
 func_rewriter = default_func_rewriter;
 arg_rewriter = default_arg_rewriter;
 class_rewriter = default_class_rewriter;
 suite_rewriter = default_suite_rewriter;
 case_rewriter = default_case_rewriter;
 case_block_rewriter = default_case_block_rewriter;
 name_rewriter = default_name_rewriter;
 constant_rewriter = default_constant_rewriter;
 list_rewriter = default_list_rewriter;
 tuple_rewriter = default_tuple_rewriter;
 binop_rewriter = default_binop_rewriter;
 unaryop_rewriter = default_unaryop_rewriter;
 subscript_rewriter = default_subscript_rewriter;
 call_rewriter = default_call_rewriter;
 call_arg_rewriter = default_call_arg_rewriter;
 assert_rewriter = default_assert_rewriter;
 assert_equal_rewriter = default_assert_equal_rewriter;
 assert_failure_rewriter = default_assert_failure_rewriter;
}
