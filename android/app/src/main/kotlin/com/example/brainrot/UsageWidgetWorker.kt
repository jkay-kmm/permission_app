package com.example.brainrot

import android.content.Context
import android.app.KeyguardManager
import android.util.Log
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.concurrent.TimeUnit

class UsageWidgetWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        return if (updateWidget(applicationContext)) Result.success() else Result.retry()
    }

    companion object {
        private const val PERIODIC_WORK = "brainrot.widget.periodic"
        private const val REFRESH_WORK = "brainrot.widget.refresh"

        fun updateWidget(context: Context): Boolean {
            return try {
                if (!UsageWidgetProvider.hasWidgets(context)) return true
                val keyguard = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguard.isKeyguardLocked) return true
                val reader = TodayUsageReader(context)
                if (!reader.hasUsageStatsPermission()) return true
                val totalUsage = reader.getTodayUsageStats().sumOf { it["usageTimeMillis"] as Long }
                // Recheck permission so revoking access cannot turn the mood into a false happy state.
                if (!reader.hasUsageStatsPermission()) return true
                val score = UsageMood.score(totalUsage)
                val saved = HomeWidgetPlugin.getData(context).edit()
                    .putInt("widget_score", score.toInt())
                    .putString("widget_mood_image", UsageMood.image(score))
                    .commit()
                if (!saved) return false
                UsageWidgetProvider.updateAllWidgets(context)
                true
            } catch (e: Exception) {
                Log.e("UsageWidgetWorker", "Could not refresh usage widget", e)
                false
            }
        }

        fun schedule(context: Context) {
            if (!UsageWidgetProvider.hasWidgets(context)) return
            // shortcut: Android may defer the 15-minute fallback; accessibility events request faster refreshes.
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                PERIODIC_WORK,
                ExistingPeriodicWorkPolicy.KEEP,
                PeriodicWorkRequestBuilder<UsageWidgetWorker>(15, TimeUnit.MINUTES).build()
            )
        }

        fun refresh(context: Context) {
            if (!UsageWidgetProvider.hasWidgets(context)) return
            WorkManager.getInstance(context).enqueueUniqueWork(
                REFRESH_WORK,
                ExistingWorkPolicy.REPLACE,
                OneTimeWorkRequestBuilder<UsageWidgetWorker>().build()
            )
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).apply {
                cancelUniqueWork(PERIODIC_WORK)
                cancelUniqueWork(REFRESH_WORK)
            }
        }
    }
}
