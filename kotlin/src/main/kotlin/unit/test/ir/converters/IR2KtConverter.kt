package unit.test.ir.converters

import unit.test.ir.ast.node.Node
import unit.test.ir.escape
import kastree.ast.Node as KNode


class IR2KtConverter {
    fun visit(node: Node): KNode {
        return when (node) {
            is Node.File -> {
                KNode.File(
                        anns = listOf(),
                        pkg = null,
                        imports = listOf(),
                        decls = node.body.map { visit(it) }
                )
            }
            is Node.Block -> {
                visit(node)
            }
            is Node.Decl -> {
                visit(node)
            }
            is Node.Expr -> {
                visit(node)
            }
        }
    }

    private fun visit(node: Node.Block): KNode.Block {
        return KNode.Block(
                stmts = node.body.map { visit(it) }
        )
    }

    private fun visit(node: Node.Block.Stmt): KNode.Stmt {
        return when (node) {
            is Node.Block.Stmt.Decl -> {
                KNode.Stmt.Decl(visit(node.decl))
            }
            is Node.Block.Stmt.Expr -> {
                KNode.Stmt.Expr(visit(node.expr))
            }
        }
    }

    private fun visit(node: Node.Decl): KNode.Decl {
        return when (node) {
            is Node.Decl.Class -> {
                fun visit(node: String): KNode.Decl.Structured.Parent {
                    return TODO()
                }
                KNode.Decl.Structured(
                        mods = listOf(),
                        form = KNode.Decl.Structured.Form.CLASS,
                        name = node.name,
                        typeParams = listOf(),
                        primaryConstructor = null,
                        parentAnns = listOf(),
                        parents = listOf(), // TODO: node.bases.map { visit(it) },
                        typeConstraints = listOf(),
                        members = node.fields.map { visit(it) }

                )
            }
            is Node.Decl.Func -> {
                KNode.Decl.Func(
                        mods = listOf(),
                        typeParams = listOf(),
                        receiverType = null,
                        name = node.name,
                        paramTypeParams = listOf(),
                        params = node.args.map {
                            KNode.Decl.Func.Param(
                                    mods = listOf(),
                                    readOnly = null,
                                    name = it.field.name,
                                    type = KNode.Type(
                                            mods = listOf(),
                                            ref = KNode.TypeRef.Simple(
                                                    pieces = listOf(
                                                            KNode.TypeRef.Simple.Piece(
                                                                    name = it.field.type ?: "Any",
                                                                    typeParams = listOf()
                                                            )
                                                    )
                                            )
                                    ),
                                    default = it.field.value?.let { visit(it) }
                            )
                        },
                        type = null,
                        typeConstraints = listOf(),
                        body = KNode.Decl.Func.Body.Block(visit(node.body))
                )
            }
            is Node.Decl.Var -> {
                TODO()
            }
            is Node.Decl.Suite -> {
                visit(node)
            }
            else -> {
                throw Exception("This branch will never execute! but given $node")
            }
        }
    }

    private fun visit(node: Node.Decl.Suite): KNode.Decl {
        node.setUp // TODO:
        node.tearDown // TODO:
        return KNode.Decl.Structured(
                mods = listOf(),
                form = KNode.Decl.Structured.Form.CLASS,
                name = node.name,
                typeParams = listOf(),
                primaryConstructor = null,
                parentAnns = listOf(),
                parents = listOf(),
                typeConstraints = listOf(),
                members = node.cases.map { visit(it) }
        )
    }

    private fun visit(node: Node.Expr.Case): KNode.Decl.Func {
        return when(node) {
            is Node.Expr.Case.CaseBlock ->
                KNode.Decl.Func(
                    mods = listOf(KNode.Modifier.AnnotationSet(
                            target = null,
                            anns = listOf(KNode.Modifier.AnnotationSet.Annotation(
                                    names = listOf("Test"),
                                    typeArgs = listOf(),
                                    args = listOf(),
                            ))
                    )),
                    typeParams = listOf(),
                    receiverType = null,
                    name = node.name,
                    paramTypeParams = listOf(),
                    params = listOf(),
                    type = null,
                    typeConstraints = listOf(),
                    body = KNode.Decl.Func.Body.Block(visit(node.body))
                )
            else -> TODO()
        }
    }

    private fun visit(node: Node.Expr): KNode.Expr {
        return when (node) {
            is Node.Expr.BinOp -> {
                fun visit(node: Node.Expr.BinOp.Kind): KNode.Expr.BinaryOp.Oper {
                    return when (node) {
                        Node.Expr.BinOp.Kind.DOT -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.DOT
                            )
                        }
                        Node.Expr.BinOp.Kind.ASSIGN -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.ASSN
                            )
                        }
                        Node.Expr.BinOp.Kind.ADD -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.ADD
                            )
                        }
                        Node.Expr.BinOp.Kind.SUB -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.SUB
                            )
                        }
                        Node.Expr.BinOp.Kind.MUL -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.MUL
                            )
                        }
                        Node.Expr.BinOp.Kind.DIV -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.DIV
                            )
                        }
                        Node.Expr.BinOp.Kind.MOD -> {
                            KNode.Expr.BinaryOp.Oper.Token(
                                    token = KNode.Expr.BinaryOp.Token.MOD
                            )
                        }
                        Node.Expr.BinOp.Kind.LEFT_SHIFT -> {
                            KNode.Expr.BinaryOp.Oper.Infix(
                                    str = "shl"
                            )
                        }
                        Node.Expr.BinOp.Kind.RIGHT_SHIFT -> {
                            KNode.Expr.BinaryOp.Oper.Infix(
                                    str = "shr"
                            )
                        }
                    }
                }
                KNode.Expr.BinaryOp(
                        lhs = visit(node.left),
                        oper = visit(node.kind),
                        rhs = visit(node.right),
                )
            }
            is Node.Expr.Call -> {
                KNode.Expr.Call(
                        expr = visit(node.value),
                        typeArgs = listOf(),
                        args = node.args.map {
                            KNode.ValueArg(
                                    name = it.name,
                                    asterisk = false,
                                    expr = visit(it.value)
                            )
                        },
                        lambda = null,
                )
            }
            is Node.Expr.Constant -> {
                when (node.kind) {
                    Node.Expr.Constant.Kind.INTEGER -> {
                        KNode.Expr.Const(
                                value = node.value,
                                form = KNode.Expr.Const.Form.INT
                        )
                    }
                    Node.Expr.Constant.Kind.STRING -> {
                        KNode.Expr.StringTmpl(
                                elems = listOf(KNode.Expr.StringTmpl.Elem.Regular(node.value.escape())),
                                raw = false
                        )
                    }
                    Node.Expr.Constant.Kind.NULL -> {
                        KNode.Expr.Const(
                                value = "null",
                                form = KNode.Expr.Const.Form.NULL
                        )
                    }
                    Node.Expr.Constant.Kind.FLOAT -> {
                        KNode.Expr.Const(
                                value = node.value,
                                form = KNode.Expr.Const.Form.FLOAT
                        )
                    }
                    Node.Expr.Constant.Kind.BOOLEAN -> {
                        KNode.Expr.Const(
                                value = node.value.toLowerCase(),
                                form = KNode.Expr.Const.Form.BOOLEAN
                        )
                    }
                    Node.Expr.Constant.Kind.BYTES -> {
                        println("Warn: ${node.kind} passed but currently unsupported!")
                        KNode.Expr.StringTmpl(
                                elems = listOf(KNode.Expr.StringTmpl.Elem.Regular(node.value)),
                                raw = false
                        )
                    }
                }
            }
            is Node.Expr.For -> {
                KNode.Expr.For(
                        anns = listOf(),
                        vars = listOf(),
                        inExpr = visit(node.generator),
                        body = KNode.Expr.Brace(
                                params = listOf(),
                                block = visit(node.body),
                        ),
                )
            }
            is Node.Expr.Name -> {
                KNode.Expr.Name(node.name)
            }
            is Node.Expr.Return -> {
                KNode.Expr.Return(
                        label = null,
                        expr = visit(node.value)
                )
            }
            is Node.Expr.Subscript -> {
                KNode.Expr.ArrayAccess(
                        expr = visit(node.value),
                        indices = listOf(visit(node.index))
                )
            }
            is Node.Expr.Throw -> {
                TODO()
            }
            is Node.Expr.Try -> {
                TODO()
            }
            is Node.Expr.Tuple -> {
                when (node.values.size) {
                    2 -> {
                        KNode.Expr.Call(
                                expr = KNode.Expr.Name(name = "Pair"),
                                typeArgs = listOf(),
                                args = node.values.map {
                                    KNode.ValueArg(
                                            name = null,
                                            asterisk = false,
                                            expr = visit(it),
                                    )
                                },
                                lambda = null,
                        )
                    }
                    3 -> {
                        KNode.Expr.Call(
                                expr = KNode.Expr.Name(name = "Triple"),
                                typeArgs = listOf(),
                                args = node.values.map {
                                    KNode.ValueArg(
                                            name = null,
                                            asterisk = false,
                                            expr = visit(it),
                                    )
                                },
                                lambda = null,
                        )
                    }
                    else -> {
                        KNode.Expr.Call(
                                expr = KNode.Expr.Name(name = "listOf"),
                                typeArgs = listOf(),
                                args = node.values.map {
                                    KNode.ValueArg(
                                            name = null,
                                            asterisk = false,
                                            expr = visit(it),
                                    )
                                },
                                lambda = null,
                        )
                    }
                }
            }
            is Node.Expr.List -> {
                KNode.Expr.Call(
                        expr = KNode.Expr.Name(name = "listOf"),
                        typeArgs = listOf(),
                        args = node.values.map {
                            KNode.ValueArg(
                                    name = null,
                                    asterisk = false,
                                    expr = visit(it),
                            )
                        },
                        lambda = null,
                )
            }
            is Node.Expr.UnaryOp -> {
                when (node.kind) {
                    Node.Expr.UnaryOp.Kind.PLUS -> {
                        KNode.Expr.UnaryOp(
                                expr = visit(node.value),
                                oper = KNode.Expr.UnaryOp.Oper(
                                        token = KNode.Expr.UnaryOp.Token.POS
                                ),
                                prefix = true
                        )
                    }
                    Node.Expr.UnaryOp.Kind.MINUS -> {
                        KNode.Expr.UnaryOp(
                                expr = visit(node.value),
                                oper = KNode.Expr.UnaryOp.Oper(
                                        token = KNode.Expr.UnaryOp.Token.NEG
                                ),
                                prefix = true
                        )
                    }
                }
            }
            is Node.Expr.Assert -> {
                when (node.kind) {
                    is Node.Expr.Assert.Kind.AssertEqual -> {
                        KNode.Expr.Call(
                                expr = KNode.Expr.Name(name = "assertEquals"),
                                typeArgs = listOf(),
                                args = mutableListOf(
                                        KNode.ValueArg(
                                                name = null,
                                            asterisk = false,
                                                expr = visit(node.kind.excepted)
                                        ),
                                        KNode.ValueArg(
                                                name = null,
                                        asterisk = false,
                                        expr = visit(node.kind.actual)
                                        )
                                ).apply {
                                    node.kind.message?.let {
                                        add(KNode.ValueArg(
                                                    name = null,
                                                    asterisk = false,
                                                    expr = visit(Node.Expr.Constant(
                                                            kind = Node.Expr.Constant.Kind.STRING,
                                                            value = it
                                                        )
                                                    )
                                            )
                                        )
                                    }
                                },
                                lambda = null
                        )
                    }
                }
            }
            else -> {
                throw Exception("This branch will never execute! but given $node")
            }
        }
    }
}
