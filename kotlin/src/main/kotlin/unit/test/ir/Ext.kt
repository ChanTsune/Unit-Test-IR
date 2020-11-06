package unit.test.ir

import org.apache.commons.lang.StringEscapeUtils

fun String.escape(): String = StringEscapeUtils.escapeJava(this)
