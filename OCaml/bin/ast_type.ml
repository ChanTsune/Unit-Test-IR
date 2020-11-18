type node = 
  File of file
| Block of block
| Decl of decl 
| Expr of expr

and file = {file_version: int; file_body: decl list}
and block = {block_body: stmt list}

and stmt =
  ExprStmt of {expr: expr}
| DeclStmt of {decl: decl}
| Return of return
| For of for_
| Throw of throw
| Try of try_
| Catch of catch

and return = {return_value: expr}
and for_ = {for_value: var; for_generator: expr; for_body: block}
and throw = {throw_value: expr}
and try_ = {try_block: block; try_catch: catch}
and catch = {catch_block: block; catch_catch: catch option}

and decl =
  Var of var
| Func of func
| Class of class_
| Suite of suite
| Case of case
and var = {var_name:string; var_type:string option; var_value: expr option}
and func = {func_name:string; func_args: arg list; func_body: block}
and arg = {arg_field: var; arg_vararg: bool}
and class_ = {class_name: string; class_bases: string list; class_constractors: func list; class_fields: decl list}
and suite = {suite_name: string; suite_set_up: expr list; suite_cases: case list; suite_tear_down: expr list}
and case = CaseBlock of case_block
and case_block = {case_block_name: string; case_block_body: block}

and expr =
  Name of name
| Constant of constant
| List of list_
| Tuple of tuple
| BinOp of binop
| UnaryOp of unaryop
| Subscript of subscript
| Call of call
| Assert of assert_

and name = {name_name: string}
and constant = {constant_kind: constant_kind; constant_value: string}
and constant_kind = String|Bytes|Integer|Float|Null|Boolean
and list_ = {list_values: expr list}
and tuple = {tuple_values: expr list}
and binop = {binop_left: expr; binop_right: expr; binop_kind: binop_kind}
and binop_kind = Dot| Assign |Add| Sub| Mul| Div| Mod| Left_shift| Right_shift| Not_equal| In
and unaryop = {unaryop_value: expr; unaryop_kind: unaryop_kind}
and unaryop_kind = Plus| Minus
and subscript = {subscript_value: expr; subscript_index: expr}
and call = {call_value: expr; call_args: call_arg list}
and call_arg = {call_arg_name: string option;call_arg_value: expr}
and assert_ = {assert_kind: assert_kind}
and assert_kind = Equal of assert_equal | Failure of assert_failure
and assert_equal = {assert_equal_expected:expr; assert_equal_actual:expr; assert_equal_message: string option}
and assert_failure = {assert_failure_error:string option; assert_failure_func:expr; assert_failure_args: expr list; assert_failure_message: string option}
