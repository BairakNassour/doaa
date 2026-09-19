package com.abdorx.app.amra

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences 
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // 1. قراءة البيانات من Flutter
                val rank = widgetData.getString("user_rank", "مبتدئ") 
                val bgColorHex = widgetData.getString("widget_bg_color", "#0C261F") 

                // 2. تحديث نص الرتبة
                setTextViewText(R.id.widget_rank, rank)

                // 3. تحديث لون الخلفية العادي (الميثود التي نجحت معك سابقاً بدون كراش)
                try {
                    val colorInt = Color.parseColor(bgColorHex)
                    setInt(R.id.widget_background_container, "setBackgroundColor", colorInt)
                } catch (e: Exception) {
                    setInt(R.id.widget_background_container, "setBackgroundColor", Color.parseColor("#0C261F"))
                }

                // 4. ميزة النقر لفتح التطبيق
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_background_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}