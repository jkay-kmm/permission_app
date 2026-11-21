package com.example.brainrot

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin


class UsageWidgetProvider : AppWidgetProvider() {

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widget instances
        appWidgetIds.forEach { widgetId ->
            updateAppWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val moodImage = widgetData.getString("widget_mood_image", "vui")
            val views = RemoteViews(context.packageName, R.layout.usage_widget)
            val (iconResId, quoteResId) = getMoodResources(moodImage ?: "vui")
            views.setImageViewResource(R.id.widget_mood_icon, iconResId)
            views.setTextViewText(R.id.widget_mood_quote, context.getString(quoteResId))



            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.score_container, pendingIntent)

            // Update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getMoodResources(moodImage: String): Pair<Int, Int> {
            return when {
                moodImage.contains("vui") -> {
                    R.drawable.vui to R.string.widget_quote_vui
                }
                moodImage.contains("suynghi") -> {
                    R.drawable.suynghi to R.string.widget_quote_suynghi
                }
                moodImage.contains("cangthang") -> {
                    R.drawable.cangthang to R.string.widget_quote_cangthang
                }
                moodImage.contains("buonngu") -> {
                    R.drawable.buonngu to R.string.widget_quote_buonngu
                }
                else -> {
                    R.drawable.vui to R.string.widget_quote_vui
                }
            }
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, UsageWidgetProvider::class.java)
            )

            appWidgetIds.forEach { widgetId ->
                updateAppWidget(context, appWidgetManager, widgetId)
            }
        }
    }
}
