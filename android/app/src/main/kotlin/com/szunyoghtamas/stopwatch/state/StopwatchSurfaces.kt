package com.szunyoghtamas.stopwatch.state

import android.content.Context
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.widget.StopwatchWidgetProvider

object StopwatchSurfaces {
    fun refresh(context: Context) {
        StopwatchState.init(context)
        StopwatchNotificationHelper.update(context)
        StopwatchWidgetProvider.updateAll(context)
    }
}