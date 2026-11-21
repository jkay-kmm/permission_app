package com.example.brainrot

import android.content.Context
import android.content.Intent
import android.provider.AlarmClock
import android.telecom.TelecomManager
import android.telecom.InCallService
import android.util.Log
import org.json.JSONObject
import java.util.Calendar

object SleepMode {
    private const val KEY = "sleep_mode"

    fun read(context: Context): JSONObject = JSONObject(
        context.getSharedPreferences("brainrot_blocking", Context.MODE_PRIVATE)
            .getString(KEY, "{}") ?: "{}"
    )

    fun save(context: Context, json: String): Boolean {
        val value = JSONObject(json)
        require(value.getInt("startMinute") in 0..1439)
        require(value.getInt("endMinute") in 0..1439)
        require(value.getInt("startMinute") != value.getInt("endMinute"))
        value.getBoolean("enabled")
        require(value.getLong("manualUntil") >= 0 && value.getLong("pausedUntil") >= 0)
        val days = value.getJSONArray("days")
        require(days.length() in 1..7)
        for (i in 0 until days.length()) require(days.getInt(i) in 1..7)
        val packages = value.getJSONArray("allowedPackages")
        for (i in 0 until packages.length()) require(packages.getString(i).isNotBlank())
        return context.getSharedPreferences("brainrot_blocking", Context.MODE_PRIVATE)
            .edit().putString(KEY, value.toString()).commit()
    }

    fun isActive(value: JSONObject, now: Calendar = Calendar.getInstance()): Boolean {
        val timestamp = now.timeInMillis
        if (timestamp < value.optLong("pausedUntil")) return false
        if (timestamp < value.optLong("manualUntil")) return true
        if (!value.optBoolean("enabled")) return false
        val start = value.optInt("startMinute", 1320)
        val end = value.optInt("endMinute", 420)
        if (start !in 0..1439 || end !in 0..1439 || start == end) return false
        val androidDay = now.get(Calendar.DAY_OF_WEEK)
        val day = if (androidDay == Calendar.SUNDAY) 7 else androidDay - 1
        val minute = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val days = value.optJSONArray("days") ?: return false
        fun includes(day: Int): Boolean {
            for (i in 0 until days.length()) if (days.optInt(i) == day) return true
            return false
        }
        return if (start < end) {
            includes(day) && minute >= start && minute < end
        } else {
            (minute >= start && includes(day)) ||
                (minute < end && includes(if (day == 1) 7 else day - 1))
        }
    }

    fun essentialPackages(context: Context): Set<String> {
        val packages = mutableSetOf(context.packageName, "com.android.settings",
            "com.android.systemui", "com.android.phone", "com.android.server.telecom",
            "com.android.emergency", "com.google.android.permissioncontroller",
            "com.android.permissioncontroller")
        val telecom = context.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
        telecom?.defaultDialerPackage?.let { packages.add(it) }
        context.packageManager.queryIntentServices(Intent(InCallService.SERVICE_INTERFACE), 0)
            .forEach { packages.add(it.serviceInfo.packageName) }
        val intents = listOf(
            Intent(Intent.ACTION_DIAL),
            Intent(AlarmClock.ACTION_SHOW_ALARMS),
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        )
        for (intent in intents) {
            context.packageManager.queryIntentActivities(intent, 0).forEach {
                packages.add(it.activityInfo.packageName)
            }
        }
        return packages
    }

    fun shouldBlock(context: Context, packageName: String): Boolean {
        try {
            val value = read(context)
            if (!isActive(value) || essentialPackages(context).contains(packageName)) return false
            val allowed = value.optJSONArray("allowedPackages")
            if (allowed != null) {
                for (i in 0 until allowed.length()) if (allowed.optString(i) == packageName) return false
            }
            return true
        } catch (e: Exception) {
            Log.e("SleepMode", "Could not evaluate sleep mode", e)
            return false
        }
    }
}
