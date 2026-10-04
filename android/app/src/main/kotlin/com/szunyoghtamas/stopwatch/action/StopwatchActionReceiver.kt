package com.szunyoghtamas.stopwatch.action

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces

class StopwatchActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_START = "com.szunyoghtamas.stopwatch.action.START"
        const val ACTION_STOP = "com.szunyoghtamas.stopwatch.action.STOP"
        const val ACTION_DISMISS = "ACTION_DISMISS"
        private const val TAG = "[Widget] ActionReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: intent action = ${intent.action}")
        StopwatchState.init(context)

        when (intent.action) {
            ACTION_START -> {
                val now = System.currentTimeMillis()
                Log.d(TAG, "onReceive: ACTION_START -> now: $now, acc: ${StopwatchState.accumulatedMs}")
                StopwatchState.start(now, StopwatchState.accumulatedMs)
            }
            ACTION_STOP -> {
                val elapsed = StopwatchState.accumulatedMs +
                        if (StopwatchState.isRunning) {
                            System.currentTimeMillis() - (StopwatchState.startedAtEpochMs ?: System.currentTimeMillis())
                        } else 0L
                Log.d(TAG, "onReceive: ACTION_STOP -> elapsed: $elapsed")
                StopwatchState.stop(elapsed)
            }
            ACTION_DISMISS -> {
                Log.d(TAG, "onReceive: ACTION_DISMISS")
                return StopwatchNotificationHelper.update(context)
            }
        }

        Log.d(TAG, "onReceive: refreshing surfaces and Flutter state")
        StopwatchSurfaces.refresh(context)
        StopwatchMethodChannel.pushStateUpdate(context)
    }
}