package com.example.brainrot

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import java.util.Calendar

// Share the same usage source between Flutter and background widget updates.
class TodayUsageReader(private val context: Context) {
    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun getTodayUsageStats(): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) {
            return emptyList()
        }

        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val packageManager = context.packageManager

        // Get today's start and end time
        val calendar = Calendar.getInstance()
        val currentTime = System.currentTimeMillis()

        // Reset to start of today (00:00:00)
        calendar.timeInMillis = currentTime
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        // ✅ GIẢI PHÁP 1: Dùng UsageEvents để tính chính xác
        // UsageEvents track từng event cụ thể, chính xác hơn UsageStats
        val appUsageMap = calculateUsageFromEvents(usageStatsManager, startTime, currentTime)

        // ✅ GIẢI PHÁP 2: Fallback dùng INTERVAL_BEST nếu UsageEvents không đủ data
        if (appUsageMap.isEmpty()) {
            Log.d("BRAINROT", "UsageEvents empty, using INTERVAL_BEST fallback")
            return getUsageStatsWithBestInterval(usageStatsManager, packageManager, startTime, currentTime)
        }

        val result = mutableListOf<Map<String, Any>>()

        for ((packageName, usageTime) in appUsageMap) {
            // ✅ GIẢI PHÁP 3: Giảm threshold xuống 10 giây (10000ms)
            if (usageTime > 10000) {
                try {
                    val appInfo = packageManager.getApplicationInfo(packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()

                    result.add(mapOf(
                        "packageName" to packageName,
                        "appName" to appName,
                        "usageTimeMillis" to usageTime,
                        "lastTimeUsed" to currentTime,
                        "firstTimeStamp" to startTime
                    ))

                    Log.d("BRAINROT", "App: $appName, Usage: ${usageTime / 1000}s")
                } catch (e: PackageManager.NameNotFoundException) {
                    // App might be uninstalled, skip
                }
            }
        }

        Log.d("BRAINROT", "Total apps tracked: ${result.size}")

        // Sort by usage time descending
        return result.sortedByDescending { it["usageTimeMillis"] as Long }
    }

    /**
     * ✅ GIẢI PHÁP 1: Calculate usage time from UsageEvents (CHÍNH XÁC NHẤT)
     * Track từng ACTIVITY_RESUMED và ACTIVITY_PAUSED event
     */
    private fun calculateUsageFromEvents(
        usageStatsManager: UsageStatsManager,
        startTime: Long,
        endTime: Long
    ): MutableMap<String, Long> {
        val appUsageMap = mutableMapOf<String, Long>()
        val appSessionMap = mutableMapOf<String, Long>() // Track session start time

        try {
            val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()

            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)

                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        // App moved to foreground
                        appSessionMap[event.packageName] = event.timeStamp
                        Log.v("BRAINROT_EVENTS", "${event.packageName} RESUMED at ${event.timeStamp}")
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED,
                    UsageEvents.Event.ACTIVITY_STOPPED -> {
                        // App moved to background
                        val sessionStart = appSessionMap[event.packageName]
                        if (sessionStart != null && sessionStart >= startTime) {
                            val sessionDuration = event.timeStamp - sessionStart
                            if (sessionDuration > 0) {
                                val currentUsage = appUsageMap[event.packageName] ?: 0L
                                appUsageMap[event.packageName] = currentUsage + sessionDuration
                                Log.v("BRAINROT_EVENTS", "${event.packageName} PAUSED, session: ${sessionDuration}ms")
                            }
                            appSessionMap.remove(event.packageName)
                        }
                    }
                }
            }

            // Handle apps still in foreground (chưa có PAUSED event)
            val currentTime = System.currentTimeMillis()
            for ((packageName, sessionStart) in appSessionMap) {
                if (sessionStart >= startTime) {
                    val sessionDuration = currentTime - sessionStart
                    if (sessionDuration > 0) {
                        val currentUsage = appUsageMap[packageName] ?: 0L
                        appUsageMap[packageName] = currentUsage + sessionDuration
                        Log.v("BRAINROT_EVENTS", "$packageName still active, duration: ${sessionDuration}ms")
                    }
                }
            }

            Log.d("BRAINROT", "UsageEvents processed: ${appUsageMap.size} apps")

        } catch (e: Exception) {
            Log.e("BRAINROT", "Error processing UsageEvents: ${e.message}")
        }

        return appUsageMap
    }

    /**
     * ✅ GIẢI PHÁP 2: Fallback using INTERVAL_BEST (CÂN BẰNG)
     * Android tự chọn interval chính xác nhất
     */
    private fun getUsageStatsWithBestInterval(
        usageStatsManager: UsageStatsManager,
        packageManager: PackageManager,
        startTime: Long,
        endTime: Long
    ): List<Map<String, Any>> {
        // Dùng INTERVAL_BEST thay vì INTERVAL_DAILY
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            startTime,
            endTime
        )

        val result = mutableListOf<Map<String, Any>>()

        for (usageStat in usageStats) {
            // ✅ GIẢI PHÁP 3: Giảm threshold xuống 10 giây (10000ms)
            if (usageStat.totalTimeInForeground > 10000 && usageStat.lastTimeUsed >= startTime) {
                try {
                    val appInfo = packageManager.getApplicationInfo(usageStat.packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()

                    result.add(mapOf(
                        "packageName" to usageStat.packageName,
                        "appName" to appName,
                        "usageTimeMillis" to usageStat.totalTimeInForeground,
                        "lastTimeUsed" to usageStat.lastTimeUsed,
                        "firstTimeStamp" to usageStat.firstTimeStamp
                    ))

                    Log.d("BRAINROT", "INTERVAL_BEST - $appName: ${usageStat.totalTimeInForeground / 1000}s")
                } catch (e: PackageManager.NameNotFoundException) {
                    // Skip
                }
            }
        }

        return result.sortedByDescending { it["usageTimeMillis"] as Long }
    }

}
