/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package unit.test.ir

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
        println(file)
        val decls = file.decls
        for (decl in decls) {
            when(decl){
                is KNode.Decl.Structured -> {
                    println(decl)
                    println("MEMBERS")
                    for (member in decl.members) {
                        println(member)
                    }
                }
                is KNode.Decl.Func -> {
                    println(decl)
                    val body = decl.body
                    when(body){
                        is KNode.Decl.Func.Body.Block -> {
                            for (stmt in body.block.stmts){
                                when(stmt) {
                                    is KNode.Stmt.Decl -> {}
                                    is KNode.Stmt.Expr -> {}
                                }
                                println(stmt)
                            }
                        }
                        else -> println(decl.body)
                    }
                }
                else -> println(decl)
            }
        }


        println(Writer.write(file))
    } catch (e: Parser.ParseError){
        println(e)
    }

    try {
        val currentPath = Paths.get("").toAbsolutePath().parent.resolve("sample_data").resolve("test_sample.json")
        val fileContent = File(currentPath.toString()).readText()

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
