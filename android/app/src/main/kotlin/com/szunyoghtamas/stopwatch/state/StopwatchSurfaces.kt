package com.szunyoghtamas.stopwatch.state

import android.content.Context
import android.util.Log
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.widget.StopwatchWidgetProvider

object StopwatchSurfaces {
    private const val TAG = "[Widget] Surfaces"

    fun refresh(context: Context) {
        Log.d(TAG, "refresh called")
        StopwatchState.init(context)

        StopwatchNotificationHelper.update(context)
        StopwatchWidgetProvider.updateAll(context)
    }
}