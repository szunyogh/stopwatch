package com.szunyoghtamas.stopwatch.action

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.szunyoghtamas.stopwatch.alarm.TimerAlarm
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchState

class StopwatchActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_START = "com.szunyoghtamas.stopwatch.action.START"
        const val ACTION_STOP = "com.szunyoghtamas.stopwatch.action.STOP"
        const val ACTION_TOGGLE = "com.szunyoghtamas.stopwatch.action.TOGGLE"
        const val ACTION_DISMISS = "ACTION_DISMISS"
        const val ACTION_DISMISS_ALARM = "com.szunyoghtamas.stopwatch.action.DISMISS_ALARM"
        private const val EXTRA_KIND = "kind"
        private const val TAG = "[Widget] ActionReceiver"

        fun pending(context: Context, action: String, kind: Kind): PendingIntent {
            val intent = Intent(context, StopwatchActionReceiver::class.java).setAction(action).putExtra(EXTRA_KIND, kind.key)
            return PendingIntent.getBroadcast(
                context, "$action/${kind.key}".hashCode(), intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: intent action = ${intent.action}")
        StopwatchState.init(context)

        val kind = Kind.from(intent.getStringExtra(EXTRA_KIND))

        when (intent.action) {
            ACTION_START -> StopwatchActions.start(context, kind)
            ACTION_STOP -> StopwatchActions.stop(context, kind)
            ACTION_TOGGLE -> StopwatchActions.toggleMode(context)
            ACTION_DISMISS -> return StopwatchNotificationHelper.update(context, kind)
            ACTION_DISMISS_ALARM -> return TimerAlarm.dismiss(context)
        }

        Log.d(TAG, "onReceive: pushing state to Flutter")
        StopwatchMethodChannel.pushStateUpdate(context)
    }
}