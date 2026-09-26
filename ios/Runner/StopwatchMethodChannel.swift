import Flutter
import Foundation
import StopwatchCore
import os

private let methodChannelLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "MethodChannel")

final class StopwatchMethodChannel: NSObject {
    static let shared = StopwatchMethodChannel()

    private static let methodChannelName = "stopwatch/native"
    private static let eventChannelName = "stopwatch/native_events"

    private var eventSink: FlutterEventSink?
    private var darwinObserver: DarwinNotificationObserver?

    func register(with registrar: FlutterPluginRegistrar) {
        methodChannelLogger.notice("[Widget] Registering method and event channels...")
        
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
        methodChannelLogger.notice("[Widget] Received call from Flutter: \(call.method)")
        
        switch call.method {
        case "getState":
            let state = StopwatchSharedState.asDictionary()
            methodChannelLogger.notice("[Widget] getState -> returning: \(String(describing: state))")
            result(state)

        case "notifyStart":
            guard let args = call.arguments as? [String: Any],
                let startedAt = args["startedAtEpochMs"] as? Int,
                let accumulated = args["accumulatedMs"] as? Int else {
                methodChannelLogger.error("[Widget] notifyStart failed: bad_args")
                result(FlutterError(code: "bad_args", message: "startedAtEpochMs/accumulatedMs missing", details: nil))
                return
            }
            methodChannelLogger.notice("[Widget] notifyStart -> startedAt: \(startedAt), accumulated: \(accumulated)")
            StopwatchSharedState.start(startedAtEpochMs: startedAt, accumulatedMs: accumulated)
            Task { await StopwatchActivityController.start() }
            result(nil)

        case "notifyStop":
            guard let args = call.arguments as? [String: Any],
                let accumulated = args["accumulatedMs"] as? Int else {
                methodChannelLogger.error("[Widget] notifyStop failed: bad_args")
                result(FlutterError(code: "bad_args", message: "accumulatedMs missing", details: nil))
                return
            }
            methodChannelLogger.notice("[Widget] notifyStop -> accumulated: \(accumulated)")
            StopwatchSharedState.stop(accumulatedMs: accumulated)
            Task { await StopwatchActivityController.update() }
            result(nil)

        case "notifyReset":
            methodChannelLogger.notice("[Widget] notifyReset called")
            StopwatchSharedState.reset()
            Task { await StopwatchActivityController.end() }
            result(nil)

        default:
            methodChannelLogger.error("[Widget] Method not implemented: \(call.method)")
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
