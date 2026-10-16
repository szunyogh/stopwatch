package com.szunyoghtamas.stopwatch

import android.content.Intent
import android.os.Bundle
import com.szunyoghtamas.stopwatch.action.StopwatchLaunch
import com.szunyoghtamas.stopwatch.alarm.TimerAlarm
import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val stopwatchMethodChannel = StopwatchMethodChannel()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        stopwatchMethodChannel.register(flutterEngine, this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleLaunchIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLaunchIntent(intent)
    }

    private fun handleLaunchIntent(intent: Intent?) {
        intent ?: return

        if (intent.getBooleanExtra(StopwatchLaunch.EXTRA_DISMISS_ALARM, false)) {
            intent.removeExtra(StopwatchLaunch.EXTRA_DISMISS_ALARM)
            TimerAlarm.dismiss(this) // az értesítésre koppintás elnémítja a szóló jelzést
        }

        intent.getStringExtra(StopwatchLaunch.EXTRA_TAB)?.let { tab ->
            intent.removeExtra(StopwatchLaunch.EXTRA_TAB) // elforgatásnál ne ismétlődjön
            StopwatchLaunch.deliver(tab)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (!stopwatchMethodChannel.onRequestPermissionsResult(requestCode, grantResults)) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}