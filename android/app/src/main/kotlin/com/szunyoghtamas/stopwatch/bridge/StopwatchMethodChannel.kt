package com.szunyoghtamas.stopwatch.bridge

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
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
        private const val TAG = "[Widget] MethodChannel"

        private var eventSink: EventChannel.EventSink? = null

        fun pushStateUpdate(context: Context) {
            Log.d(TAG, "pushStateUpdate: Állapot küldése a Flutternek")
            StopwatchState.init(context)
            val state = StopwatchState.asMap()
            Handler(Looper.getMainLooper()).post { eventSink?.success(state) }
        }
    }

    private var activity: Activity? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        Log.d(TAG, "register: Csatornák regisztrálása")
        this.activity = activity
        StopwatchState.init(activity.applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler(this)

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
        Log.d(TAG, "onMethodCall: Hívott metódus = ${call.method}")
        when (call.method) {
            "getState" -> {
                Log.d(TAG, "onMethodCall: getState lekérve")
                result.success(StopwatchState.asMap())
            }

            "notifyStart" -> {
                val startedAt = call.argument<Number>("startedAtEpochMs")?.toLong()
                val accumulated = call.argument<Number>("accumulatedMs")?.toLong()
                Log.d(TAG, "onMethodCall: notifyStart -> startedAt=$startedAt, accumulated=$accumulated")
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
                Log.d(TAG, "onMethodCall: notifyStop -> accumulated=$accumulated")
                if (accumulated == null) {
                    result.error("bad_args", "accumulatedMs missing", null)
                    return
                }
                StopwatchState.stop(accumulated)
                activity?.applicationContext?.let { StopwatchSurfaces.refresh(it) }
                result.success(null)
            }

            "notifyReset" -> {
                Log.d(TAG, "onMethodCall: notifyReset")
                StopwatchState.reset()
                activity?.applicationContext?.let { StopwatchSurfaces.refresh(it, true) }
                result.success(null)
            }

            "hasNotificationPermission" -> {
                val hasPerm = hasNotificationPermission()
                Log.d(TAG, "onMethodCall: hasNotificationPermission = $hasPerm")
                result.success(hasPerm)
            }

            "requestNotificationPermission" -> {
                Log.d(TAG, "onMethodCall: requestNotificationPermission indítva")
                requestNotificationPermission(result)
            }

            else -> {
                Log.w(TAG, "onMethodCall: Nem implementált metódus: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun hasNotificationPermission(): Boolean {
        val ctx = activity ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(ctx, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        val act = activity ?: run {
            Log.w(TAG, "requestNotificationPermission: Activity null")
            return result.success(false)
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || hasNotificationPermission()) {
            Log.d(TAG, "requestNotificationPermission: Nincs szükség engedélykérésre (vagy már megvan)")
            result.success(true)
            return
        }

        pendingPermissionResult = result
        Log.d(TAG, "requestNotificationPermission: Engedélykérő dialog megjelenítése")
        ActivityCompat.requestPermissions(act, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST_CODE)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "onRequestPermissionsResult: Engedély megadva? = $granted")
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
        return true
    }
}
