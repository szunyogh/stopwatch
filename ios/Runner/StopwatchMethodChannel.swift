import Flutter
import Foundation
import os

private let methodChannelLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "MethodChannel")

final class StopwatchMethodChannel: NSObject {
    static let shared = StopwatchMethodChannel()

    private static let methodChannelName = "stopwatch/native"
    private static let eventChannelName = "stopwatch/native_events"

    private var eventSink: FlutterEventSink?
    private var darwinObserver: DarwinNotificationObserver?

    func register(with registrar: FlutterPluginRegistrar) {
        methodChannelLogger.notice("[Widget] [MethodChannel] Registering method and event channels...")

        let methodChannel = FlutterMethodChannel(name: Self.methodChannelName, binaryMessenger: registrar.messenger())
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        let eventChannel = FlutterEventChannel(name: Self.eventChannelName, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(self)

        darwinObserver = DarwinNotificationObserver { [weak self] in
            DispatchQueue.main.async {
                self?.eventSink?(StopwatchSharedState.asDictionary())
            }
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodChannelLogger.notice("[Widget] [MethodChannel] Received call from Flutter: \(call.method)")

        switch call.method {
        case "getState":
            let state = StopwatchSharedState.asDictionary()
            methodChannelLogger.notice("[Widget] [MethodChannel] getState -> returning: \(String(describing: state))")
            result(state)

        case "notifyStart":
            guard let args = call.arguments as? [String: Any],
                  let startedAt = args["startedAtEpochMs"] as? Int,
                  let accumulated = args["accumulatedMs"] as? Int else {
                methodChannelLogger.error("[Widget] [MethodChannel] notifyStart failed: bad_args")
                result(FlutterError(code: "bad_args", message: "startedAtEpochMs/accumulatedMs missing", details: nil))
                return
            }
            methodChannelLogger.notice("[Widget] [MethodChannel] notifyStart -> startedAt: \(startedAt), accumulated: \(accumulated)")
            StopwatchSharedState.start(startedAtEpochMs: startedAt, accumulatedMs: accumulated)
            Task { await StopwatchActivityController.start() }
            result(nil)

        case "notifyStop":
            guard let args = call.arguments as? [String: Any],
                  let accumulated = args["accumulatedMs"] as? Int else {
                methodChannelLogger.error("[Widget] [MethodChannel] notifyStop failed: bad_args")
                result(FlutterError(code: "bad_args", message: "accumulatedMs missing", details: nil))
                return
            }
            methodChannelLogger.notice("[Widget] [MethodChannel] notifyStop -> accumulated: \(accumulated)")
            StopwatchSharedState.stop(accumulatedMs: accumulated)
            Task { await StopwatchActivityController.update() }
            result(nil)

        case "notifyReset":
            methodChannelLogger.notice("[Widget] [MethodChannel] notifyReset called")
            StopwatchSharedState.reset()
            StopwatchSharedState.clearLaps()
            Task { await StopwatchActivityController.end() }
            result(nil)

        case "getLaps":
            let json = StopwatchSharedState.lapsJson
            methodChannelLogger.notice("[Widget] [MethodChannel] getLaps -> \(json?.count ?? 0) characters")
            result(json)

        case "saveLaps":
            guard let args = call.arguments as? [String: Any],
                  let json = args["laps"] as? String else {
                methodChannelLogger.error("[Widget] [MethodChannel] saveLaps failed: bad_args")
                result(FlutterError(code: "bad_args", message: "laps missing", details: nil))
                return
            }
            methodChannelLogger.notice("[Widget] [MethodChannel] saveLaps -> \(json.count) characters")
            StopwatchSharedState.saveLaps(json)
            result(nil)

        default:
            methodChannelLogger.error("[Widget] [MethodChannel] Method not implemented: \(call.method)")
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
