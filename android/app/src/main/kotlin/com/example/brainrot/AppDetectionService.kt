package com.example.brainrot

import android.accessibilityservice.AccessibilityService
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.app.KeyguardManager
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONObject
import java.util.Calendar
import java.util.concurrent.Executors

class AppDetectionService : AccessibilityService() {
    companion object {
        private const val TAG = "AppDetectionService"
        private const val PREFS_NAME = "brainrot_blocking"
        private const val RULES_KEY = "blocking_rules"
        private const val FOCUS_MODES_KEY = "focus_modes"
    }

    private var lastPackageName: String? = null
    private var lastWidgetPackage: String? = null
    private var lastWidgetRefresh = 0L
    private val widgetExecutor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private val sleepCheck = object : Runnable {
        override fun run() {
            try {
                val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                if (power.isInteractive && !keyguard.isKeyguardLocked) {
                    val now = android.os.SystemClock.elapsedRealtime()
                    if (now - lastWidgetRefresh >= 60000L) {
                        lastWidgetRefresh = now
                        refreshWidget()
                    }
                    val foreground = lastPackageName
                    if (foreground != null && !shouldIgnorePackage(foreground) &&
                        SleepMode.shouldBlock(this@AppDetectionService, foreground)) {
                        showBlockScreen(foreground, getString(R.string.sleep_block_reason), false)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Could not check sleep mode", e)
            } finally {
                // shortcut: schedule boundaries can take 5 seconds to apply; use alarms if exact timing is needed.
                handler.postDelayed(this, 5000L)
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "App blocker accessibility service connected")
        UsageWidgetWorker.schedule(this)
        refreshWidget()
        handler.removeCallbacks(sleepCheck)
        handler.post(sleepCheck)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return
        // Include the launcher: returning Home must refresh without opening Brainrot.
        if (packageName != lastWidgetPackage) {
            lastWidgetPackage = packageName
            refreshWidget()
        }
        if (shouldIgnorePackage(packageName)) {
            if (packageName != "com.android.systemui") lastPackageName = null
            return
        }

        lastPackageName = packageName
        val blockResult = shouldBlockPackage(packageName)
        if (blockResult.shouldBlock) {
            showBlockScreen(packageName, blockResult.reason, blockResult.canBypass)
        }
    }

    private fun refreshWidget() {
        if (!UsageWidgetProvider.hasWidgets(this)) return
        // Read usage off the accessibility thread without waiting for Android's job scheduler.
        widgetExecutor.execute { UsageWidgetWorker.updateWidget(applicationContext) }
    }

    private fun shouldIgnorePackage(packageName: String): Boolean {
        if (packageName == applicationContext.packageName ||
            packageName == "com.android.systemui" ||
            packageName == "com.android.settings") {
            return true
        }

        val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val homePackage = packageManager.resolveActivity(homeIntent, 0)?.activityInfo?.packageName
        return packageName == homePackage
    }

    private fun shouldBlockPackage(packageName: String): BlockResult {
        return try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            if (SleepMode.shouldBlock(this, packageName)) {
                return BlockResult(true, getString(R.string.sleep_block_reason), false)
            }

            val focusModes = org.json.JSONArray(prefs.getString(FOCUS_MODES_KEY, "[]"))
            for (i in 0 until focusModes.length()) {
                val mode = focusModes.getJSONObject(i)
                if (!isFocusModeActive(mode)) continue

                val allowed = mode.optJSONArray("allowedPackages")
                val blocked = mode.optJSONArray("blockedPackages")
                val isBlocked = if (allowed != null && allowed.length() > 0) {
                    !allowed.contains(packageName)
                } else {
                    blocked.contains(packageName)
                }

                if (isBlocked) {
                    return BlockResult(
                        true,
                        mode.optString("customMessage").takeIf { it.isNotBlank() && it != "null" }
                            ?: "Blocked by ${mode.optString("name", "focus mode")}",
                        mode.optBoolean("allowEmergency", true)
                    )
                }
            }

            val rules = org.json.JSONArray(prefs.getString(RULES_KEY, "[]"))
            for (i in 0 until rules.length()) {
                val rule = rules.getJSONObject(i)
                if (rule.optString("status") != "active" ||
                    !rule.optJSONArray("targetPackages").contains(packageName) ||
                    !isRuleCurrentlyBlocking(rule, packageName)) {
                    continue
                }

                return BlockResult(
                    true,
                    rule.optString("customBlockMessage").takeIf { it.isNotBlank() && it != "null" }
                        ?: "Blocked by ${rule.optString("name", "blocking rule")}",
                    rule.optBoolean("allowEmergencyBypass", false)
                )
            }

            BlockResult(false)
        } catch (e: Exception) {
            Log.e(TAG, "Could not evaluate blocking rules", e)
            BlockResult(false)
        }
    }

    private fun isFocusModeActive(mode: JSONObject): Boolean {
        if (!mode.optBoolean("isActive", false)) return false
        val endTime = mode.optLong("endTimeEpochMillis", 0L)
        return endTime == 0L || System.currentTimeMillis() <= endTime
    }

    private fun isRuleCurrentlyBlocking(rule: JSONObject, packageName: String): Boolean {
        return when (rule.optString("type")) {
            "allDayBlock", "focusMode" -> true
            "schedule" -> isInsideSchedule(rule)
            "timeLimit" -> {
                val dailyLimit = rule.optLong("dailyLimit", 0L)
                dailyLimit > 0L && getTodayForegroundUsage(packageName) >= dailyLimit
            }
            else -> false
        }
    }

    private fun isInsideSchedule(rule: JSONObject): Boolean {
        val calendar = Calendar.getInstance()
        val androidDay = calendar.get(Calendar.DAY_OF_WEEK)
        val mondayBasedDay = if (androidDay == Calendar.SUNDAY) 7 else androidDay - 1
        val days = rule.optJSONArray("daysOfWeek")
        if (days != null && days.length() > 0 && !days.contains(mondayBasedDay)) return false

        val start = parseMinutes(rule.optString("startTime")) ?: return true
        val end = parseMinutes(rule.optString("endTime")) ?: return true
        val now = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)
        return if (start <= end) now in start..end else now >= start || now <= end
    }

    private fun parseMinutes(value: String): Int? {
        val parts = value.split(':')
        if (parts.size != 2) return null
        val hours = parts[0].toIntOrNull() ?: return null
        val minutes = parts[1].toIntOrNull() ?: return null
        return hours * 60 + minutes
    }

    private fun getTodayForegroundUsage(packageName: String): Long {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        return manager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            calendar.timeInMillis,
            System.currentTimeMillis()
        ).firstOrNull { it.packageName == packageName }?.totalTimeInForeground ?: 0L
    }

    private fun showBlockScreen(packageName: String, reason: String, canBypass: Boolean) {
        try {
            startActivity(Intent(this, BlockOverlayActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("blocked_package", packageName)
                putExtra("block_reason", reason)
                putExtra("can_bypass", canBypass)
            })
        } catch (e: Exception) {
            Log.e(TAG, "Could not display block screen", e)
        }
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        handler.removeCallbacks(sleepCheck)
        widgetExecutor.shutdownNow()
        super.onDestroy()
    }

    private fun org.json.JSONArray?.contains(value: String): Boolean {
        if (this == null) return false
        for (i in 0 until length()) if (optString(i) == value) return true
        return false
    }

    private fun org.json.JSONArray?.contains(value: Int): Boolean {
        if (this == null) return false
        for (i in 0 until length()) if (optInt(i) == value) return true
        return false
    }

    private data class BlockResult(
        val shouldBlock: Boolean,
        val reason: String = "",
        val canBypass: Boolean = false
    )
}
