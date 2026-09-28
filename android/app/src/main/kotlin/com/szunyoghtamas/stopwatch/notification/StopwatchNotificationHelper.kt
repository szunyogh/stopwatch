package com.szunyoghtamas.stopwatch.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
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
import com.szunyoghtamas.stopwatch.state.StopwatchState
import java.util.Locale

object StopwatchNotificationHelper {
    private const val CHANNEL_ID = "stopwatch_channel"
    private const val NOTIFICATION_ID = 1001
    private const val TAG = "[Widget] NotifHelper"

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "createChannel: Értesítési csatorna létrehozása (ha még nincs)")
            val channel = NotificationChannel(CHANNEL_ID, "Stopper", NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) }
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun actionPendingIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, StopwatchActionReceiver::class.java).apply { this.action = action }
        return PendingIntent.getBroadcast(
            context, action.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun update(context: Context) {
        Log.d(TAG, "update: Értesítés frissítése indítva")
        StopwatchState.init(context)
        createChannel(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "update: Nincs POST_NOTIFICATIONS engedély, kilépés")
            return
        }

        val isRunning = StopwatchState.isRunning
        val startedAt = StopwatchState.startedAtEpochMs
        val accumulated = StopwatchState.accumulatedMs

        Log.d(TAG, "update: Állapot -> isRunning=$isRunning, startedAt=$startedAt, acc=$accumulated")

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val launchPendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                context, 0, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val customView = RemoteViews(context.packageName, R.layout.notification_stopwatch)

        if (isRunning && startedAt != null) {
            val epochWhen = startedAt - accumulated
            val elapsedSinceEpochWhen = System.currentTimeMillis() - epochWhen
            val base = SystemClock.elapsedRealtime() - elapsedSinceEpochWhen
            Log.d(TAG, "update: Értesítés futó állapotban (Chronometer mód), base=$base")
            customView.setChronometer(R.id.widget_time_text, base, null, true)
        } else {
            val timeString = formatStatic(accumulated)
            Log.d(TAG, "update: Értesítés álló állapotban, mutatott idő=$timeString")
            customView.setChronometer(R.id.widget_time_text, 0L, null, false)
            customView.setTextViewText(R.id.widget_time_text, timeString)
        }

        val action = if (isRunning) StopwatchActionReceiver.ACTION_STOP else StopwatchActionReceiver.ACTION_START
        customView.setImageViewResource(R.id.widget_action_button, if (isRunning) R.drawable.ic_stop else R.drawable.ic_play)
        customView.setOnClickPendingIntent(R.id.widget_action_button, actionPendingIntent(context, action))

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(customView)
            .setCustomBigContentView(customView)
            .setOngoing(isRunning)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setDeleteIntent(actionPendingIntent(context, StopwatchActionReceiver.ACTION_DISMISS))

        launchPendingIntent?.let { builder.setContentIntent(it) }

        if (Build.VERSION.SDK_INT >= 36) {
            builder.setRequestPromotedOngoing(true)
            builder.setShortCriticalText(if (isRunning) "Fut" else "Áll")
        }

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, builder.build())
        Log.d(TAG, "update: Értesítés sikeresen elküldve")
    }

    fun cancel(context: Context) {
        Log.d(TAG, "cancel: Értesítés törlése")
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }

    private fun formatStatic(ms: Long): String {
        val totalSeconds = ms / 1000
        return String.format(locale = Locale.US, "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
