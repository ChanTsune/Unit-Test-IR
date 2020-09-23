package unit.test.ir.ast.node

import kotlin.collections.List as IList
import com.github.chantsune.kotlin.enumext.EnumExtension
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Node {
    interface IR
    @Serializable
    @SerialName("File")
    data class File(
            @SerialName("Body")
            val body: IList<Decl>,
            @SerialName("Version")
            val version: Int,
    ) : Node()

    @Serializable
    @SerialName("Block")
    data class Block(
            @SerialName("Body")
            val body: IList<Stmt>
    ) : Node() {
        @Serializable
        sealed class Stmt {
            @Serializable
            @SerialName("Decl")
            data class Decl(
                    @SerialName("Decl")
                    val decl: Node.Decl
            ) : Stmt()

            @Serializable
            @SerialName("Expr")
            data class Expr(
                    @SerialName("Expr")
                    val expr: Node.Expr
            ) : Stmt()
        }
    }

    @Serializable
    sealed class Decl : Node() {
        @Serializable
        @SerialName("Var")
        data class Var(
                @SerialName("Name")
                val name: String,
                @SerialName("Type")
                val type: String?,
                @SerialName("Value")
                val value: Expr?
        ) : Decl()

        @Serializable
        @SerialName("Func")
        data class Func(
                @SerialName("Name")
                val name: String,
                @SerialName("Args")
                val args: IList<Arg>,
                @SerialName("Body")
                val body: Block,
        ) : Decl() {
            @Serializable
            @SerialName("Arg")
            data class Arg(
                    @SerialName("Field")
                    val field: Var,
                    @SerialName("Vararg")
                    val vararg: Boolean
            ) : Decl()
        }

        @Serializable
        @SerialName("Class")
        data class Class(
                @SerialName("Name")
                val name: String,
                @SerialName("Bases")
                val bases: IList<String>,
                @SerialName("Constractors")
                val constractors: IList<Func>,
                @SerialName("Fields")
                val fields: IList<Decl>
        ) : Decl()

        @Serializable
        @SerialName("Suite")
        class Suite(
                @SerialName("Name")
                val name: String,
                @SerialName("SetUp")
                val setUp: IList<Expr>,
                @SerialName("Cases")
                val cases: IList<Expr.Case>,
                @SerialName("TearDown")
                val tearDown: IList<Expr>,
        ) : Decl(), IR
    }

    @Serializable
    sealed class Expr : Node() {
        @Serializable
        @SerialName("Name")
        data class Name(
                @SerialName("Name")
                val name: String
        ) : Expr()

        @Serializable
        @SerialName("Constant")
        data class Constant(
                @SerialName("Kind")
                val kind: Kind,
                @SerialName("Value")
                val value: String
        ) : Expr() {
            enum class Kind {
                STRING,
                BYTES,
                INTEGER,
                FLOAT,
                BOOLEAN,
                NULL,
                ;

                companion object : EnumExtension<Kind>
            }
        }

        @Serializable
        @SerialName("List")
        data class List(
                @SerialName("Values")
                val values: IList<Expr>
        ) : Expr()

        @Serializable
        @SerialName("Tuple")
        data class Tuple(
                @SerialName("Values")
                val values: IList<Expr>
        ) : Expr()

        @Serializable
        @SerialName("BinOp")
        data class BinOp(
                @SerialName("Right")
                val right: Expr,
                @SerialName("Kind")
                val kind: Kind,
                @SerialName("Left")
                val left: Expr
        ) : Expr() {
            enum class Kind {
                DOT,
                ASSIGN,
                ADD,
                SUB,
                MUL,
                DIV,
                MOD,
                LEFT_SHIFT,
                RIGHT_SHIFT,
                ;

                companion object : EnumExtension<Kind>
            }
        }

        @Serializable
        @SerialName("UnaryOp")
        data class UnaryOp(
                @SerialName("Kind")
                val kind: Kind,
                @SerialName("Value")
                val value: Expr
        ) : Expr() {
            enum class Kind {
                PLUS,
                MINUS,
                ;
                companion object : EnumExtension<Kind>
            }
        }

        @Serializable
        @SerialName("Subscript")
        data class Subscript(
                @SerialName("Value")
                val value: Expr,
                @SerialName("Index")
                val index: Expr
        ) : Expr()

        @Serializable
        @SerialName("Call")
        data class Call(
                @SerialName("Value")
                val value: Expr,
                @SerialName("Args")
                val args: IList<Arg>
        ) : Expr() {
            @Serializable
            @SerialName("Arg")
            data class Arg(
                    @SerialName("Name")
                    val name: String?,
                    @SerialName("Value")
                    val value: Expr
            )
        }

        @Serializable
        @SerialName("Throw")
        data class Throw(
                @SerialName("Value")
                val value: Expr
        ) : Expr()

        @Serializable
        @SerialName("Return")
        data class Return(
                @SerialName("Value")
                val value: Expr
        ) : Expr()

        @Serializable
        @SerialName("For")
        data class For(
                @SerialName("Value")
                val value: Decl.Var,
                @SerialName("Generator")
                val generator: Expr,
                @SerialName("Body")
                val body: Block
        ) : Expr()

        @Serializable
        @SerialName("Try")
        data class Try(
                @SerialName("Body")
                val body: Block
        ) : Expr() {
            @Serializable
            @SerialName("Catch")
            data class Catch(
                    @SerialName("Type")
                    val type: String,
                    @SerialName("Body")
                    val body: Block
            ) : Expr()
        }
        @Serializable
        sealed class Case : Expr(), IR {
            @Serializable
            class MethodSet(
                    val name: String,
                    val params: IList<Param>,
            ) : Case() {
                @Serializable
                class Param(
                        val name: String,
                        val receiver: Expr,
                        val args: Map<String, Expr>,
                        val excepted: Expr,
                        val message: String?
                )
            }
            @Serializable
            class FunctionSet(
                    val name: String,
                    val params: IList<Param>,
            ) : Case() {
                @Serializable
                class Param(
                        val name: String,
                        val args: Map<String, Expr>,
                        val excepted: Expr,
                        val message: String?
                )
            }

            @Serializable
            class CaseExpr(
                    val name: String,
                    val expr: IList<Expr>,
            ) : Case()
        }

        @Serializable
        class Assert(
                val kind: Kind
        ) : Expr(), IR {
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

