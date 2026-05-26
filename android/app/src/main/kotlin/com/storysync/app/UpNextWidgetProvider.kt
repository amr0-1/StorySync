package com.storysync.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class UpNextWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.upnext_widget).apply {
                val title = widgetData.getString("widget_manga_title", "No manga in progress")
                val currentChapter = widgetData.getInt("widget_current_chapter", 0)
                val totalChapters = widgetData.getInt("widget_total_chapters", -1)

                setTextViewText(R.id.widget_manga_title, title)
                
                if (totalChapters > 0) {
                    setTextViewText(R.id.widget_chapter_text, "Ch. $currentChapter")
                    setTextViewText(R.id.widget_total_chapters, " / $totalChapters")
                } else {
                    setTextViewText(R.id.widget_chapter_text, "Ch. $currentChapter")
                    setTextViewText(R.id.widget_total_chapters, "")
                }

                val mangaId = widgetData.getString("widget_manga_id", "")
                if (!mangaId.isNullOrEmpty()) {
                    val intent = Uri.parse("storysync://increment?mangaId=$mangaId")
                    setOnClickPendingIntent(R.id.widget_increment_button, getPendingSelfIntent(context, intent))
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getPendingSelfIntent(context: Context, uri: Uri): android.app.PendingIntent {
        val intent = android.content.Intent(context, UpNextWidgetProvider::class.java).apply {
            action = "es.antonborri.home_widget.action.BACKGROUND"
            data = uri
            putExtra("es.antonborri.home_widget.keys", arrayOf("increment"))
        }
        return android.app.PendingIntent.getBroadcast(
            context,
            0,
            intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_MUTABLE
        )
    }
}
