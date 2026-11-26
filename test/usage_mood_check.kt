import com.example.brainrot.UsageMood

// Compile with UsageMood.kt and run Usage_mood_checkKt; no Android runtime required.
fun main() {
    val cases = mapOf(
        0L to (100.0 to "vui"),
        120L to (90.0 to "vui"),
        150L to (80.0 to "vui"),
        151L to (79.66666666666667 to "suynghi"),
        210L to (60.0 to "suynghi"),
        211L to (59.66666666666667 to "cangthang"),
        300L to (30.0 to "cangthang"),
        301L to (29.66666666666667 to "buonngu"),
        390L to (0.0 to "buonngu"),
        1440L to (0.0 to "buonngu")
    )
    for ((minutes, expected) in cases) {
        val score = UsageMood.score(minutes * 60000L)
        check(kotlin.math.abs(score - expected.first) < 0.000001) { "Wrong score at $minutes minutes" }
        check(UsageMood.image(score) == expected.second) { "Wrong mood at $minutes minutes" }
        check(UsageMood.score(minutes * 60000L + 59999L) == score) { "Must use whole minutes like Flutter" }
    }
    check(UsageMood.image(UsageMood.score(0)) == "vui") { "A new day must reset the mood" }
    println("Usage mood checks passed: thresholds, clamping, whole minutes and daily reset.")
}
