/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package Unit.Test.IR

import kastree.ast.Writer


fun _main() {
//    val scriptFile = "/Users/tsunekwataiki/Documents/GitHub/Unit-Test-IR/kotlin/src/main/kotlin/Unit/Test/IR/App.kt"
//
//    val parser = KotlinScriptParser()
//
//    val analyzeContext = parser.parse(scriptFile)
//
//    println(analyzeContext)
//
//    val function = analyzeContext.functions.keys.first()
//    val body = function.bodyExpression as KtBlockExpression
//    println(body)
}


fun main(args: Array<String>) {
    val code = """
        package foo
    
        fun bar() {
            // Print hello
            println("Hello, World!")
        }
    
        fun baz() = println("Hello, again!")
    """.trimIndent()
    // Call the parser with the code
    val file = Parser.parseFile(code)
    println(file)
    println(file.decls)

    println(Writer.write(file))
}
