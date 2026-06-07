package com.storysync.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class HeatmapWidgetProvider : HomeWidgetProvider() {
    private data class HeatmapPayload(
        val values: IntArray,
        val dates: Array<String?>
    )

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

        val payload = parseHeatmapPayload(widgetData, viewIds.size)
        if (payload == null) {
            appWidgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.heatmap_widget)
                applyEmptyState(views, viewIds)
                appWidgetManager.updateAppWidget(widgetId, views)
            }
            return
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.heatmap_widget).apply {
                for (i in viewIds.indices) {
                    val value = payload.values[i]
                    val color = when (value) {
                        0 -> Color.parseColor("#1AFFFFFF")
                        in 1..2 -> Color.parseColor("#59D4AF37")
                        else -> Color.parseColor("#FFD4AF37")
                    }
                    setInt(viewIds[i], "setBackgroundColor", color)

                    val date = payload.dates[i] ?: continue
                    val timestamp = System.currentTimeMillis()
                    val uri = Uri.parse("storysync://insights?date=$date&t=$timestamp")
                    val pendingIntent =
                        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
                    setOnClickPendingIntent(viewIds[i], pendingIntent)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun parseHeatmapPayload(
        widgetData: SharedPreferences?,
        cellCount: Int
    ): HeatmapPayload? {
        return try {
            val heatmapString = widgetData?.getString("widget_heatmap_data", null) ?: return null
            val datesString = widgetData.getString("widget_heatmap_dates", null) ?: return null

            val heatmapArray = JSONArray(heatmapString)
            val datesArray = JSONArray(datesString)
            val values = IntArray(cellCount) { index ->
                if (index < heatmapArray.length()) heatmapArray.optInt(index, 0) else 0
            }
            val dates = Array<String?>(cellCount) { index ->
                if (index < datesArray.length()) {
                    datesArray.optString(index).takeIf { it.isNotBlank() }
                } else {
                    null
                }
            }

            HeatmapPayload(values, dates)
        } catch (_: Exception) {
            null
        }
    }

    private fun applyEmptyState(views: RemoteViews, viewIds: IntArray) {
        val emptyColor = Color.parseColor("#1AFFFFFF")
        viewIds.forEach { viewId ->
            views.setInt(viewId, "setBackgroundColor", emptyColor)
        }
    }
}
