package com.szunyoghtamas.stopwatch.action

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.szunyoghtamas.stopwatch.MainActivity
import com.szunyoghtamas.stopwatch.state.Kind

object StopwatchLaunch {
    const val EXTRA_TAB = "stopwatch_open_tab"
    const val EXTRA_DISMISS_ALARM = "stopwatch_dismiss_alarm"

    @Volatile private var pending: String? = null

    var onPendingChanged: (() -> Unit)? = null

    fun openIntent(context: Context, kind: Kind, dismissAlarm: Boolean = false): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_TAB, kind.key)
            if (dismissAlarm) putExtra(EXTRA_DISMISS_ALARM, true)
        }
        val code = 2000 + kind.ordinal * 2 + if (dismissAlarm) 1 else 0
        return PendingIntent.getActivity(context, code, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    fun deliver(tab: String) {
        pending = tab
        onPendingChanged?.invoke()
    }

    fun consume(): String? = pending.also { pending = null }
}