package com.example.brainrot

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayOutputStream
import java.util.*
import kotlin.collections.HashMap

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.brainrot/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        UsageWidgetWorker.schedule(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSleepMode" -> {
                    try {
                        result.success(mapOf(
                            "schedule" to SleepMode.read(this).toString(),
                            "essentialPackages" to SleepMode.essentialPackages(this).toList()
                        ))
                    } catch (e: Exception) {
                        result.error("SLEEP_LOAD", "Could not load sleep mode", null)
                    }
                }
                "setSleepMode" -> {
                    try {
                        val json = requireNotNull(call.argument<String>("schedule"))
                        result.success(SleepMode.save(this, json))
                    } catch (e: Exception) {
                        result.error("SLEEP_SAVE", "Could not save sleep mode", null)
                    }
                }
                "hasUsagePermission" -> {
                    result.success(TodayUsageReader(this).hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    requestUsageStatsPermission()
                    result.success(true)
                }
                "getUsageStats" -> {
                    val usageData = TodayUsageReader(this).getTodayUsageStats()
                    result.success(usageData)
                }
                "refreshUsageStats" -> {
                    // Force refresh by getting fresh data
                    val usageData = TodayUsageReader(this).getTodayUsageStats()
                    result.success(usageData)
                }
                "openDigitalWellbeing" -> {
                    try {
                        val intent = Intent("com.google.android.apps.wellbeing.action.DASHBOARD").apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.success(false)
                        }
                    }
                }
                "getCurrentTimeInfo" -> {
                    val currentTime = System.currentTimeMillis()
                    val calendar = Calendar.getInstance()
                    calendar.timeInMillis = currentTime

                    result.success(mapOf(
                        "currentTime" to currentTime,
                        "hour" to calendar.get(Calendar.HOUR_OF_DAY),
                        "minute" to calendar.get(Calendar.MINUTE),
                        "day" to calendar.get(Calendar.DAY_OF_MONTH),
                        "month" to calendar.get(Calendar.MONTH) + 1,
                        "year" to calendar.get(Calendar.YEAR)
                    ))
                }
                "getAppIcon" -> {
                    getAppIcon(call, result)
                }
                "getMultipleAppIcons" -> {
                    getMultipleAppIcons(call, result)
                }
                "getLaunchableApps" -> {
                    result.success(getLaunchableApps())
                }
                "syncBlockingData" -> {
                    val rulesJson = call.argument<String>("rulesJson") ?: "[]"
                    val focusModesJson = call.argument<String>("focusModesJson") ?: "[]"
                    getSharedPreferences("brainrot_blocking", Context.MODE_PRIVATE)
                        .edit()
                        .putString("blocking_rules", rulesJson)
                        .putString("focus_modes", focusModesJson)
                        .apply()
                    result.success(true)
                }
                "startBlockingService" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "stopBlockingService" -> {
                    result.success(false)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission()
                    result.success(true)
                }
                "hasAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.data = android.net.Uri.parse("package:$packageName")
        startActivity(intent)
    }

    private fun getLaunchableApps(): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        return packageManager.queryIntentActivities(launcherIntent, 0)
            .asSequence()
            .filter { it.activityInfo.packageName != packageName }
            .map {
                mapOf(
                    "packageName" to it.activityInfo.packageName,
                    "appName" to it.loadLabel(packageManager).toString()
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["appName"]?.lowercase(Locale.getDefault()) }
            .toList()
    }

    private fun getAppIcon(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("packageName")
            if (packageName == null) {
                result.error("INVALID_ARGUMENT", "Package name is required", null)
                return
            }

            val iconBytes = getAppIconBytes(packageName)
            if (iconBytes != null) {
                result.success(iconBytes.map { it.toInt() and 0xFF })
            } else {
                result.error("ICON_NOT_FOUND", "Could not get icon for $packageName", null)
            }
        } catch (e: Exception) {
            Log.e("BRAINROT", "Error getting app icon: ${e.message}")
            result.error("ERROR", "Error getting app icon: ${e.message}", null)
        }
    }

    private fun getMultipleAppIcons(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageNames = call.argument<List<String>>("packageNames")
            if (packageNames == null) {
                result.error("INVALID_ARGUMENT", "Package names list is required", null)
                return
            }

            val iconsMap = mutableMapOf<String, List<Int>?>()

            for (packageName in packageNames) {
                val iconBytes = getAppIconBytes(packageName)
                iconsMap[packageName] = iconBytes?.map { it.toInt() and 0xFF }
            }

            result.success(iconsMap)
        } catch (e: Exception) {
            Log.e("BRAINROT", "Error getting multiple app icons: ${e.message}")
            result.error("ERROR", "Error getting multiple app icons: ${e.message}", null)
        }
    }

    private fun getAppIconBytes(packageName: String): ByteArray? {
        return try {
            Log.d("BRAINROT", "Attempting to get icon for: $packageName")
            val packageManager = applicationContext.packageManager
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val drawable = packageManager.getApplicationIcon(appInfo)

            Log.d("BRAINROT", "Got drawable for $packageName: ${drawable.javaClass.simpleName}")

            // Convert drawable to bitmap
            val bitmap = when (drawable) {
                is BitmapDrawable -> {
                    Log.d("BRAINROT", "Using BitmapDrawable for $packageName")
                    drawable.bitmap
                }
                else -> {
                    val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 128
                    val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 128
                    Log.d("BRAINROT", "Creating bitmap for $packageName: ${width}x${height}")

                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }

            // Convert bitmap to byte array
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val bytes = outputStream.toByteArray()

            Log.d("BRAINROT", "Successfully converted icon for $packageName to ${bytes.size} bytes")
            bytes

        } catch (e: Exception) {
            Log.e("BRAINROT", "Error getting icon for $packageName: ${e.message}", e)
            null
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, AppDetectionService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = ComponentName.unflattenFromString(componentNameString)

            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }

        return false
    }
}
