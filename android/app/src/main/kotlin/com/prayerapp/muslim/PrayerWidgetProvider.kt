package com.prayerapp.muslim

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val nextPrayer = widgetData.getString("next_prayer", "Prayer") ?: "Prayer"
            val countdown = widgetData.getString("countdown", "--:--") ?: "--:--"
            val prayerTime = widgetData.getString("prayer_time", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout).apply {
                setTextViewText(R.id.next_prayer_name, nextPrayer)
                setTextViewText(R.id.countdown, countdown)
                setTextViewText(R.id.prayer_time, prayerTime)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
