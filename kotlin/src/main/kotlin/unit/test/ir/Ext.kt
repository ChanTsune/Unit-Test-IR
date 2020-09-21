package unit.test.ir

val defaultEscapeMap = mapOf(
        '\t' to "\\t",
        '\n' to "\\n",
        '\r' to "\\r",
)

fun String.escape(escapeMap: Map<Char, String> = defaultEscapeMap): String {
    val self = this
    return buildString {
        self.map { append(escapeMap[it] ?: it) }
    }
}
