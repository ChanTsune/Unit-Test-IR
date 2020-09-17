package unit.test.ir.converters

import unit.test.ir.ast.node.Node
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
                                    readOnly = true,
                                    name = it.field.name,
                                    type = null,// it.field.type
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
            is Node.Decl.IR -> {
                TODO()
            }
            else -> {
                throw Exception("This branch will never execute! but given $node")
            }
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
                                elems = listOf(KNode.Expr.StringTmpl.Elem.Regular(node.value)),
                                raw = false
                        )
                    }
                    else -> {
                        TODO()
                    }
                }
            }
            is Node.Expr.For -> {
                TODO()
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
                TODO()
            }
            is Node.Expr.Throw -> {
                TODO()
            }
            is Node.Expr.Try -> {
                TODO()
            }
            is Node.Expr.Tuple -> {
                TODO()
            }
            is Node.Expr.List -> {
                TODO()
            }
            is Node.Expr.UnaryOp -> {
                TODO()
            }
            else -> {
                throw Exception("This branch will never execute! but given $node")
            }
        }
    }
}
