package ktPyString

import kotlin.test.*


class StringTest {
    @Test
    fun testExtendedGetSlice() {
        var b = ""
        for (i in 0..255) {
            b += i.toString()
        }
        val indices = arrayOf(0, null, 1, 3, 19, 100, 54775807, -1, -2, -31, -100)
        val subIndices = indices.slice(IntRange(1, 10))
        for (start in indices) {
            for (stop in indices) {
                for (step in subIndices) {
                    assertEquals(b[start, stop, step], b[start, stop, step])
                }
            }
        }
    }
//    @Test fun test_split_unicodewhitespace() {
//        var b = "\t\n\u000b\u000c\r\u001c\u001d\u001e\u001f"
//        assertEquals(listOf("a\u01cb"), "a\u01cb".split())
//        assertEquals(listOf("a\u01db"), "a\u01db".split())
//        assertEquals(listOf("a\u01eb"), "a\u01eb".split())
//        assertEquals(listOf("a\u01fb"), "a\u01fb".split())
//        assertEquals(listOf("\u001c\u001d\u001e\u001f"),b.split())
//    }
//    @Test fun test_maketrans(){
//        var transtable = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\x0c\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f !"#$%&\"()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\x7f\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0¡¢£¤¥¦§¨©ª«¬\xad®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüxyz"
//        assertEquals(transtable,String.maketrans('abc', 'xyz'))
//        assertEquals(transtable,String.maketrans('ýþÿ', 'xyz'))
//    }
//    @Test fun test_rsplit_unicodewhitespace(){
//        var b = "\t\n\u000b\u000c\r\u001c\u001d\u001e\u001f"
//        assertEquals(listOf("\u001c\u001d\u001e\u001f"),b.rsplit())
//    }
}
