package com.szunyoghtamas.stopwatch.bridge

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.szunyoghtamas.stopwatch.notification.StopwatchNotificationHelper
import com.szunyoghtamas.stopwatch.state.StopwatchState
import com.szunyoghtamas.stopwatch.state.StopwatchSurfaces
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class StopwatchMethodChannel : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL_NAME = "stopwatch/native"
        private const val EVENT_CHANNEL_NAME = "stopwatch/native_events"
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 5001

        private var eventSink: EventChannel.EventSink? = null

        fun pushStateUpdate(context: Context) {
            StopwatchState.init(context)
            val state = StopwatchState.asMap()
            Handler(Looper.getMainLooper()).post { eventSink?.success(state) }
        }
    }

    private var activity: Activity? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        this.activity = activity
        StopwatchState.init(activity.applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) { eventSink = events }
                override fun onCancel(arguments: Any?) { eventSink = null }
            })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getState" -> result.success(StopwatchState.asMap())

            "notifyStart" -> {
                val startedAt = call.argument<Number>("startedAtEpochMs")?.toLong()
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong()
                if (startedAt == null || accumulated == null) {
                    result.error("bad_args", "startedAtEpochMs/accumulatedMs missing", null)
                    return
                }
                StopwatchState.start(startedAt, accumulated)
                activity?.applicationContext?.let { StopwatchSurfaces.refresh(it) }
                result.success(null)
            }

            "notifyStop" -> {
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong()
                if (accumulated == null) {
                    result.error("bad_args", "accumulatedMs missing", null)
                    return
                }
                StopwatchState.stop(accumulated)
                activity?.applicationContext?.let { StopwatchSurfaces.refresh(it) }
                result.success(null)
            }

            "notifyReset" -> {
                StopwatchState.reset()
                activity?.applicationContext?.let {
                    StopwatchNotificationHelper.update(it)
                    StopwatchSurfaces.refresh(it)
                }
                result.success(null)
            }

            "hasNotificationPermission" -> result.success(hasNotificationPermission())

            "requestNotificationPermission" -> requestNotificationPermission(result)

            else -> result.notImplemented()
        }
    }

    private fun hasNotificationPermission(): Boolean {
        val ctx = activity ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(ctx, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        val act = activity ?: return result.success(false)

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || hasNotificationPermission()) {
            result.success(true)
            return
        }

        pendingPermissionResult = result
        ActivityCompat.requestPermissions(act, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST_CODE)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
        return true
    }
}