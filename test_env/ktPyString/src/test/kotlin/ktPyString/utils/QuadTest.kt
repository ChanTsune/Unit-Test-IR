package ktPyString.utils

import kotlin.test.*

internal class QuadTest {

    private val quad = Quad(1, 2.0, 'a', "string")
    private val quadSameTypes = Quad(1, 2, 3, 4)

    @Test
    fun testToString() {
        assertEquals("(1, 2.0, a, string)", quad.toString())
        assertEquals("(1, 2, 3, 4)", quadSameTypes.toString())
    }

    @Test
    fun testToList() {
        assertEquals(
            listOf(1, 2, 3, 4), quadSameTypes.toList()
        )
    }

    @Test
    fun getFirst() {
        assertEquals(1, quad.first)
        assertEquals(1, quadSameTypes.first)
    }

    @Test
    fun getSecond() {
        assertEquals(2.0, quad.second)
        assertEquals(2, quadSameTypes.second)
    }

    @Test
    fun getThird() {
        assertEquals('a', quad.third)
        assertEquals(3, quadSameTypes.third)
    }

    @Test
    fun getFourth() {
        assertEquals("string", quad.fourth)
        assertEquals(4, quadSameTypes.fourth)
    }

    @Test
    fun testComponent() {
        val quad = Quad("a", "b", 1, 2)
        val (a, b, o, t) = quad
        assertEquals("a", a)
        assertEquals("b", b)
        assertEquals(1, o)
        assertEquals(2, t)
    }

    @Test
    operator fun component1() {
        assertEquals(1, quad.component1())
        assertEquals(1, quadSameTypes.component1())

    }

    @Test
    operator fun component2() {
        assertEquals(2.0, quad.component2())
        assertEquals(2, quadSameTypes.component2())
    }

    @Test
    operator fun component3() {
        assertEquals('a', quad.component3())
        assertEquals(3, quadSameTypes.component3())
    }

    @Test
    operator fun component4() {
        assertEquals("string", quad.component4())
        assertEquals(4, quadSameTypes.component4())
    }

    @Test
    fun copy() {
        val quad1 = Quad(1, 2, 3, 4)
        val quad2 = quad1.copy()
        assertEquals(quad1, quad2)
    }

    @Test
    fun testEquals() {
        assertEquals(Quad(1, 2, 3, 4), Quad(1, 2, 3, 4))
        assertEquals(Quad("", "a", 1, 5), Quad("", "a", 1, 5))
    }

    @Test
    fun testQuadAssign() {
        val quad = Quad("a", "b", 1, 2)
        val (a, b, o, t) = quad
        assertEquals("a", a)
        assertEquals("b", b)
        assertEquals(1, o)
        assertEquals(2, t)
    }
}
