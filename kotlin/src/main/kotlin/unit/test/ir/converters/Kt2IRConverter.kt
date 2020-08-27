package unit.test.ir.converters
//
//import Unit.Test.IR.ast.node.File
//import kastree.ast.Node as KNode
//import Unit.Test.IR.ast.node.Node
//
//
//open class Kt2IRConverter {
//
//    open fun <T: KNode?> visit(v: T, parent: KNode): Node? = v.run {
//                when (this) {
//                    is KNode.File -> File(
//                        // anns <- Anotations
//                        // pkg <- package
//                        // imports <- import directiv
//                        body=visitChildren(decls)
//                    )
//                    is KNode.Script -> File(
////                        anns = visitChildren(anns),
////                        pkg = visitChildren(pkg),
////                        imports = visitChildren(imports),
////                        exprs
//                        body = visitChildren(exprs)
//                    )
//                    is KNode.Package -> null
////                        copy(
////                        mods = visitChildren(mods)
////                    )
//                    is KNode.Import -> null
////                    is KNode.Decl.Structured -> copy(
////                        mods = visitChildren(mods),
////                        typeParams = visitChildren(typeParams),
////                        primaryConstructor = visitChildren(primaryConstructor),
////                        parentAnns = visitChildren(parentAnns),
////                        parents = visitChildren(parents),
////                        typeConstraints = visitChildren(typeConstraints),
////                        members = visitChildren(members)
////                    )
////                    is KNode.Decl.Structured.Parent.CallConstructor -> copy(
////                        type = visitChildren(type),
////                        typeArgs = visitChildren(typeArgs),
////                        args = visitChildren(args),
////                        lambda = visitChildren(lambda)
////                    )
////                    is KNode.Decl.Structured.Parent.Type -> copy(
////                        type = visitChildren(type),
////                        by = visitChildren(by)
////                    )
////                    is KNode.Decl.Structured.PrimaryConstructor -> copy(
////                        mods = visitChildren(mods),
////                        params = visitChildren(params)
////                    )
////                    is KNode.Decl.Init -> copy(
////                        block = visitChildren(block)
////                    )
////                    is KNode.Decl.Func -> copy(
////                        mods = visitChildren(mods),
////                        typeParams = visitChildren(typeParams),
////                        receiverType = visitChildren(receiverType),
////                        paramTypeParams = visitChildren(paramTypeParams),
////                        params = visitChildren(params),
////                        type = visitChildren(type),
////                        typeConstraints = visitChildren(typeConstraints),
////                        body = visitChildren(body)
////                    )
////                    is KNode.Decl.Func.Param -> copy(
////                        mods = visitChildren(mods),
////                        type = visitChildren(type),
////                        default = visitChildren(default)
////                    )
////                    is KNode.Decl.Func.Body.Block -> copy(
////                        block = visitChildren(block)
////                    )
////                    is KNode.Decl.Func.Body.Expr -> copy(
////                        expr = visitChildren(expr)
////                    )
////                    is KNode.Decl.Property -> copy(
////                        mods = visitChildren(mods),
////                        typeParams = visitChildren(typeParams),
////                        receiverType = visitChildren(receiverType),
////                        vars = visitChildren(vars),
////                        typeConstraints = visitChildren(typeConstraints),
////                        expr = visitChildren(expr),
////                        accessors = visitChildren(accessors)
////                    )
////                    is KNode.Decl.Property.Var -> copy(
////                        type = visitChildren(type)
////                    )
////                    is KNode.Decl.Property.Accessors -> copy(
////                        first = visitChildren(first),
////                        second = visitChildren(second)
////                    )
////                    is KNode.Decl.Property.Accessor.Get -> copy(
////                        mods = visitChildren(mods),
////                        type = visitChildren(type),
////                        body = visitChildren(body)
////                    )
////                    is KNode.Decl.Property.Accessor.Set -> copy(
////                        mods = visitChildren(mods),
////                        paramMods = visitChildren(paramMods),
////                        paramType = visitChildren(paramType),
////                        body = visitChildren(body)
////                    )
////                    is KNode.Decl.TypeAlias -> copy(
////                        mods = visitChildren(mods),
////                        typeParams = visitChildren(typeParams),
////                        type = visitChildren(type)
////                    )
////                    is KNode.Decl.Constructor -> copy(
////                        mods = visitChildren(mods),
////                        params = visitChildren(params),
////                        delegationCall = visitChildren(delegationCall),
////                        block = visitChildren(block)
////                    )
////                    is KNode.Decl.Constructor.DelegationCall -> copy(
////                        args = visitChildren(args)
////                    )
////                    is KNode.Decl.EnumEntry -> copy(
////                        mods = visitChildren(mods),
////                        args = visitChildren(args),
////                        members = visitChildren(members)
////                    )
////                    is KNode.TypeParam -> copy(
////                        mods = visitChildren(mods),
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeConstraint -> copy(
////                        anns = visitChildren(anns),
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeRef.Paren -> copy(
////                        mods = visitChildren(mods),
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeRef.Func -> copy(
////                        receiverType = visitChildren(receiverType),
////                        params = visitChildren(params),
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeRef.Func.Param -> copy(
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeRef.Simple -> copy(
////                        pieces = visitChildren(pieces)
////                    )
////                    is KNode.TypeRef.Simple.Piece -> copy(
////                        typeParams = visitChildren(typeParams)
////                    )
////                    is KNode.TypeRef.Nullable -> copy(
////                        type = visitChildren(type)
////                    )
////                    is KNode.TypeRef.Dynamic -> this
////                    is KNode.Type -> copy(
////                        mods = visitChildren(mods),
////                        ref = visitChildren(ref)
////                    )
////                    is KNode.ValueArg -> copy(
////                        expr = visitChildren(expr)
////                    )
//                    is KNode.Expr.If -> copy(
//                        expr = visitChildren(expr),
//                        body = visitChildren(body),
//                        elseBody = visitChildren(elseBody)
//                    )
//                    is KNode.Expr.Try -> copy(
//                        block = visitChildren(block),
//                        catches = visitChildren(catches),
//                        finallyBlock = visitChildren(finallyBlock)
//                    )
//                    is KNode.Expr.Try.Catch -> copy(
//                        anns = visitChildren(anns),
//                        varType = visitChildren(varType),
//                        block = visitChildren(block)
//                    )
//                    is KNode.Expr.For -> copy(
//                        anns = visitChildren(anns),
//                        vars = visitChildren(vars),
//                        inExpr = visitChildren(inExpr),
//                        body = visitChildren(body)
//                    )
//                    is KNode.Expr.While -> copy(
//                        expr = visitChildren(expr),
//                        body = visitChildren(body)
//                    )
//                    is KNode.Expr.BinaryOp -> copy(
//                        lhs = visitChildren(lhs),
//                        oper = visitChildren(oper),
//                        rhs = visitChildren(rhs)
//                    )
//                    is KNode.Expr.BinaryOp.Oper.Infix -> this
//                    is KNode.Expr.BinaryOp.Oper.Token -> this
//                    is KNode.Expr.UnaryOp -> copy(
//                        expr = visitChildren(expr),
//                        oper = visitChildren(oper)
//                    )
//                    is KNode.Expr.UnaryOp.Oper -> this
//                    is KNode.Expr.DoubleColonRef.Callable -> copy(
//                        recv = visitChildren(recv)
//                    )
//                    is KNode.Expr.DoubleColonRef.Class -> copy(
//                        recv = visitChildren(recv)
//                    )
//                    is KNode.Expr.DoubleColonRef.Recv.Expr -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.DoubleColonRef.Recv.Type -> copy(
//                        type = visitChildren(type)
//                    )
//                    is KNode.Expr.Paren -> copy(
//                        expr = visitChildren(expr)
//                    )
////                    is KNode.Expr.StringTmpl -> copy(
////                        elems = visitChildren(elems)
////                    )
////                    is KNode.Expr.StringTmpl.Elem.Regular -> this
////                    is KNode.Expr.StringTmpl.Elem.ShortTmpl -> this
////                    is KNode.Expr.StringTmpl.Elem.UnicodeEsc -> this
////                    is KNode.Expr.StringTmpl.Elem.RegularEsc -> this
////                    is KNode.Expr.StringTmpl.Elem.LongTmpl -> copy(
////                        expr = visitChildren(expr)
////                    )
//                    is KNode.Expr.Const -> this
//                    is KNode.Expr.Brace -> copy(
//                        params = visitChildren(params),
//                        block = visitChildren(block)
//                    )
//                    is KNode.Expr.Brace.Param -> copy(
//                        vars = visitChildren(vars),
//                        destructType = visitChildren(destructType)
//                    )
//                    is KNode.Expr.This -> this
//                    is KNode.Expr.Super -> copy(
//                        typeArg = visitChildren(typeArg)
//                    )
//                    is KNode.Expr.When -> copy(
//                        expr = visitChildren(expr),
//                        entries = visitChildren(entries)
//                    )
//                    is KNode.Expr.When.Entry -> copy(
//                        conds = visitChildren(conds),
//                        body = visitChildren(body)
//                    )
//                    is KNode.Expr.When.Cond.Expr -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.When.Cond.In -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.When.Cond.Is -> copy(
//                        type = visitChildren(type)
//                    )
//                    is KNode.Expr.Object -> copy(
//                        parents = visitChildren(parents),
//                        members = visitChildren(members)
//                    )
//                    is KNode.Expr.Throw -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.Return -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.Continue -> this
//                    is KNode.Expr.Break -> this
//                    is KNode.Expr.CollLit -> copy(
//                        exprs = visitChildren(exprs)
//                    )
//                    is KNode.Expr.Name -> this
//                    is KNode.Expr.Labeled -> copy(
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.Annotated -> copy(
//                        anns = visitChildren(anns),
//                        expr = visitChildren(expr)
//                    )
//                    is KNode.Expr.TypeOp -> copy (
//                        lhs = visitChildren(lhs),
//                        oper = visitChildren(oper),
//                        rhs = visitChildren(rhs)
//                    )
//                    is KNode.Expr.TypeOp.Oper -> this
//                    is KNode.Expr.Call -> copy(
//                        expr = visitChildren(expr),
//                        typeArgs = visitChildren(typeArgs),
//                        args = visitChildren(args),
//                        lambda = visitChildren(lambda)
//                    )
//                    is KNode.Expr.Call.TrailLambda -> copy(
//                        anns = visitChildren(anns),
//                        func = visitChildren(func)
//                    )
//                    is KNode.Expr.ArrayAccess -> copy(
//                        expr = visitChildren(expr),
//                        indices = visitChildren(indices)
//                    )
//                    is KNode.Expr.AnonFunc -> copy(
//                        func = visitChildren(func)
//                    )
//                    is KNode.Expr.Property -> copy(
//                        decl = visitChildren(decl)
//                    )
//                    is KNode.Block -> copy(
//                        stmts = visitChildren(stmts)
//                    )
//                    is KNode.Stmt.Decl -> copy(
//                        decl = visitChildren(decl)
//                    )
//                    is KNode.Stmt.Expr -> copy(
//                        expr = visitChildren(expr)
//                    )
////                    is KNode.Modifier.AnnotationSet -> copy(
////                        anns = visitChildren(anns)
////                    )
////                    is KNode.Modifier.AnnotationSet.Annotation -> copy(
////                        typeArgs = visitChildren(typeArgs),
////                        args = visitChildren(args)
////                    )
////                    is KNode.Modifier.Lit -> this
////                    is KNode.Extra.BlankLines -> this
////                    is KNode.Extra.Comment -> this
//                    else -> error("Unrecognized node: $this")
//                }
//    }
//
//    fun visitDecl(decl:KNode.Decl):Node? {
//        when(decl){
//
//        }
//    }
//
//    protected fun <T: KNode?> KNode?.visitChildren(v: T): Node? = visit(v, this!!)
//
//    protected fun <T: KNode?> KNode?.visitChildren(v: List<T>): List<Node> =
//        v.mapNotNull { orig -> visit(orig, this!!) }
//}
