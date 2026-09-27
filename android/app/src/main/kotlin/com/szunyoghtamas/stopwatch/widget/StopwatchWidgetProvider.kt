package com.szunyoghtamas.stopwatch.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.widget.RemoteViews
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.state.StopwatchState
import java.util.Locale

class StopwatchWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { updateWidget(context, manager, it) }
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, StopwatchWidgetProvider::class.java))
            ids.forEach { updateWidget(context, manager, it) }
        }

        private fun updateWidget(context: Context, manager: AppWidgetManager, appWidgetId: Int) {
            StopwatchState.init(context)
            val isRunning = StopwatchState.isRunning
            val startedAt = StopwatchState.startedAtEpochMs
            val accumulated = StopwatchState.accumulatedMs

            val views = RemoteViews(context.packageName, R.layout.widget_stopwatch)

            if (isRunning && startedAt != null) {
                val epochWhen = startedAt - accumulated
                val elapsedSinceEpochWhen = System.currentTimeMillis() - epochWhen
                val base = SystemClock.elapsedRealtime() - elapsedSinceEpochWhen
                views.setChronometer(R.id.widget_time_text, base, null, true)
            } else {
                views.setChronometer(R.id.widget_time_text, 0L, null, false)
                views.setTextViewText(R.id.widget_time_text, formatStatic(accumulated))
            }

            val action = if (isRunning) StopwatchActionReceiver.ACTION_STOP else StopwatchActionReceiver.ACTION_START
            views.setImageViewResource(R.id.widget_action_button, if (isRunning) R.drawable.ic_stop else R.drawable.ic_play)

            val intent = Intent(context, StopwatchActionReceiver::class.java).apply { this.action = action }
            val pendingIntent = PendingIntent.getBroadcast(
                context, action.hashCode(), intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_action_button, pendingIntent)

            manager.updateAppWidget(appWidgetId, views)
        }

        private fun formatStatic(ms: Long): String {
            val totalSeconds = ms / 1000
            return String.format(locale = Locale.US, "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
        }
    }
}