import Flutter
import Foundation
import UserNotifications
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
                for kind in TimeKind.allCases {
                    self?.eventSink?(StopwatchSharedState.asDictionary(kind: kind))
                }
            }
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodChannelLogger.notice("[Widget] [MethodChannel] Received call from Flutter: \(call.method)")

        let args = call.arguments as? [String: Any]
        let kind = TimeKind(rawValue: args?["kind"] as? String ?? "") ?? .stopwatch

        switch call.method {
            case "hasNotificationPermission":
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    let granted = [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus)
                    DispatchQueue.main.async { result(granted) }
                }

            case "requestNotificationPermission":
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    Task {
                        #if canImport(AlarmKit)
                            if #available(iOS 26.0, *) { await AlarmKitTimer.requestAuthorization() }
                        #endif
                            DispatchQueue.main.async { result(granted) }
                    }
                }
            case "notifyTimerFinished":
                Task { await StopwatchActions.finishTimerAlarm() }
                result(nil)
            case "getState":
                let state = StopwatchSharedState.asDictionary(kind: kind)
                methodChannelLogger.notice("[Widget] [MethodChannel] getState(\(kind.rawValue)) -> \(String(describing: state))")
                result(state)

            case "notifyStart":
                guard let startedAt = args?["startedAtEpochMs"] as? Int,
                      let accumulated = args?["accumulatedMs"] as? Int else {
                    result(FlutterError(code: "bad_args", message: "startedAtEpochMs/accumulatedMs missing", details: nil))
                    return
                }
                StopwatchSharedState.start(kind: kind, startedAtEpochMs: startedAt, accumulatedMs: accumulated)
                Task { await StopwatchActivityController.start(kind: kind) }
                result(nil)

            case "notifyStop":
                guard let accumulated = args?["accumulatedMs"] as? Int else {
                    result(FlutterError(code: "bad_args", message: "accumulatedMs missing", details: nil))
                    return
                }
                StopwatchSharedState.stop(kind: kind, accumulatedMs: accumulated)
                Task { await StopwatchActivityController.update(kind: kind) }
                result(nil)

            case "notifyReset":
                let accumulated = args?["accumulatedMs"] as? Int ?? 0
                StopwatchSharedState.reset(kind: kind, accumulatedMs: accumulated)
                if kind == .stopwatch {
                    StopwatchSharedState.clearLaps()
                }
                Task { await StopwatchActivityController.end(kind: kind) }
                result(nil)

            case "notifySetTimer":
                guard let totalMs = args?["totalMs"] as? Int else {
                    result(FlutterError(code: "bad_args", message: "totalMs missing", details: nil))
                    return
                }
                StopwatchSharedState.setTimer(totalMs: totalMs)
                Task { await StopwatchActivityController.update(kind: .timer) }
                result(nil)

            case "getLaps":
                result(StopwatchSharedState.lapsJson)

            case "saveLaps":
                guard let json = args?["laps"] as? String else {
                    result(FlutterError(code: "bad_args", message: "laps missing", details: nil))
                    return
                }
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
