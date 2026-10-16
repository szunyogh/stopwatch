package com.szunyoghtamas.stopwatch.alarm

import android.app.Activity
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces

object TimerAlarm {
    private const val CHANNEL_ID = "timer_alarm_channel"
    private const val NOTIFICATION_ID = 2001
    private const val REQUEST_FIRE = 3001
    private const val REQUEST_FULL_SCREEN = 3002
    private const val TAG = "[Widget] TimerAlarm"

    private fun firePendingIntent(context: Context) = PendingIntent.getBroadcast(
        context, REQUEST_FIRE, Intent(context, TimerAlarmReceiver::class.java),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    fun schedule(context: Context, endAtEpochMs: Long) {
        StopwatchState.init(context)
        unschedule(context)
        if (endAtEpochMs <= StopwatchState.now()) return

        Log.d(TAG, "schedule: end=$endAtEpochMs")
        StopwatchState.alarmEndAt = endAtEpochMs
        context.getSystemService(AlarmManager::class.java).setAlarmClock(
            AlarmManager.AlarmClockInfo(endAtEpochMs, StopwatchLaunch.openIntent(context, Kind.TIMER)),
            firePendingIntent(context),
        )
    }

    private fun unschedule(context: Context) {
        context.getSystemService(AlarmManager::class.java).cancel(firePendingIntent(context))
        StopwatchState.alarmEndAt = 0L
    }

    fun cancel(context: Context) {
        StopwatchState.init(context)
        unschedule(context)
        dismiss(context)
    }

    fun dismiss(context: Context) {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
        TimerAlarmActivity.current?.finish()
    }

    fun onFired(context: Context) {
        StopwatchState.init(context)

        if (StopwatchState.alarmEndAt == 0L) {
            Log.d(TAG, "onFired: ignored, alarm was cancelled")
            return
        }
        StopwatchState.alarmEndAt = 0L

        StopwatchState.settleExpiredTimer()
        showAlarm(context)
        StopwatchSurfaces.refresh(context)
        StopwatchMethodChannel.pushStateUpdate(context)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(CHANNEL_ID, context.getString(R.string.notification_channel_alarm), NotificationManager.IMPORTANCE_HIGH).apply {
            setSound(
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
                AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ALARM).setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build(),
            )
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 800, 400, 800, 400, 800)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun showAlarm(context: Context) {
        val nm = NotificationManagerCompat.from(context)
        if (!nm.areNotificationsEnabled()) {
            Log.w(TAG, "showAlarm: notifications disabled")
            return
        }
        ensureChannel(context)

        val fullScreen = PendingIntent.getActivity(
            context, REQUEST_FULL_SCREEN,
            Intent(context, TimerAlarmActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_timer)
            .setContentTitle(context.getString(R.string.timer_finished_title))
            .setContentText(context.getString(R.string.timer_finished_body))
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(fullScreen, true)
            .setContentIntent(StopwatchLaunch.openIntent(context, Kind.TIMER, dismissAlarm = true))
            .addAction(0, context.getString(R.string.timer_finished_stop), StopwatchActionReceiver.pending(context, StopwatchActionReceiver.ACTION_DISMISS_ALARM, Kind.TIMER))
            .setOngoing(true)
            .setTimeoutAfter(10 * 60 * 1000L)
            .build()
            .apply { flags = flags or Notification.FLAG_INSISTENT }

        try {
            nm.notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            Log.w(TAG, "showAlarm: POST_NOTIFICATIONS permission missing")
        }
    }
}

class TimerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = TimerAlarm.onFired(context)
}

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        StopwatchState.init(context)

        val end = StopwatchState.alarmEndAt
        if (end != 0L) {
            if (end > StopwatchState.now()) {
                TimerAlarm.schedule(context, end)
            } else {
                StopwatchState.alarmEndAt = 0L
                StopwatchState.settleExpiredTimer()
            }
        }
        StopwatchSurfaces.refresh(context)
    }
}

class TimerAlarmActivity : Activity() {
    companion object {
        var current: TimerAlarmActivity? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        current = this

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val title = TextView(this).apply {
            text = getString(R.string.timer_finished_title)
            textSize = 36f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        val stop = Button(this).apply {
            text = getString(R.string.timer_finished_stop)
            textSize = 22f
            setOnClickListener {
                TimerAlarm.dismiss(this@TimerAlarmActivity)
                finish()
            }
        }

        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(0xFFB3261E.toInt())
                setPadding(64, 64, 64, 64)
                addView(title, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
                addView(stop, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 220))
            },
        )
    }

    override fun onDestroy() {
        if (current === this) current = null
        super.onDestroy()
    }
}