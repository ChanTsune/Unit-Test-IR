/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package Unit.Test.IR

import kastree.ast.Writer




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
    try {
        val file = Parser.parseFile(code)
        println(file)
        println(file.decls)


        println(Writer.write(file))
    } catch (e: Parser.ParseError){
        println(e)
    }
}
