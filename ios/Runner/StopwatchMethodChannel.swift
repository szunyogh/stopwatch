//
//  StopwatchMethodChannel.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import Flutter
import Foundation

final class StopwatchMethodChannel: NSObject {
    static let shared = StopwatchMethodChannel()

    private static let methodChannelName = "stopwatch/native"
    private static let eventChannelName = "stopwatch/native_events"

    private var eventSink: FlutterEventSink?
    private var darwinObserver: DarwinNotificationObserver?

    func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: Self.methodChannelName, binaryMessenger: registrar.messenger())
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        let eventChannel = FlutterEventChannel(name: Self.eventChannelName, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(self)

        darwinObserver = DarwinNotificationObserver { [weak self] in
            self?.eventSink?(StopwatchSharedState.asDictionary())
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getState":
            result(StopwatchSharedState.asDictionary())

        case "notifyStart":
            guard let args = call.arguments as? [String: Any],
                let startedAt = args["startedAtEpochMs"] as? Int,
                let accumulated = args["accumulatedMs"] as? Int else {
                result(FlutterError(code: "bad_args", message: "startedAtEpochMs/accumulatedMs missing", details: nil))
                return
            }
            StopwatchSharedState.start(startedAtEpochMs: startedAt, accumulatedMs: accumulated)
            Task { await StopwatchActivityController.start() }
            result(nil)

        case "notifyStop":
            guard let args = call.arguments as? [String: Any],
                let accumulated = args["accumulatedMs"] as? Int else {
                result(FlutterError(code: "bad_args", message: "accumulatedMs missing", details: nil))
                return
            }
            StopwatchSharedState.stop(accumulatedMs: accumulated)
            Task { await StopwatchActivityController.update() }
            result(nil)

        case "notifyReset":
            StopwatchSharedState.reset()
            Task { await StopwatchActivityController.end() }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension StopwatchMethodChannel: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
