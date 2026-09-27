package com.szunyoghtamas.stopwatch

import com.szunyoghtamas.stopwatch.bridge.StopwatchMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val stopwatchMethodChannel = StopwatchMethodChannel()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        stopwatchMethodChannel.register(flutterEngine, this)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (!stopwatchMethodChannel.onRequestPermissionsResult(requestCode, grantResults)) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}
