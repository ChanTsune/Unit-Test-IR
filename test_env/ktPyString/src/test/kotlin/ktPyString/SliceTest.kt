package ktPyString

import ktPyString.utils.Quad
import kotlin.test.*

internal class SliceTest {

    private val slice = Slice(1)

    @Test
    fun testToString() {
        assertEquals("Slice(null, 1, null)", slice.toString())
    }

    @Test
    fun testSliceInit2() {
        val sliceObj = Slice(1, 2)
        assertEquals(sliceObj, sliceObj)
    }

    @Test
    fun testSliceInit3() {
        val sliceObj = Slice(null, 2)
        assertEquals(sliceObj, sliceObj)
    }

    @Test
    fun testSliceAdjustIndex() {
        val sliceObj = Slice(null, null, 1)
        assertEquals(Quad(0, 20, 1, 20), sliceObj.adjustIndex(20))
        val sliceObj2 = Slice(null, 4, 2)
        assertEquals(Quad(0, 4, 2, 2), sliceObj2.adjustIndex(20))
    }

    @Test
    fun testAdjustIndex2() {
        val slice = Slice(0, null, 1)
        assertEquals(Quad(0, 10, 1, 10), slice.adjustIndex(10))
    }

    @Test
    fun testAdjustIndexStartIsNegative() {
        val slice = Slice(-1, null)
        assertEquals(Quad(9, 10, 1, 1), slice.adjustIndex(10))
    }

    @Test
    fun testAdjustIndexStepIsNegative() {
        val slice = Slice(null, null, -1)
        assertEquals(Quad(9, -1, -1, 10), slice.adjustIndex(10))
    }

    @Test
    fun testAdjustIndexStopAndStepIsNegative() {
        val slice = Slice(null, -5, -1)
        assertEquals(Quad(1, -1, -1, 2), slice.adjustIndex(2))
    }

    @Test
    fun testStepIsZero() {
        assertFailsWith<Exception> {
            Slice(null, -5, 0).adjustIndex(10)
        }
    }

    @Test
    fun testIndies() {
        assertEquals(Triple(0, 10, 1), Slice(10).indices(10))
    }
}
