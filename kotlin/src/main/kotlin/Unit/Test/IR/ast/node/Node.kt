package unit.test.ir.ast.node

sealed class Node {
    data class File(
        val body:List<Decl>
    ): Node()
    data class Block(
        val body: List<Stmt>
    ): Node() {
        sealed class Stmt{
            data class Decl(
                val decl:Node.Decl
            ):Stmt()
            data class Expr(
                val expr:Node.Expr
            ):Stmt()
        }
    }
    sealed class Decl: Node() {
        data class Var(
            val name:String,
            val type:String,
            val value:Expr?
        ): Decl()
        data class Func(
            val name:String,
            val args:List<Arg>,
            val body:Block
        ): Decl(){
            data class Arg(
                val field:Var,
                val vararg:Boolean
            ): Node()
        }
        data class Class(
            val name:String,
            val bases:List<String>,
            val constractors:List<Func>,
            val fields:List<Decl>
        )
        sealed class IR : Node() {
            class Suite(
                val setUp: List<Node>, // Expr
                val cases: List<Case>,
                val tearDown: List<Node> // Expr
            ) : IR()

            sealed class Case : IR() {
                class Set(
                    val target: Node,
                    val call: String,
                    val params: List<Params>,
                    val kind: Kind
                ) : Case() {
                    class Params(
                        val name: String,
                        val args: Map<String, Node>,
                        val excepted: Node,
                        val actual: Node,
                        val message: String?
                    )
                    enum class Kind{
                        METHOD,
                        MEMBER,
                        FUNCTION,
                        BIN_OP,
                        UNARY_OP,
                    }
                }

                class CaseExpr(
                    val name: String,
                    val expr: List<Node>, // Expr
                    val asserts: List<Node>
                ) : Case()
            }

            class Assert(
                val kind: Kind
            ) : IR() {
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
    sealed class Expr: Node() {
        data class Name(
            val name:String
        ):Node()
        data class BinOp(
            val right:Expr,
            val kind:String,
            val left:Expr
        ): Node()
    }
}
