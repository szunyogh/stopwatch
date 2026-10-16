package com.szunyoghtamas.stopwatch.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.TimeFormat

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
            StopwatchState.init(context)

            val stopwatch = StopwatchState.state(Kind.STOPWATCH)
            val timer = StopwatchState.state(Kind.TIMER)

            val both = stopwatch.isRunning && timer.isRunning
            val kind = when {
                both -> StopwatchState.widgetMode
                stopwatch.isRunning -> Kind.STOPWATCH
                timer.isRunning -> Kind.TIMER
                else -> StopwatchState.widgetMode
            }
            val s = if (kind == Kind.TIMER) timer else stopwatch

            Log.d(TAG, "updateWidget (ID: $appWidgetId): kind=${kind.key}, isRunning=${s.isRunning}, both=$both")

            val views = RemoteViews(context.packageName, R.layout.widget_stopwatch)

            views.setOnClickPendingIntent(R.id.widget_root, StopwatchLaunch.openIntent(context, kind))

            views.setTextViewText(R.id.widget_title, context.getString(if (kind == Kind.TIMER) R.string.widget_name_timer else R.string.widget_name))

            views.setViewVisibility(R.id.widget_toggle, if (both) View.VISIBLE else View.GONE)
            views.setInt(R.id.widget_toggle_stopwatch, "setImageAlpha", if (kind == Kind.STOPWATCH) 255 else 90)
            views.setInt(R.id.widget_toggle_timer, "setImageAlpha", if (kind == Kind.TIMER) 255 else 90)
            views.setOnClickPendingIntent(R.id.widget_toggle, StopwatchActionReceiver.pending(context, StopwatchActionReceiver.ACTION_TOGGLE, kind))

            if (s.isRunning) {
                val value = s.valueMs()
                val realtime = SystemClock.elapsedRealtime()

                if (kind == Kind.TIMER) {
                    views.setChronometerCountDown(R.id.widget_time_text, true)
                    views.setChronometer(R.id.widget_time_text, realtime + value + 999, null, true) // +999: felfelé kerekít, mint az app
                } else {
                    views.setChronometerCountDown(R.id.widget_time_text, false)
                    views.setChronometer(R.id.widget_time_text, realtime - value, null, true)
                }
            } else {
                views.setChronometerCountDown(R.id.widget_time_text, false)
                views.setChronometer(R.id.widget_time_text, 0L, null, false)
                views.setTextViewText(R.id.widget_time_text, TimeFormat.format(s.valueMs(), kind))
            }

            val buttonText = if (s.isRunning) R.string.widget_button_text_stop else R.string.widget_button_text_start
            val buttonBackground = if (s.isRunning) R.drawable.rounded_button_stop_bg else R.drawable.rounded_button_start_bg
            views.setTextViewText(R.id.widget_action_button, context.getString(buttonText))
            views.setInt(R.id.widget_action_button, "setBackgroundResource", buttonBackground)

            val action = if (s.isRunning) StopwatchActionReceiver.ACTION_STOP else StopwatchActionReceiver.ACTION_START
            views.setOnClickPendingIntent(R.id.widget_action_button, StopwatchActionReceiver.pending(context, action, kind))

            manager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "updateWidget: update finished (ID: $appWidgetId)")
        }
    }
}