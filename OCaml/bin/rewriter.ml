
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
 assert_rewriter : (rewriter -> Ast_type.assert_ -> Ast_type.assert_);
 assert_equal_rewriter : (rewriter -> Ast_type.assert_equal -> Ast_type.assert_equal);
 assert_failure_rewriter : (rewriter -> Ast_type.assert_failure -> Ast_type.assert_failure);
}
let rewrite node rewriter = rewriter.node_rewriter rewriter node

let _any_rewriter rewriter any_node = let _ = rewriter in any_node

let default_rewriter = {
 node_rewriter = _any_rewriter;
 file_rewriter = _any_rewriter;
 block_rewriter = _any_rewriter;
 decl_rewriter = _any_rewriter;
 expr_rewriter = _any_rewriter;
 stmt_rewriter = _any_rewriter;
 expr_stmt_rewriter = _any_rewriter;
 decl_stmt_rewriter = _any_rewriter;
 return_rewriter = _any_rewriter;
 for_rewriter = _any_rewriter;
 throw_rewriter = _any_rewriter;
 try_rewriter = _any_rewriter;
 catch_rewriter = _any_rewriter;
 var_rewriter = _any_rewriter;
 func_rewriter = _any_rewriter;
 class_rewriter = _any_rewriter;
 suite_rewriter = _any_rewriter;
 case_rewriter = _any_rewriter;
 case_block_rewriter = _any_rewriter;
 name_rewriter = _any_rewriter;
 constant_rewriter = _any_rewriter;
 list_rewriter = _any_rewriter;
 tuple_rewriter = _any_rewriter;
 binop_rewriter = _any_rewriter;
 unaryop_rewriter = _any_rewriter;
 subscript_rewriter = _any_rewriter;
 call_rewriter = _any_rewriter;
 assert_rewriter = _any_rewriter;
 assert_equal_rewriter = _any_rewriter;
 assert_failure_rewriter = _any_rewriter;
}