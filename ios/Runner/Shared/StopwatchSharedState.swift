import Foundation
import WidgetKit
import os

private let sharedStateLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "SharedState")

enum StopwatchSharedState {
    private static let appGroupId = "group.com.szunyogh.stopwatch"

    private static let keyIsRunning = "isRunning"
    private static let keyStartedAt = "startedAtEpochMs"
    private static let keyAccumulated = "accumulatedMs"

    private static var defaults: UserDefaults {
        guard let d = UserDefaults(suiteName: appGroupId) else {
            fatalError("App Group '\(appGroupId)' not configured")
        }
        return d
    }

    static var isRunning: Bool {
        defaults.bool(forKey: keyIsRunning)
    }

    static var startedAtEpochMs: Int? {
        let v = defaults.integer(forKey: keyStartedAt)
        return v == 0 ? nil : v
    }

    static var accumulatedMs: Int {
        defaults.integer(forKey: keyAccumulated)
    }

    static func start(startedAtEpochMs: Int, accumulatedMs: Int) {
        sharedStateLogger.notice("[Widget] [SharedState] START -> startedAt: \(startedAtEpochMs), accumulated: \(accumulatedMs)")
        defaults.set(true, forKey: keyIsRunning)
        defaults.set(startedAtEpochMs, forKey: keyStartedAt)
        defaults.set(accumulatedMs, forKey: keyAccumulated)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func stop(accumulatedMs: Int) {
        sharedStateLogger.notice("[Widget] [SharedState] STOP -> accumulated: \(accumulatedMs)")
        defaults.set(false, forKey: keyIsRunning)
        defaults.set(0, forKey: keyStartedAt)
        defaults.set(accumulatedMs, forKey: keyAccumulated)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func reset() {
        sharedStateLogger.notice("[Widget] [SharedState] RESET -> clearing data")
        defaults.set(false, forKey: keyIsRunning)
        defaults.set(0, forKey: keyStartedAt)
        defaults.set(0, forKey: keyAccumulated)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func contentState() -> StopwatchAttributes.ContentState {
        let state = StopwatchAttributes.ContentState(startedAtEpochMs: startedAtEpochMs, accumulatedMs: accumulatedMs, isRunning: isRunning)
        sharedStateLogger.notice("[Widget] [SharedState] contentState() requested -> \(String(describing: state), privacy: .public)")
        return state
    }

    static func asDictionary() -> [String: Any] {
        return [
            "isRunning": isRunning,
            "startedAtEpochMs": startedAtEpochMs as Any,
            "accumulatedMs": accumulatedMs,
        ]
    }
}
