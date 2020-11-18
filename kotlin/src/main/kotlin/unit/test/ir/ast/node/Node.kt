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
            @Serializable
            @SerialName("Return")
            data class Return(
                    @SerialName("Value")
                    val value: Node.Expr
            ) : Stmt()

            @Serializable
            @SerialName("For")
            data class For(
                    @SerialName("Value")
                    val value: Node.Decl.Var,
                    @SerialName("Generator")
                    val generator: Node.Expr,
                    @SerialName("Body")
                    val body: Block
            ) : Stmt()
            @Serializable
            @SerialName("Throw")
            data class Throw(
                    @SerialName("Value")
                    val value: Node.Expr
            ) : Stmt()
            @Serializable
            @SerialName("Try")
            data class Try(
                    @SerialName("Body")
                    val body: Block,
                    val catch: Catch
            ) : Stmt() {
                @Serializable
                @SerialName("Catch")
                data class Catch(
                        @SerialName("Type")
                        val type: String,
                        @SerialName("Body")
                        val body: Block,
                        val catch: Catch?
                ) : Stmt()
            }
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
                val cases: IList<Case>,
                @SerialName("TearDown")
                val tearDown: IList<Expr>,
        ) : Decl(), IR
        @Serializable
        sealed class Case : Decl(), IR {
            @Serializable
            data class MethodSet(
                    val name: String,
                    val params: IList<Param>,
            ) : Case() {
                @Serializable
                data class Param(
                        val name: String,
                        val receiver: Expr,
                        val args: Map<String, Expr>,
                        val expected: Expr,
                        val message: String?
                )
            }
            @Serializable
            data class FunctionSet(
                    val name: String,
                    val params: IList<Param>,
            ) : Case() {
                @Serializable
                data class Param(
                        val name: String,
                        val args: Map<String, Expr>,
                        val expected: Expr,
                        val message: String?
                )
            }

            @Serializable
            @SerialName("CaseBlock")
            data class CaseBlock(
                    @SerialName("Name")
                    val name: String,
                    @SerialName("Body")
                    val body: Block,
            ) : Case()
        }

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
                NOT_EQUAL,
                IN,
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
        @SerialName("Assert")
        data class Assert(
                @SerialName("Kind")
                val kind: Kind
        ) : Expr(), IR {
            @Serializable
            sealed class Kind {
                @Serializable
                @SerialName("Equal")
                data class AssertEqual(
                        @SerialName("Expected")
                        val expected: Expr,
                        @SerialName("Actual")
                        val actual: Expr,
                        @SerialName("Message")
                        val message: String?
                ) : Kind()
                @Serializable
                @SerialName("Failure")
                data class AssertFailure(
                        @SerialName("Error")
                        val error: String?,
                        @SerialName("Func")
                        val func: Expr,
                        @SerialName("Args")
                        val args: IList<Expr>,
                        @SerialName("Message")
                        val message: String?
                ) : Kind()
            }
        }

    }
}

