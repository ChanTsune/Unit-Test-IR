package ktPyString.utils


/**
 * Represents a triad of values
 *
 * There is no meaning attached to values in this class, it can be used for any purpose.
 * Quad exhibits value semantics, i.e. two quads are equal if all four components are equal.
 * An example of decomposing it into values:
 *
 * @param A type of the first value.
 * @param B type of the second value.
 * @param C type of the third value.
 * @param D type of the fourth value.
 * @property first First value.
 * @property second Second value.
 * @property third Third value.
 * @property fourth Fourth value.
 */
internal data class Quad<out A, out B, out C, out D>(
    val first: A,
    val second: B,
    val third: C,
    val fourth: D
) {

    /**
     * Returns string representation of the [Quad] including its [first], [second], [third] and [fourth] values.
     */
    override fun toString(): String {
        return "($first, $second, $third, $fourth)"
    }
}

/**
 * Converts this quad into a list.
 */
internal fun <T> Quad<T, T, T, T>.toList(): List<T> = listOf(first, second, third, fourth)
