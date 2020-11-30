package ktPyString.properties

import kotlin.test.Test
import kotlin.test.assertEquals


internal class NumericTypeTest {
    @Test
    fun notNumeric() {
        assertEquals(NumericType.NOT_NUMERIC, ' '.numericType)
    }

    @Test
    fun decimal() {
        assertEquals(NumericType.DECIMAL, '1'.numericType)
    }

    @Test
    fun digit() {
        assertEquals(NumericType.DIGIT, '①'.numericType)
    }

    @Test
    fun numeric() {
        assertEquals(NumericType.NUMERIC, '¾'.numericType)
    }
}
