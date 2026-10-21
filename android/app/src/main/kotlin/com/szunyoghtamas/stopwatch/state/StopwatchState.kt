package com.szunyoghtamas.stopwatch.state

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.core.content.edit

object StopwatchState {
    private const val PREFS_NAME = "stopwatch_state"
    private const val KEY_IS_RUNNING = "isRunning"
    private const val KEY_IS_FIRST_USE = "isFirstUse"
    private const val KEY_STARTED_AT = "startedAtEpochMs"
    private const val KEY_ACCUMULATED = "accumulatedMs"
    private const val KEY_TIMER_TOTAL = "timer_totalMs"
    private const val KEY_WIDGET_MODE = "widgetMode"
    private const val KEY_ALARM_END = "timer_alarmEndAt"
    private const val TAG = "[Widget] State"

    private lateinit var prefs: SharedPreferences

    fun init(context: Context) {
        if (::prefs.isInitialized) return
        Log.d(TAG, "init: initializing SharedPreferences")
        prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun now() = System.currentTimeMillis()

    fun raw(kind: Kind): KindState = KindState(
        kind = kind,
        isRunning = prefs.getBoolean(kind.k(KEY_IS_RUNNING), false),
        startedAtEpochMs = prefs.getLong(kind.k(KEY_STARTED_AT), 0L).takeIf { it != 0L },
        accumulatedMs = prefs.getLong(kind.k(KEY_ACCUMULATED), 0L),
        totalMs = if (kind == Kind.TIMER) prefs.getLong(KEY_TIMER_TOTAL, 0L) else null,
    )

    fun state(kind: Kind, asOf: Long = now()): KindState {
        val s = raw(kind)
        val end = s.endAtEpochMs
        if (kind == Kind.TIMER && end != null && end <= asOf) {
            val total = s.totalMs ?: 0L
            return KindState(kind, false, null, total, total)
        }
        return s
    }

    fun isFirstUse(kind: Kind): Boolean {
        val isFirstUse = prefs.getBoolean(kind.k(KEY_IS_FIRST_USE), true)
        return isFirstUse;
    }

    fun setFirstUse(kind: Kind, value: Boolean) {
        prefs.edit { putBoolean(kind.k(KEY_IS_FIRST_USE), value) }
    }

    fun start(kind: Kind, startedAtEpochMs: Long, accumulatedMs: Long) {
        Log.d(TAG, "start(${kind.key}): SAVE -> startedAt=$startedAtEpochMs, acc=$accumulatedMs")
        prefs.edit {
            putBoolean(kind.k(KEY_IS_RUNNING), true)
            putLong(kind.k(KEY_STARTED_AT), startedAtEpochMs)
            putLong(kind.k(KEY_ACCUMULATED), accumulatedMs)
            putString(KEY_WIDGET_MODE, kind.key)
        }
    }

    fun stop(kind: Kind, accumulatedMs: Long) {
        Log.d(TAG, "stop(${kind.key}): SAVE -> isRunning=false, acc=$accumulatedMs")
        prefs.edit {
            putBoolean(kind.k(KEY_IS_RUNNING), false)
            putLong(kind.k(KEY_STARTED_AT), 0L)
            putLong(kind.k(KEY_ACCUMULATED), accumulatedMs)
        }
    }

    fun reset(kind: Kind, accumulatedMs: Long = 0L) {
        Log.d(TAG, "reset(${kind.key}): SAVE -> acc=$accumulatedMs")
        stop(kind, accumulatedMs)
    }

    fun setTimer(totalMs: Long) {
        Log.d(TAG, "setTimer: SAVE -> total=$totalMs")
        prefs.edit {
            putLong(KEY_TIMER_TOTAL, totalMs)
            putBoolean(Kind.TIMER.k(KEY_IS_RUNNING), false)
            putLong(Kind.TIMER.k(KEY_STARTED_AT), 0L)
            putLong(Kind.TIMER.k(KEY_ACCUMULATED), totalMs)
        }
    }

    fun settleExpiredTimer() {
        val s = raw(Kind.TIMER)
        val end = s.endAtEpochMs ?: return
        if (end > now()) return

        Log.d(TAG, "settleExpiredTimer: reset to ${s.totalMs}")
        prefs.edit {
            putBoolean(Kind.TIMER.k(KEY_IS_RUNNING), false)
            putLong(Kind.TIMER.k(KEY_STARTED_AT), 0L)
            putLong(Kind.TIMER.k(KEY_ACCUMULATED), s.totalMs ?: 0L)
        }
    }

    var widgetMode: Kind
        get() = Kind.from(prefs.getString(KEY_WIDGET_MODE, null))
        set(value) = prefs.edit { putString(KEY_WIDGET_MODE, value.key) }

    var alarmEndAt: Long
        get() = prefs.getLong(KEY_ALARM_END, 0L)
        set(value) = prefs.edit { putLong(KEY_ALARM_END, value) }

    fun asMap(kind: Kind): Map<String, Any?> {
        val s = raw(kind)
        val map = mutableMapOf<String, Any?>(
            "kind" to kind.key,
            "isRunning" to s.isRunning,
            "startedAtEpochMs" to s.startedAtEpochMs,
            "accumulatedMs" to s.accumulatedMs,
        )
        if (kind == Kind.TIMER) map["totalMs"] = s.totalMs
        return map
    }
}