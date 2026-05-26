package com.storysync.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class HeatmapWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val viewIds = intArrayOf(
            R.id.heatmap_cell_0, R.id.heatmap_cell_1, R.id.heatmap_cell_2, R.id.heatmap_cell_3,
            R.id.heatmap_cell_4, R.id.heatmap_cell_5, R.id.heatmap_cell_6, R.id.heatmap_cell_7,
            R.id.heatmap_cell_8, R.id.heatmap_cell_9, R.id.heatmap_cell_10, R.id.heatmap_cell_11,
            R.id.heatmap_cell_12, R.id.heatmap_cell_13, R.id.heatmap_cell_14, R.id.heatmap_cell_15,
            R.id.heatmap_cell_16, R.id.heatmap_cell_17, R.id.heatmap_cell_18, R.id.heatmap_cell_19,
            R.id.heatmap_cell_20, R.id.heatmap_cell_21, R.id.heatmap_cell_22, R.id.heatmap_cell_23,
            R.id.heatmap_cell_24, R.id.heatmap_cell_25, R.id.heatmap_cell_26, R.id.heatmap_cell_27,
            R.id.heatmap_cell_28, R.id.heatmap_cell_29, R.id.heatmap_cell_30, R.id.heatmap_cell_31,
            R.id.heatmap_cell_32, R.id.heatmap_cell_33, R.id.heatmap_cell_34
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.heatmap_widget).apply {
                val heatmapStr = widgetData.getString("widget_heatmap_data", "[]") ?: "[]"
                val datesStr = widgetData.getString("widget_heatmap_dates", "[]") ?: "[]"
                
                try {
                    val heatmapArray = JSONArray(heatmapStr)
                    val datesArray = JSONArray(datesStr)
                    
                    for (i in 0 until minOf(heatmapArray.length(), viewIds.size)) {
                        val value = heatmapArray.getInt(i)
                        val colorStr = when (value) {
                            0 -> "#1AFFFFFF"
                            in 1..2 -> "#59D4AF37"
                            else -> "#FFD4AF37"
                        }
                        setInt(viewIds[i], "setBackgroundColor", android.graphics.Color.parseColor(colorStr))
                        
                        if (i < datesArray.length()) {
                            val dateStr = datesArray.getString(i)
                            val intent = android.content.Intent(context, MainActivity::class.java).apply {
                                action = android.content.Intent.ACTION_VIEW
                                data = Uri.parse("storysync://insights?date=$dateStr")
                            }
                            val pendingIntent = android.app.PendingIntent.getActivity(
                                context, 
                                dateStr.hashCode(), 
                                intent, 
                                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                            )
                            setOnClickPendingIntent(viewIds[i], pendingIntent)
                        }
                    }
                } catch (e: Exception) {
                    // Ignore JSON parsing errors
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
