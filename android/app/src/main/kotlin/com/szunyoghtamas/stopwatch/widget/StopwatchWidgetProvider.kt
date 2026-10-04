package com.szunyoghtamas.stopwatch.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import android.widget.RemoteViews
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.state.StopwatchState
import java.util.Locale

class StopwatchWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d(TAG, "onUpdate: called by the system, widget ID count: ${appWidgetIds.size}")
        appWidgetIds.forEach { updateWidget(context, manager, it) }
    }

    companion object {
        private const val TAG = "[Widget] Provider"

        fun updateAll(context: Context) {
            Log.d(TAG, "updateAll called: manually updating all active widgets")
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, StopwatchWidgetProvider::class.java))
            Log.d(TAG, "updateAll: found ${ids.size} widgets")
            ids.forEach { updateWidget(context, manager, it) }
        }

        private fun updateWidget(context: Context, manager: AppWidgetManager, appWidgetId: Int) {
            Log.d(TAG, "updateWidget: starting (ID: $appWidgetId)")
            StopwatchState.init(context)
            val isRunning = StopwatchState.isRunning
            val startedAt = StopwatchState.startedAtEpochMs
            val accumulated = StopwatchState.accumulatedMs

            Log.d(TAG, "updateWidget (ID: $appWidgetId): isRunning=$isRunning, startedAt=$startedAt, acc=$accumulated")

            val views = RemoteViews(context.packageName, R.layout.widget_stopwatch)

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val appOpenIntent = launchIntent?.let {
                PendingIntent.getActivity(
                    context, 0, it,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }
            appOpenIntent?.let { views.setOnClickPendingIntent(R.id.widget_root, it) }

            if (isRunning && startedAt != null) {
                val epochWhen = startedAt - accumulated
                val elapsedSinceEpochWhen = System.currentTimeMillis() - epochWhen
                val base = SystemClock.elapsedRealtime() - elapsedSinceEpochWhen
                Log.d(TAG, "updateWidget (ID: $appWidgetId): running mode - setting Chronometer, base=$base")
                views.setChronometer(R.id.widget_time_text, base, null, true)
            } else {
                val timeString = formatStatic(accumulated)
                Log.d(TAG, "updateWidget (ID: $appWidgetId): stopped mode - setting static text: $timeString")
                views.setChronometer(R.id.widget_time_text, 0L, null, false)
                views.setTextViewText(R.id.widget_time_text, timeString)
            }

            val buttonText = if (isRunning) R.string.widget_button_text_stop else R.string.widget_button_text_start
            val buttonBackground = if (isRunning) R.drawable.rounded_button_stop_bg else R.drawable.rounded_button_start_bg

            views.setTextViewText(R.id.widget_action_button, context.getString(buttonText))
            views.setInt(R.id.widget_action_button, "setBackgroundResource", buttonBackground)

            val action = if (isRunning) StopwatchActionReceiver.ACTION_STOP else StopwatchActionReceiver.ACTION_START
            Log.d(TAG, "updateWidget (ID: $appWidgetId): setting button action -> $action")

            val intent = Intent(context, StopwatchActionReceiver::class.java).apply { this.action = action }
            val pendingIntent = PendingIntent.getBroadcast(
                context, action.hashCode(), intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_action_button, pendingIntent)

            manager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "updateWidget: update finished (ID: $appWidgetId)")
        }

        private fun formatStatic(ms: Long): String {
            val totalSeconds = ms / 1000
            return String.format(locale = Locale.US, "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
        }
    }
}