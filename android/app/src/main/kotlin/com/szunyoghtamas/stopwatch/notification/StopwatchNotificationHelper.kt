package com.szunyoghtamas.stopwatch.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.KindState
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.TimeFormat

object StopwatchNotificationHelper {
    private const val CHANNEL_ID = "stopwatch_channel"
    private const val TAG = "[Widget] NotifHelper"

    private fun notificationId(kind: Kind) = if (kind == Kind.STOPWATCH) 1001 else 1002

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "createChannel: creating notification channel (if it doesn't exist yet)")
            val channel = NotificationChannel(CHANNEL_ID, "Stopper", NotificationManager.IMPORTANCE_DEFAULT)
                .apply { setShowBadge(false) }
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun shouldShow(s: KindState): Boolean = when {
        s.isRunning -> true
        s.kind == Kind.STOPWATCH -> s.accumulatedMs > 0
        else -> s.accumulatedMs in 1 until (s.totalMs ?: 0L)
    }

    fun update(context: Context) = Kind.entries.forEach { update(context, it) }

    fun update(context: Context, kind: Kind) {
        Log.d(TAG, "update(${kind.key}): notification update started")
        StopwatchState.init(context)

        val s = StopwatchState.state(kind)
        if (!shouldShow(s)) {
            cancel(context, kind)
            return
        }

        createChannel(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "update: POST_NOTIFICATIONS permission missing, exiting")
            return
        }

        val customView = RemoteViews(context.packageName, R.layout.notification_stopwatch)
        customView.setTextViewText(R.id.notification_title, context.getString(if (kind == Kind.TIMER) R.string.widget_name_timer else R.string.widget_name))

        if (s.isRunning) {
            val value = s.valueMs()
            val realtime = SystemClock.elapsedRealtime()

            if (kind == Kind.TIMER) {
                customView.setChronometerCountDown(R.id.notification_time_text, true)
                customView.setChronometer(R.id.notification_time_text, realtime + value + 999, null, true)
            } else {
                customView.setChronometerCountDown(R.id.notification_time_text, false)
                customView.setChronometer(R.id.notification_time_text, realtime - value, null, true)
            }
        } else {
            customView.setChronometerCountDown(R.id.notification_time_text, false)
            customView.setChronometer(R.id.notification_time_text, 0L, null, false)
            customView.setTextViewText(R.id.notification_time_text, TimeFormat.format(s.valueMs(), kind))
        }

        val action = if (s.isRunning) StopwatchActionReceiver.ACTION_STOP else StopwatchActionReceiver.ACTION_START
        val iconColor = if (s.isRunning) R.color.button_bgr_color_stop else R.color.button_bgr_color_start

        customView.setImageViewResource(R.id.notification_action_button, if (s.isRunning) R.drawable.ic_stop else R.drawable.ic_play)
        customView.setInt(R.id.notification_action_button, "setColorFilter", ContextCompat.getColor(context, iconColor))
        customView.setOnClickPendingIntent(R.id.notification_action_button, StopwatchActionReceiver.pending(context, action, kind))

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(if (kind == Kind.TIMER) R.drawable.ic_stat_timer else R.drawable.ic_stat_stopwatch)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(customView)
            .setCustomBigContentView(customView)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setDeleteIntent(StopwatchActionReceiver.pending(context, StopwatchActionReceiver.ACTION_DISMISS, kind))
            .setContentIntent(StopwatchLaunch.openIntent(context, kind)) // koppintás: a megfelelő fülre

        NotificationManagerCompat.from(context).notify(notificationId(kind), builder.build())
        Log.d(TAG, "update(${kind.key}): notification sent successfully")
    }

    fun cancel(context: Context, kind: Kind) {
        Log.d(TAG, "cancel(${kind.key}): cancelling notification")
        NotificationManagerCompat.from(context).cancel(notificationId(kind))
    }
}