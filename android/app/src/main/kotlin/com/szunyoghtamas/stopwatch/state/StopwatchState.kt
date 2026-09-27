package com.szunyoghtamas.stopwatch.state

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object StopwatchState {
    private const val PREFS_NAME = "stopwatch_state"
    private const val KEY_IS_RUNNING = "isRunning"
    private const val KEY_STARTED_AT = "startedAtEpochMs"
    private const val KEY_ACCUMULATED = "accumulatedMs"

    private lateinit var prefs: SharedPreferences

    fun init(context: Context) {
        if (::prefs.isInitialized) return
        prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    val isRunning: Boolean get() = prefs.getBoolean(KEY_IS_RUNNING, false)
    val startedAtEpochMs: Long? get() = prefs.getLong(KEY_STARTED_AT, 0L).takeIf { it != 0L }
    val accumulatedMs: Long get() = prefs.getLong(KEY_ACCUMULATED, 0L)

    fun start(startedAtEpochMs: Long, accumulatedMs: Long) {
        prefs.edit {
            putBoolean(KEY_IS_RUNNING, true)
                .putLong(KEY_STARTED_AT, startedAtEpochMs)
                .putLong(KEY_ACCUMULATED, accumulatedMs)
        }
    }

    fun stop(accumulatedMs: Long) {
        prefs.edit {
            putBoolean(KEY_IS_RUNNING, false)
                .putLong(KEY_STARTED_AT, 0L)
                .putLong(KEY_ACCUMULATED, accumulatedMs)
        }
    }

    fun reset() {
        prefs.edit {
            putBoolean(KEY_IS_RUNNING, false)
                .putLong(KEY_STARTED_AT, 0L)
                .putLong(KEY_ACCUMULATED, 0L)
        }
    }

    fun asMap(): Map<String, Any?> = mapOf(
        "isRunning" to isRunning,
        "startedAtEpochMs" to startedAtEpochMs,
        "accumulatedMs" to accumulatedMs,
    )
}