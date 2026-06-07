package com.storysync.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class UpNextWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        Log.d("StorySyncWidget", "onUpdate fired! AppWidgetIds: ${appWidgetIds.joinToString()}")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.upnext_widget).apply {
                val title =
                    widgetData.getString("widget_manga_title", null)
                        ?.takeIf { it.isNotBlank() }
                        ?: "No manga in progress"
                val currentChapter = widgetData.getIntCompat("widget_current_chapter", 0)
                val totalChapters = widgetData.getIntCompat("widget_total_chapters", -1)
                val mangaId = widgetData.getString("widget_manga_id", null)
                    ?.takeIf { it.isNotBlank() }

                setTextViewText(R.id.widget_manga_title, title)
                
                if (totalChapters > 0) {
                    setTextViewText(R.id.widget_chapter_text, "Ch. $currentChapter")
                    setTextViewText(R.id.widget_total_chapters, " / $totalChapters")
                } else {
                    setTextViewText(R.id.widget_chapter_text, "Ch. $currentChapter")
                    setTextViewText(R.id.widget_total_chapters, "")
                }

                if (mangaId != null) {
                    val launchUri = Uri.Builder()
                        .scheme("storysync")
                        .authority("manga")
                        .appendPath(mangaId)
                        .appendQueryParameter("t", System.currentTimeMillis().toString())
                        .build()
                    setOnClickPendingIntent(
                        R.id.upnext_widget_root,
                        HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            launchUri
                        )
                    )

                    val incrementUri = Uri.Builder()
                        .scheme("storysync")
                        .authority("increment")
                        .appendQueryParameter("mangaId", mangaId)
                        .appendQueryParameter("t", System.currentTimeMillis().toString())
                        .build()
                    setOnClickPendingIntent(
                        R.id.widget_increment_button,
                        HomeWidgetBackgroundIntent.getBroadcast(context, incrementUri)
                    )
                } else {
                    setOnClickPendingIntent(
                        R.id.upnext_widget_root,
                        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                    )
                    setOnClickPendingIntent(R.id.widget_increment_button, null)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun SharedPreferences.getIntCompat(key: String, fallback: Int): Int {
        return when (val value = all[key]) {
            is Int -> value
            is Long -> value.toInt()
            is Float -> value.toInt()
            is Double -> value.toInt()
            is String -> value.toIntOrNull() ?: fallback
            is Number -> value.toInt()
            else -> fallback
        }
    }
}
