package com.szunyoghtamas.stopwatch.action

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces

class StopwatchActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_START = "com.szunyoghtamas.stopwatch.action.START"
        const val ACTION_STOP = "com.szunyoghtamas.stopwatch.action.STOP"
    }

    override fun onReceive(context: Context, intent: Intent) {
        StopwatchState.init(context)

        when (intent.action) {
            ACTION_START -> {
                val now = System.currentTimeMillis()
                StopwatchState.start(now, StopwatchState.accumulatedMs)
            }
            ACTION_STOP -> {
                val elapsed = StopwatchState.accumulatedMs +
                    if (StopwatchState.isRunning) {
                        System.currentTimeMillis() - (StopwatchState.startedAtEpochMs ?: System.currentTimeMillis())
                    } else 0L
                StopwatchState.stop(elapsed)
            }
        }

        StopwatchSurfaces.refresh(context)
        StopwatchMethodChannel.pushStateUpdate(context)
    }
}