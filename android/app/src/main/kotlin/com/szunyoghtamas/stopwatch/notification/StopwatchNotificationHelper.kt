package com.szunyoghtamas.stopwatch.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
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

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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
        StopwatchState.init(context)
        createChannel(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val isRunning = StopwatchState.isRunning
        val startedAt = StopwatchState.startedAtEpochMs
        val accumulated = StopwatchState.accumulatedMs

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Stopper")
            .setOngoing(isRunning)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (isRunning && startedAt != null) {
            val epochWhen = startedAt - accumulated
            builder
                .setUsesChronometer(true)
                .setChronometerCountDown(false)
                .setWhen(epochWhen)
                .setShowWhen(true)
                .addAction(R.drawable.ic_stop, "Leállítás", actionPendingIntent(context, StopwatchActionReceiver.ACTION_STOP))
        } else {
            builder
                .setUsesChronometer(false)
                .setContentText(formatStatic(accumulated))
                .addAction(R.drawable.ic_play, "Indítás", actionPendingIntent(context, StopwatchActionReceiver.ACTION_START))
        }

        if (Build.VERSION.SDK_INT >= 36) {
            builder.setRequestPromotedOngoing(true)
            builder.setShortCriticalText(if (isRunning) "Fut" else "Áll")
        }

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, builder.build())
    }

    //fun cancel(context: Context) = NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)

    private fun formatStatic(ms: Long): String {
        val totalSeconds = ms / 1000
        return String.format(locale = Locale.US, "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}