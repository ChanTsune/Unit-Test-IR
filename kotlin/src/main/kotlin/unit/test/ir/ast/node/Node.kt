package unit.test.ir.ast.node

import com.github.chantsune.kotlin.enumext.EnumExtension
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Node {
    @Serializable
    @SerialName("File")
    data class File(
            val body: List<Decl>
    ) : Node()
    @Serializable
    data class Block(
            val body: List<Stmt>
    ) : Node() {
        @Serializable
        sealed class Stmt {
            @Serializable
            data class Decl(
                    val decl: Node.Decl
            ) : Stmt()
            @Serializable
            data class Expr(
                    val expr: Node.Expr
            ) : Stmt()
        }
    }

    @Serializable
    sealed class Decl : Node() {
        @Serializable
        data class Var(
                val name: String,
                val type: String,
                val value: Expr?
        ) : Decl()

        @Serializable
        data class Func(
                val name: String,
                val args: List<Arg>,
                val body: Block
        ) : Decl() {
            @Serializable
            data class Arg(
                    val field: Var,
                    val vararg: Boolean
            ) : Decl()
        }

        @Serializable
        data class Class(
                val name: String,
                val bases: List<String>,
                val constractors: List<Func>,
                val fields: List<Decl>
        ) : Decl()

        @Serializable
        sealed class IR : Decl() {
            @Serializable
            class Suite(
                    val setUp: List<Node>, // Expr
                    val cases: List<Case>,
                    val tearDown: List<Node> // Expr
            ) : IR()

            @Serializable
            sealed class Case : IR() {
                @Serializable
                class Set(
                        val target: Node,
                        val call: String,
                        val params: List<Params>,
                        val kind: Kind
                ) : Case() {
                    @Serializable
                    class Params(
                            val name: String,
                            val args: Map<String, Node>,
                            val excepted: Node,
                            val actual: Node,
                            val message: String?
                    )

                    enum class Kind {
                        METHOD,
                        MEMBER,
                        FUNCTION,
                        BIN_OP,
                        UNARY_OP;

                        companion object : EnumExtension<Kind>
                    }
                }
                @Serializable
                class CaseExpr(
                        val name: String,
                        val expr: List<Node>, // Expr
                        val asserts: List<Assert>
                ) : Case()
            }
            @Serializable
            class Assert(
                    val kind: Kind
            ) : IR() {
                @Serializable
                sealed class Kind {
                    class AssertEqual(
                            val excepted: Node,
                            val actual: Node,
                            val message: String?
                    ) : Kind()
                }
            }
        }
    }

    @Serializable
    sealed class Expr : Node() {
        @Serializable
        data class Name(
                val name: String
        ) : Expr()

        @Serializable
        data class Constant(
                val kind: Kind,
                val value: String
        ) : Expr() {
            enum class Kind {
                STRING;

                companion object : EnumExtension<Kind>
            }
        }
        @Serializable
        data class Tuple(
                val values: List<Expr>
        ) : Expr()

        @Serializable
        data class BinOp(
                val right: Expr,
                val kind: Kind,
                val left: Expr
        ) : Expr() {
            enum class Kind(var kw: String) {
                DOT(".");

                companion object : EnumExtension<Kind>
            }
        }
        @Serializable
        data class UnaryOp(
                val kind: String,
                val value: Expr
        ) : Expr() {
            enum class Kind(var kw: String) {
                PLUS("+"),
                MINUS("-");

                companion object : EnumExtension<Kind>
            }
        }

        @Serializable
        data class Subscript(
                val value: Expr,
                val index: Expr
        ) : Expr()

        @Serializable
        data class Call(
                val value: Expr,
                val args: List<Arg>
        ) : Expr() {
            @Serializable
            data class Arg(
                    val name: String,
                    val value: Expr
            )
        }

        @Serializable
        data class Throw(
                val value: Expr
        ) : Expr()

        @Serializable
        data class Return(
                val value: Expr
        ) : Expr()

        @Serializable
        data class For(
                val value: Decl.Var,
                val generator: Expr,
                val body: Block
        ) : Expr()

        @Serializable
        data class Try(
                val body: Block
        ) : Expr() {
            @Serializable
            data class Catch(
                    val type: String,
                    val body: Block
            ) : Expr()
        }
    }
}
