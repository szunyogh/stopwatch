package com.szunyoghtamas.stopwatch.state

import android.content.Context
import android.util.Log
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.widget.StopwatchWidgetProvider

object StopwatchSurfaces {
    private const val TAG = "[Widget] Surfaces"

    fun refresh(context: Context, isReset: Boolean = false) {
        Log.d(TAG, "refresh called, isReset: $isReset")
        StopwatchState.init(context)

        if(isReset) {
            Log.d(TAG, "refresh: cancelling notification (cancel)")
            StopwatchNotificationHelper.cancel(context)
        } else {
            Log.d(TAG, "refresh: updating notification (update)")
            StopwatchNotificationHelper.update(context)
        }

        Log.d(TAG, "refresh: starting widget update (updateAll)")
        StopwatchWidgetProvider.updateAll(context)
    }
}