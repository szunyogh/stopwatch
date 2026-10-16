package com.szunyoghtamas.stopwatch.alarm

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.app.Activity
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Button
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.szunyoghtamas.stopwatch.R
import com.szunyoghtamas.stopwatch.action.StopwatchActionReceiver
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces
import androidx.core.net.toUri

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

        val alarmManager = context.getSystemService(AlarmManager::class.java)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "schedule: missing SCHEDULE_EXACT_ALARM permission!")

                val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = "package:${context.packageName}".toUri()
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                return
            }
        }

        Log.d(TAG, "schedule: end=$endAtEpochMs")
        StopwatchState.alarmEndAt = endAtEpochMs
        alarmManager.setAlarmClock(
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
        StopwatchMethodChannel.pushStateUpdate(context, Kind.TIMER)
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

        setContentView(R.layout.activity_timer_alarm)

        startPulseAnimation(findViewById(R.id.pulse_1), 0L)
        startPulseAnimation(findViewById(R.id.pulse_2), 800L)
        startPulseAnimation(findViewById(R.id.pulse_3), 1600L)


        findViewById<Button>(R.id.btn_alarm_stop).setOnClickListener {
            TimerAlarm.dismiss(this@TimerAlarmActivity)
            finish()
        }
    }

    private fun startPulseAnimation(view: View, delay: Long) {
        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, 3.5f).apply {
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
        }
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, 3.5f).apply {
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
        }

        val alpha = ObjectAnimator.ofFloat(view, "alpha", 1f, 0f).apply {
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.RESTART
        }

        AnimatorSet().apply {
            playTogether(scaleX, scaleY, alpha)
            duration = 2400L
            startDelay = delay
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
    }


    override fun onDestroy() {
        if (current === this) current = null
        super.onDestroy()
    }
}