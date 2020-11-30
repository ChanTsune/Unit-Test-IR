package ktPyString

import kotlin.test.*

internal class KtPyStringKtTest {
    private val hello = "Hello World"
    private val empty = ""
    private val digits = "0123456789"
    @Test
    fun times() {
        assertEquals("Hello WorldHello World", hello * 2)
        assertEquals("", empty * 2)
        assertEquals("", hello * 0)
        assertEquals("", hello * -2)
    }

    @Test
    fun slice() {
        assertEquals("Hello", hello[null, 5])
        assertEquals("ello", hello[1, 5])
        assertEquals(" W", hello[5, 7])
        assertEquals("orld", hello[7, null])

        val b = "Hello, world"
        assertEquals("Hello", b[null, 5])
        assertEquals("ello", b[1, 5])
        assertEquals(", ", b[5, 7])
        assertEquals("world", b[7, null])
        assertEquals("world", b[7, 12])
        assertEquals("world", b[7, 100])
        assertEquals("Hello", b[null, -7])
        assertEquals("ello", b[-11, -7])
        assertEquals(", ", b[-7, -5])
        assertEquals("world", b[-5, null])
        assertEquals("world", b[-5, 12])
        assertEquals("world", b[-5, 100])
        assertEquals("Hello", b[-100, 5])
    }

    @Test
    fun sliceEmpty() {
        assertEquals("", empty[null, 5])
        assertEquals("", empty[1, 5])
        assertEquals("", empty[5, 7])
        assertEquals("", empty[7, null])
    }

    @Test
    fun sliceStepIsNegative() {
        assertEquals("dlroW olleH", "Hello World"[null, null, -1])
        assertEquals("drWolH", "Hello World"[null, null, -2])
        assertEquals("H", "Hello World"[0, null, -2])
        assertEquals("drWo", "Hello World"[null, 3, -2])
        assertEquals("d", "Hello World"[null, -3, -2])
    }

    @Test
    fun sliceStopAndStepIsNegative() {
        assertEquals("3210", "0123"[null, -6, -1])
    }

    @Test
    fun center() {
        val str = "12"
        assertEquals("  12 ", str.center(5))
        assertEquals("12", str.center(1))
        assertEquals("12", str.center(0))

        assertEquals("     ", empty.center(5))
        assertEquals("", empty.center(0))
    }

    @Test
    fun count() {
        assertEquals(5, "aaaaa".count("a"))
        assertEquals(2, "a".count(""))
        assertEquals(3, "ab".count(""))
        assertEquals(3, "bababba".count("ba"))

        val b = "mississippi"
        val i = "i"
        val p = "p"
        val w = "w"
        assertEquals(4, b.count("i"))
        assertEquals(2, b.count("ss"))
        assertEquals(0, b.count("w"))
        assertEquals(4, b.count(i))
        assertEquals(0, b.count(w))
        assertEquals(2, b.count("i", 6))
        assertEquals(2, b.count("p", 6))
        assertEquals(1, b.count("i", 1, 3))
        assertEquals(1, b.count("p", 7, 9))
        assertEquals(2, b.count(i, 6))
        assertEquals(2, b.count(p, 6))
        assertEquals(1, b.count(i, 1, 3))
        assertEquals(1, b.count(p, 7, 9))
    }

    @Test
    fun endswith() {
        assertTrue(digits.endswith("9"))
        assertTrue(digits.endswith("8", end = -1))
        assertFalse(digits.endswith("8", end = -2))
        assertFalse(digits.endswith("8"))
    }

    @Test
    fun endswithVararg() {
        assertTrue(digits.endswith("9", "8"))
        assertFalse(digits.endswith("8", "7"))
    }

    @Test
    fun expandtabs() {
        assertEquals("        ", "\t".expandtabs())
        assertEquals("    ", "\t".expandtabs(4))
        assertEquals("", empty.expandtabs())
        assertEquals("abc\rab      def\ng       hi","abc\rab\tdef\ng\thi".expandtabs())
        assertEquals("abc\rab      def\ng       hi", "abc\rab\tdef\ng\thi".expandtabs(8))
        assertEquals("abc\rab  def\ng   hi", "abc\rab\tdef\ng\thi".expandtabs(4))
        assertEquals("abc\r\nab      def\ng       hi", "abc\r\nab\tdef\ng\thi".expandtabs())
        assertEquals("abc\r\nab      def\ng       hi", "abc\r\nab\tdef\ng\thi".expandtabs(8))
        assertEquals("abc\r\nab  def\ng   hi", "abc\r\nab\tdef\ng\thi".expandtabs(4))
        assertEquals("abc\r\nab\r\ndef\ng\r\nhi", "abc\r\nab\r\ndef\ng\r\nhi".expandtabs(4))
        assertEquals("  a\n b", " \ta\n\tb".expandtabs(1))
    }

    @Test
    fun makeTable() {
    }

    @Test
    fun find() {
        assertEquals(2, digits.find("2"))
        assertEquals(4, digits.find("45"))
        assertEquals(0, digits.find(""))
        assertEquals(-1, digits.find("87"))

        val b = "mississippi"
        val i = "i"
        val w = "w"
        assertEquals(2, b.find("ss"))
        assertEquals(-1, b.find("w"))
        assertEquals(-1, b.find("mississippian"))
        assertEquals(1, b.find(i))
        assertEquals(-1, b.find(w))
        assertEquals(5, b.find("ss", 3))
        assertEquals(2, b.find("ss", 1, 7))
        assertEquals(-1, b.find("ss", 1, 3))
        assertEquals(7, b.find(i, 6))
        assertEquals(1, b.find(i, 1, 3))
        assertEquals(-1, b.find(w, 1, 3))
    }

    @Test
    fun index() {
        assertEquals(2, digits.index("2"))
        assertEquals(4, digits.index("45"))
        assertEquals(0, digits.index(""))
    }

    @Test(expected = Exception::class)
    fun indexNotFound() {
        assertEquals(0, digits.index("87"))
    }

    @Test
    fun isalnum() {
        assertFalse("".isalnum())
        assertTrue("a".isalnum())
        assertTrue("１".isalnum())
        assertFalse("a@b".isalnum())
        assertFalse("abc 123".isalnum())
    }

    @Test
    fun isalpha() {
        assertFalse("I have pen.".isalpha())
        assertTrue("qwerty".isalpha())
        assertFalse("123".isalpha())
        assertFalse("".isalpha())
    }

    @Test
    fun isascii() {
        assertTrue("I have pen.".isascii())
        assertTrue("qwerty".isascii())
        assertTrue("123".isascii())
        assertTrue("".isascii())
        assertFalse("非ASCII文字列".isascii())
    }

    @Test
    fun isdecimal() {
        assertTrue("123".isdecimal())
        assertTrue("１２３４５".isdecimal())
        assertFalse("一".isdecimal())
        assertFalse("".isdecimal())
    }

    @Test
    fun isdigit() {
        assertTrue("123".isdigit())
        assertTrue("１２３４５".isdigit())
        assertFalse("一".isdigit())
        assertFalse("".isdigit())
    }

    @Test
    fun islower() {
        assertTrue("lower case string".islower())
        assertFalse("Lower case string".islower())
        assertFalse("lower case String".islower())
        assertFalse("lower Case string".islower())
        assertFalse("小文字では無い".islower())
    }

    @Test
    fun isprintable() {
        assertTrue("".isprintable())
        assertTrue("abc".isprintable())
        assertFalse("\u060D".isprintable())
    }

    @Test
    fun isspace() {
        assertTrue(" ".isspace())
        assertFalse("".isspace())
        assertFalse("Speace".isspace())
    }

    @Test
    fun isnumeric() {
        assertTrue("123".isnumeric())
        assertTrue("１２３４５".isnumeric())
        assertTrue("一".isnumeric())
        assertFalse("".isnumeric())
    }

    @Test
    fun istitle() {
        assertTrue("Title Case String".istitle())
        assertTrue("Title_Case_String".istitle())
        assertTrue("Title__Case  String".istitle())
        assertFalse("not Title Case String".istitle())
        assertFalse("NotTitleCaseString".istitle())
        assertFalse("Not Title case String".istitle())
    }

    @Test
    fun isupper() {
        assertTrue("UPPER CASE STRING".isupper())
        assertFalse("Upper Case String".isupper())
        assertFalse("大文字では無い".isupper())
    }

    @Test
    fun join() {
        val list = listOf("1", "2", "3")
        assertEquals("1,2,3", ",".join(list))
        assertEquals("123", "".join(list))
    }

    @Test
    fun ljust() {
        assertEquals("ab   ", "ab".ljust(5))
        assertEquals("ab000", "ab".ljust(5, '0'))
        assertEquals("", empty.ljust(0))
        assertEquals("   ", empty.ljust(3))
    }

    @Test
    fun lower() {
        val a = "hello"
        val b = "HELLO"
        assertEquals("", "".lower())
        assertEquals("hello", a.lower())
        assertEquals("hello", b.lower())
    }

    @Test
    fun lstrip() {
        assertEquals("bc", "abc".lstrip("ac"))
        assertEquals("", empty.lstrip())
    }

    @Test
    fun maketrans() {
    }

    @Test
    fun partition() {
        val b = "mississippi"
        assertEquals(Triple("mi", "ss", "issippi"), b.partition("ss"))
        assertEquals(Triple("mississippi", "", ""), b.partition("w"))
    }

    @Test
    fun replace() {
        val b = "mississippi"
        assertEquals("massassappa", b.replace("i", "a"))
        assertEquals("mixixippi", b.replace("ss", "x"))
    }

    @Test
    fun rfind() {
        val b = "mississippi"
        val i = "i"
        val w = "w"
        assertEquals(5, b.rfind("ss"))
        assertEquals(-1, b.rfind("w"))
        assertEquals(-1, b.rfind("mississippian"))
        assertEquals(10, b.rfind(i))
        assertEquals(-1, b.rfind(w))
        assertEquals(5, b.rfind("ss", 3))
        assertEquals(2, b.rfind("ss", 0, 6))
        assertEquals(1, b.rfind(i, 1, 3))
        assertEquals(7, b.rfind(i, 3, 9))
        assertEquals(-1, b.rfind(w, 1, 3))
    }

    @Test(expected = Exception::class)
    fun rindex() {
        val b = "mississippi"
        b.rindex("w")
    }

    @Test
    fun rjust() {
        val b = "abc"
        assertEquals("----abc", b.rjust(7, '-'))
        assertEquals("    abc", b.rjust(7))
    }

    @Test
    fun rpartition() {
        val b = "mississippi"
        assertEquals(Triple("missi", "ss", "ippi"), b.rpartition("ss"))
        assertEquals(Triple("mississipp", "i", ""), b.rpartition("i"))
        assertEquals(Triple("", "", "mississippi"), b.rpartition("w"))
    }

    @Test
    fun rsplit() {
        val expected = listOf("1", "1", "1", "1", "1")
        assertEquals(expected, "1 1 1 1 1".rsplit())
        assertEquals(expected, " 1 1 1 1 1 ".rsplit())
        assertEquals(expected, "  1  1   1 1 1  ".rsplit())
    }

    @Test
    fun rsplitWithArgument() {
        assertEquals(listOf("a", "b", "c", "d", ""), "a|b|c|d|".rsplit("|"))
        assertEquals(listOf("a", "b", "c", "d", ""), "a,b,c,d,".rsplit(","))
        assertEquals(listOf("a,b,c", "d", ""), "a,b,c,d,".rsplit(",", 2))
        assertEquals(listOf("a,b,c,d,"), "a,b,c,d,".rsplit(",", 0))
        assertEquals(listOf("aabbxx", "bb", "ddbb"), "aabbxxaabbaaddbb".rsplit("aa", 2))
        assertEquals(listOf("a,b,c,d,"), "a,b,c,d,".rsplit())

    }

    @Test
    fun rstrip() {
        assertEquals("ab", "abc".rstrip("ac"))
        assertEquals("", empty.rstrip())
    }

    @Test
    fun split() {
        val expected = listOf("1", "1", "1", "1", "1")
        assertEquals(expected, "1 1 1 1 1".split())
        assertEquals(expected, " 1 1 1 1 1 ".split())
        assertEquals(expected, "  1  1   1 1 1  ".split())
        assertEquals(listOf("11111"), "11111".split())
    }

    @Test
    fun splitWithArgument() {
        val expected1 = listOf("1", "1", "1", "1", "1")
        val expected2 = listOf("", "1", "1", "1", "1", "1", "")
        val expected3 = listOf("-1", "1", "1", "1", "1-")
        val expected4 = listOf("", "1", "", "1", "", "1", "", "1", "", "1", "")
        assertEquals(expected1, "1,1,1,1,1".split(","))
        assertEquals(expected2, ",1,1,1,1,1,".split(","))
        assertEquals(expected3, "-1--1--1--1--1-".split("--"))
        assertEquals(expected4, "-1--1--1--1--1-".split("-"))
    }

    @Test
    fun splitlines() {
        assertEquals(listOf("abc", "abc"), "abc\nabc".splitlines())
        assertEquals(listOf("abc\n", "abc\r"), "abc\nabc\r".splitlines(true))
        assertEquals(listOf("abc", "abc"), "abc\r\nabc\n".splitlines())
        assertEquals(listOf("abc\r\n", "abc\n"), "abc\r\nabc\n".splitlines(true))
    }

    @Test
    fun startswith() {
        val b = "hello"
        assertFalse("".startswith("anything"))
        assertTrue(b.startswith("hello"))
        assertTrue(b.startswith("hel"))
        assertTrue(b.startswith("h"))
        assertFalse(b.startswith("hellow"))
        assertFalse(b.startswith("ha"))
    }

    @Test
    fun startswithVarargs() {
        assertTrue(digits.startswith("0","1"))
        assertFalse(digits.startswith("1","2"))
    }

    @Test
    fun strip() {
        assertEquals("b", "abc".strip("ac"))
        assertEquals("", empty.strip(null))
    }

    @Test
    fun swapcase() {
        assertEquals("abc", "ABC".swapcase())
        assertEquals("ABC", "abc".swapcase())
        assertEquals("A b", "a B".swapcase())
    }

    @Test
    fun title() {
        assertEquals("Title Case", "title case".title())
        assertEquals("Title  Case", "title  case".title())
        assertEquals("Title  Case", "title  cAse".title())
    }

    @Test
    fun translate() {
    }

    @Test
    fun upper() {
        val a = "hello"
        val b = "HELLO"
        assertEquals("", "".upper())
        assertEquals("HELLO", a.upper())
        assertEquals("HELLO", b.upper())
    }

    @Test
    fun zfill() {
        val b = "100"
        val c = "-100"
        val d = "+100"
        val e = "=100"
        assertEquals("00100", b.zfill(5))
        assertEquals("100", b.zfill(3))
        assertEquals("100", b.zfill(2))
        assertEquals("-0100", c.zfill(5))
        assertEquals("-100", c.zfill(4))
        assertEquals("-100", c.zfill(3))
        assertEquals("-100", c.zfill(2))
        assertEquals("+0100", d.zfill(5))
        assertEquals("0=100", e.zfill(5))
        assertEquals("00000", empty.zfill(5))
        assertEquals("100", b.zfill(0))
        assertEquals("-100", c.zfill(0))
        assertEquals("", empty.zfill(0))
    }

    @Test
    fun test_none_arguments() {
        val b = "hello"
        val h = "h"
        val l = "l"
        val o = "o"
        val x = "x"
        assertEquals(2, b.find(l, null))
        assertEquals(3, b.find(l, -2, null))
        assertEquals(2, b.find(l, null, -2))
        assertEquals(0, b.find(h, null, null))
        assertEquals(3, b.rfind(l, null))
        assertEquals(3, b.rfind(l, -2, null))
        assertEquals(2, b.rfind(l, null, -2))
        assertEquals(0, b.rfind(h, null, null))
        assertEquals(2, b.count(l, null))
        assertEquals(1, b.count(l, -2, null))
        assertEquals(1, b.count(l, null, -2))
        assertEquals(0, b.count(x, null, null))
        assertTrue(b.endswith(o, null))
        assertTrue(b.endswith(o, -2, null))
        assertTrue(b.endswith(l, null, -2))
        assertFalse(b.endswith(x, null, null))
        assertTrue(b.startswith(h, null))
        assertTrue(b.startswith(l, -2, null))
        assertTrue(b.startswith(h, null, -2))
        assertFalse(b.startswith(x, null, null))
    }
}
