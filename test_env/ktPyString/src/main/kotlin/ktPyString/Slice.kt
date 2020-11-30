package ktPyString

import kotlin.math.sign
import ktPyString.utils.Quad

/**
 * Slice object representing the set of indices specified by range(start, stop, step).
 * @param start indices specified start.
 * @param stop indices specified stop.
 * @param step indices specified step.
 * @property start indices specified start.
 * @property stop indices specified stop.
 * @property step indices specified step.
 */
public class Slice(
        public val start: Int?,
        public val stop: Int?,
        public val step: Int? = null
) {
    /**
     * Shortcut constractor. [start] and [step] will be 'null'
     * @param stop indices specified stop.
     */
    public constructor(stop: Int?) : this(null, stop)

    /**
     * Return adjusted slice indices
     * @param length target sequence length.
     * @return Triple(start, stop, step)
     */
    public fun indices(length: Int): Triple<Int, Int, Int> {
        val (f, s, t, _) = adjustIndex(length)
        return Triple(f, s, t)
    }

    /**
     * Returns string representation of the [Slice]
     */
    override fun toString(): String = "Slice($start, $stop, $step)"

    internal fun adjustIndex(length: Int): Quad<Int, Int, Int, Int> {
        val step: Int = this.step ?: 1
        var start: Int
        var stop: Int
        val upper: Int
        val lower: Int

        // Convert step to an integer; raise for zero step.
        val stepSign: Int = step.sign
        if (stepSign == 0) {
            throw Exception("ValueError: slice step cannot be zero")
        }
        val stepIsNegative: Boolean = stepSign < 0

        /* Find lower and upper bounds for start and stop. */
        if (stepIsNegative) {
            lower = -1
            upper = length + lower
        } else {
            lower = 0
            upper = length
        }

        // Compute start.
        if (this.start == null) {
            start = if (stepIsNegative) upper else lower
        } else {
            start = this.start

            if (start.sign < 0) {
                start += length

                if (start < lower /* Py_LT */) {
                    start = lower
                }
            } else {
                if (start > upper /* Py_GT */) {
                    start = upper
                }
            }
        }

        // Compute stop.
        if (this.stop == null) {
            stop = if (stepIsNegative) lower else upper
        } else {
            stop = this.stop

            if (stop.sign < 0) {
                stop += length
                if (stop < lower /* Py_LT */) {
                    stop = lower
                }
            } else {
                if (stop > upper /* Py_GT */) {
                    stop = upper
                }
            }
        }
        var loop = 0
        if (step < 0) {
            if (stop < start) {
                loop = (start - stop - 1) / (-step) + 1
            }
        } else {
            if (start < stop) {
                loop = (stop - start - 1) / step + 1
            }
        }
        return Quad(start, stop, step, loop)
    }
}

