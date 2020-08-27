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
            ): Decl()
        }
        data class Class(
            val name:String,
            val bases:List<String>,
            val constractors:List<Func>,
            val fields:List<Decl>
        )
        sealed class IR : Decl() {
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
        ):Expr()
        data class Constant(
            val kind:Kind,
            val value:String
        ): Expr() {
            enum class Kind{
                STRING
            }
        }
        data class Tuple(
            val values:List<Expr>
        ): Expr()
        data class BinOp(
            val right:Expr,
            val kind:Kind,
            val left:Expr
        ): Expr() {
            enum class Kind(var kw:String){
                DOT(".")
            }
        }
        data class UnaryOp(
            val kind:String,
            val value:Expr
        ): Expr() {
            enum class Kind(var kw:String){
                PLUS("+")
            }
        }
        data class Subscript(
            val value:Expr,
            val index:Expr
        ): Expr()
        data class Call(
            val value:Expr,
            val args:List<Arg>
        ): Expr() {
            data class Arg(
                val name: String,
                val value: Expr
            )
        }
        data class Throw(
            val value:Expr
        ): Expr()
        data class Return(
            val value:Expr
        ): Expr()
        data class For(
            val value: Decl.Var,
            val generator:Expr,
            val body:Block
        ): Expr()
        data class Try(
            val body:Block
        ): Expr() {
            data class Catch(
                val type:String,
                val body:Block
            ): Expr()
        }
    }
}
