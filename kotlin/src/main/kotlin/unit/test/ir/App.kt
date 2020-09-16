/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package unit.test.ir

import kastree.ast.Visitor
import kastree.ast.Node as KNode
import kastree.ast.Writer
import kotlinx.serialization.json.Json
import unit.test.ir.ast.node.Node
import unit.test.ir.converters.IR2KtConverter
import java.io.File
import java.nio.file.Paths


fun main(args: Array<String>) {
    val code = """
        package foo

        fun baz(a:String) = 1
//        fun hoge(a:String) = baz(a=a)
//        class A(val a:String){
//            val d:String = ""
//            fun c() = println(a)
//        }
//        fun p() {
//            val b = A("w")
//            var c = b.a
//            c = "pow"[0]
//
//            b.a = "pows"
//        }
    """.trimIndent()
    // Call the parser with the code
    try {
        val file = Parser.parseFile(code)
        Visitor.visit(file) { node, parentNode ->
            println(node)
        }
        println(Writer.write(file))
    } catch (e: Parser.ParseError){
        println(e)
    }

    try {
        val fileContent = File(
                args.firstOrNull() ?: Paths.get("").toAbsolutePath().parent.resolve("sample_data").resolve("test_sample.json").toString()
        ).readText()

        Json{
            classDiscriminator = "Node"
            ignoreUnknownKeys = true
        }.apply {
            try {
                decodeFromString(Node.serializer(), fileContent).let {
                    IR2KtConverter().visit(it).let {
                        Writer.write(it).let {
                            println(it)
                        }
                    }
                }
            } catch (e: Throwable) {
                println(e.message)
                e.stackTrace.map { println(it) }
            }
        }.apply {
            val fileNode = Node.File(mutableListOf<Node.Decl>().apply{
                add(Node.Decl.Func(
                        name="SampleFunction",
                        args= mutableListOf<Node.Decl.Func.Arg>(),
                        body = Node.Block(mutableListOf<Node.Block.Stmt>().apply {
                            add(Node.Block.Stmt.Expr(
                                    expr = Node.Expr.Return(
                                            value = Node.Expr.Constant(Node.Expr.Constant.Kind.STRING,"文字列")
                                    )
                                )
                            )
                        }),
                    )
                )
            },0)
            encodeToString(Node.serializer(), fileNode).run {
                println(this)
            }
        }
    } catch (e: Throwable) {
        println(e.message)
        e.stackTrace.map { println(it) }
    }
}
