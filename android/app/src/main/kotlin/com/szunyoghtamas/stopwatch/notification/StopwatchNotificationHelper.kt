package com.szunyoghtamas.stopwatch.notification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
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
            val channel = NotificationChannel(CHANNEL_ID, "Stopper", NotificationManager.IMPORTANCE_DEFAULT)
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

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(if (isRunning) R.drawable.ic_play else R.drawable.ic_stop)
            .setContentTitle("Stopper")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setDeleteIntent(actionPendingIntent(context, StopwatchActionReceiver.ACTION_DISMISS))
            .setContentIntent(launchPendingIntent)

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
            if(!isRunning) builder.setShortCriticalText(formatStatic(accumulated))
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
