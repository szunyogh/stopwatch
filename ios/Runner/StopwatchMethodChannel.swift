import Flutter
import Foundation

final class StopwatchMethodChannel: NSObject {
    static let shared = StopwatchMethodChannel()

    private static let methodChannelName = "stopwatch/native"

    func register(with registrar: FlutterPluginRegistrar) {
        NSLog("[Widget] [MethodChannel] Registering method and event channels...")
        
        let methodChannel = FlutterMethodChannel(name: Self.methodChannelName, binaryMessenger: registrar.messenger())
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("[Widget] [MethodChannel] Received call from Flutter: \(call.method)")
        
        switch call.method {
        case "getState":
            let state = StopwatchSharedState.asDictionary()
            NSLog("[Widget] [MethodChannel] getState -> returning: \(state)")
            result(state)

        case "notifyStart":
            guard let args = call.arguments as? [String: Any],
                let startedAt = args["startedAtEpochMs"] as? Int,
                let accumulated = args["accumulatedMs"] as? Int else {
                NSLog("[Widget] [MethodChannel] notifyStart failed: bad_args")
                result(FlutterError(code: "bad_args", message: "startedAtEpochMs/accumulatedMs missing", details: nil))
                return
            }
            NSLog("[Widget] [MethodChannel] notifyStart -> startedAt: \(startedAt), accumulated: \(accumulated)")
            StopwatchSharedState.start(startedAtEpochMs: startedAt, accumulatedMs: accumulated)
            Task { await StopwatchActivityController.start() }
            result(nil)

        case "notifyStop":
            guard let args = call.arguments as? [String: Any],
                let accumulated = args["accumulatedMs"] as? Int else {
                NSLog("[Widget] [MethodChannel] notifyStop failed: bad_args")
                result(FlutterError(code: "bad_args", message: "accumulatedMs missing", details: nil))
                return
            }
            NSLog("[Widget] [MethodChannel] notifyStop -> accumulated: \(accumulated)")
            StopwatchSharedState.stop(accumulatedMs: accumulated)
            Task { await StopwatchActivityController.update() }
            result(nil)

        case "notifyReset":
            NSLog("[Widget] [MethodChannel] notifyReset called")
            StopwatchSharedState.reset()
            Task { await StopwatchActivityController.end() }
            result(nil)

        default:
            NSLog("[Widget] [MethodChannel] Method not implemented: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
}
