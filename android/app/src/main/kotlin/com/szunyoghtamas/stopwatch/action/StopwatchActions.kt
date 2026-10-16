package com.szunyoghtamas.stopwatch.action

import android.content.Context
import android.util.Log
import com.szunyoghtamas.stopwatch.alarm.TimerAlarm
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchLapStore
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces

object StopwatchActions {
    private const val TAG = "[Widget] Actions"

    fun start(context: Context, kind: Kind, startedAt: Long? = null, accumulated: Long? = null) {
        StopwatchState.init(context)
        val s = StopwatchState.state(kind)
        if (startedAt == null && s.isRunning) return

        var acc = accumulated ?: s.accumulatedMs
        if (kind == Kind.TIMER && acc <= 0) acc = s.totalMs ?: 0L // lejárt / 0-n álló: a beállított időről újra
        if (kind == Kind.TIMER && acc <= 0) return

        val begin = startedAt ?: StopwatchState.now()
        Log.d(TAG, "start(${kind.key}): begin=$begin, acc=$acc")

        StopwatchState.start(kind, begin, acc)
        if (kind == Kind.TIMER) TimerAlarm.schedule(context, begin + acc)
        StopwatchSurfaces.refresh(context)
    }

    fun stop(context: Context, kind: Kind, accumulated: Long? = null) {
        StopwatchState.init(context)
        val s = StopwatchState.state(kind)
        if (!s.isRunning) return

        val acc = accumulated ?: s.valueMs()
        Log.d(TAG, "stop(${kind.key}): acc=$acc")

        StopwatchState.stop(kind, acc)
        if (kind == Kind.TIMER) TimerAlarm.cancel(context)
        StopwatchSurfaces.refresh(context)
    }

    fun reset(context: Context, kind: Kind, accumulated: Long = 0L) {
        StopwatchState.init(context)
        Log.d(TAG, "reset(${kind.key}): acc=$accumulated")

        StopwatchState.reset(kind, accumulated)
        if (kind == Kind.STOPWATCH) StopwatchLapStore.clear(context)
        if (kind == Kind.TIMER) TimerAlarm.cancel(context)
        StopwatchSurfaces.refresh(context)
    }

    fun setTimer(context: Context, totalMs: Long) {
        StopwatchState.init(context)
        StopwatchState.setTimer(totalMs)
        TimerAlarm.cancel(context)
        StopwatchSurfaces.refresh(context)
    }

    fun onTimerExpiredInApp(context: Context) {
        StopwatchState.init(context)
        StopwatchState.settleExpiredTimer()
        StopwatchSurfaces.refresh(context)
    }

    fun toggleMode(context: Context) {
        StopwatchState.init(context)
        StopwatchState.widgetMode = if (StopwatchState.widgetMode == Kind.STOPWATCH) Kind.TIMER else Kind.STOPWATCH
        com.szunyoghtamas.stopwatch.widget.StopwatchWidgetProvider.updateAll(context)
    }
}