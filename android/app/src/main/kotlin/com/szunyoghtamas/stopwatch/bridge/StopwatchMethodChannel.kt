package com.szunyoghtamas.stopwatch.bridge

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.szunyoghtamas.stopwatch.action.StopwatchActions
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.state.Kind
import com.szunyoghtamas.stopwatch.state.StopwatchLapStore
import com.szunyoghtamas.stopwatch.state.StopwatchState
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

class StopwatchMethodChannel : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL_NAME = "stopwatch/native"
        private const val EVENT_CHANNEL_NAME = "stopwatch/native_events"
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 5001
        private const val TAG = "[Widget] MethodChannel"

        private var eventSink: EventChannel.EventSink? = null

        fun pushStateUpdate(context: Context) {
            Log.d(TAG, "pushStateUpdate: sending state to Flutter")
            StopwatchState.init(context)
            val states = Kind.entries.map { StopwatchState.asMap(it) }
            Handler(Looper.getMainLooper()).post { states.forEach { eventSink?.success(it) } }
        }
    }

    private var activity: Activity? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        Log.d(TAG, "register: registering channels")
        this.activity = activity
        StopwatchState.init(activity.applicationContext)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    Log.d(TAG, "EventChannel onListen")
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "EventChannel onCancel")
                    eventSink = null
                }
            })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: called method = ${call.method}")

        val context = activity?.applicationContext
        val kind = Kind.from(call.argument<String>("kind"))

        when (call.method) {
            "getState" -> result.success(StopwatchState.asMap(kind))

            "notifyStart" -> {
                val startedAt = call.argument<Number>("startedAtEpochMs")?.toLong()
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong()
                Log.d(TAG, "notifyStart(${kind.key}) -> startedAt=$startedAt, accumulated=$accumulated")
                if (startedAt == null || accumulated == null) {
                    result.error("bad_args", "startedAtEpochMs/accumulatedMs missing", null)
                    return
                }
                context?.let { StopwatchActions.start(it, kind, startedAt, accumulated) }
                result.success(null)
            }

            "notifyStop" -> {
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong()
                Log.d(TAG, "notifyStop(${kind.key}) -> accumulated=$accumulated")
                if (accumulated == null) {
                    result.error("bad_args", "accumulatedMs missing", null)
                    return
                }
                context?.let { StopwatchActions.stop(it, kind, accumulated) }
                result.success(null)
            }

            "notifyReset" -> {
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong() ?: 0L
                Log.d(TAG, "notifyReset(${kind.key}) -> accumulated=$accumulated")
                context?.let { StopwatchActions.reset(it, kind, accumulated) }
                result.success(null)
            }

            "notifySetTimer" -> {
                val total = call.argument<Number>("totalMs")?.toLong()
                if (total == null) {
                    result.error("bad_args", "totalMs missing", null)
                    return
                }
                context?.let { StopwatchActions.setTimer(it, total) }
                result.success(null)
            }

            "notifyTimerFinished" -> {
                context?.let { StopwatchActions.onTimerExpiredInApp(it) }
                result.success(null)
            }

            "consumePendingTab" -> result.success(StopwatchLaunch.consume())

            "hasNotificationPermission" -> {
                val hasPerm = hasNotificationPermission()
                Log.d(TAG, "onMethodCall: hasNotificationPermission = $hasPerm")
                result.success(hasPerm)
            }

            "requestNotificationPermission" -> {
                Log.d(TAG, "onMethodCall: requestNotificationPermission started")
                requestNotificationPermission(result)
            }

            "canUseFullScreenIntent" -> {
                val ctx = context
                result.success(
                    ctx == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
                            ctx.getSystemService(NotificationManager::class.java).canUseFullScreenIntent(),
                )
            }

            "openFullScreenIntentSettings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    activity?.startActivity(
                        Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                            "package:${activity?.packageName}".toUri()),
                    )
                }
                result.success(null)
            }

            "getLaps" -> {
                val json = context?.let { StopwatchLapStore.get(it) }
                Log.d(TAG, "onMethodCall: getLaps -> ${json?.length ?: 0} characters")
                result.success(json)
            }

            "saveLaps" -> {
                val json = call.argument<String>("laps")
                if (json == null) {
                    result.error("bad_args", "laps missing", null)
                    return
                }
                Log.d(TAG, "onMethodCall: saveLaps -> ${json.length} characters")
                context?.let { StopwatchLapStore.save(it, json) }
                result.success(null)
            }

            else -> {
                Log.w(TAG, "onMethodCall: method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun hasNotificationPermission(): Boolean {
        val ctx = activity ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return NotificationManagerCompat.from(ctx).areNotificationsEnabled()
        return ContextCompat.checkSelfPermission(ctx, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        val act = activity ?: run {
            Log.w(TAG, "requestNotificationPermission: activity is null")
            return result.success(false)
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || hasNotificationPermission()) {
            Log.d(TAG, "requestNotificationPermission: no permission request needed (or already granted)")
            result.success(true)
            return
        }

        pendingPermissionResult = result
        Log.d(TAG, "requestNotificationPermission: showing permission request dialog")
        ActivityCompat.requestPermissions(act, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST_CODE)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "onRequestPermissionsResult: permission granted? = $granted")
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
        return true
    }
}