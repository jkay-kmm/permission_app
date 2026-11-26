package com.example.brainrot

object UsageMood {
    fun score(totalUsageMillis: Long): Double {
        val minutes = totalUsageMillis / 60000L
        val impact = if (minutes <= 120L) minutes / 120.0 * 10.0
            else 10.0 + (minutes - 120L) / 60.0 * 20.0
        return (100.0 - impact).coerceIn(0.0, 100.0)
    }

    fun image(score: Double): String = when {
        score >= 80 -> "vui"
        score >= 60 -> "suynghi"
        score >= 30 -> "cangthang"
        else -> "buonngu"
    }
}
