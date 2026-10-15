import Foundation
import WidgetKit
import UserNotifications
import os

private let sharedStateLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "SharedState")

public enum TimeKind: String, Codable, CaseIterable {
    case stopwatch, timer
    func key(_ k: String) -> String { self == .stopwatch ? k : "timer_\(k)" }
}

enum StopwatchSharedState {
    private static let appGroupId = "group.com.szunyoghtamas.stopwatch"
    private static let widgetKind = "StopwatchHomeScreenWidget"

    private static let keyIsRunning = "isRunning"
    private static let keyStartedAt = "startedAtEpochMs"
    private static let keyAccumulated = "accumulatedMs"
    private static let keyTotal = "totalMs"
    private static let keyLaps = "laps"
    private static let keyWidgetMode = "widgetMode"

    private static var defaults: UserDefaults {
        guard let d = UserDefaults(suiteName: appGroupId) else {
            fatalError("App Group '\(appGroupId)' not configured")
        }
        return d
    }

    static var nowMs: Int { Int(Date().timeIntervalSince1970 * 1000) }

    private static func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static var lapsJson: String? { defaults.string(forKey: keyLaps) }
    static func saveLaps(_ json: String) { defaults.set(json, forKey: keyLaps) }
    static func clearLaps() { defaults.removeObject(forKey: keyLaps) }

    static func isRunning(kind: TimeKind) -> Bool { defaults.bool(forKey: kind.key(keyIsRunning)) }

    static func startedAtEpochMs(kind: TimeKind) -> Int? {
        let v = defaults.integer(forKey: kind.key(keyStartedAt))
        return v == 0 ? nil : v
    }

    static func accumulatedMs(kind: TimeKind) -> Int { defaults.integer(forKey: kind.key(keyAccumulated)) }

    static func totalMs() -> Int { defaults.integer(forKey: TimeKind.timer.key(keyTotal)) }

    static var widgetMode: TimeKind {
        TimeKind(rawValue: defaults.string(forKey: keyWidgetMode) ?? "") ?? .stopwatch
    }

    static func setWidgetMode(_ kind: TimeKind) {
        defaults.set(kind.rawValue, forKey: keyWidgetMode)
        reloadWidgets()
    }

    static func start(kind: TimeKind, startedAtEpochMs: Int, accumulatedMs: Int, fromIntent: Bool = false) {
        sharedStateLogger.notice("[Widget] [SharedState] START \(kind.rawValue) -> startedAt: \(startedAtEpochMs), accumulated: \(accumulatedMs)")
        defaults.set(true, forKey: kind.key(keyIsRunning))
        defaults.set(startedAtEpochMs, forKey: kind.key(keyStartedAt))
        defaults.set(accumulatedMs, forKey: kind.key(keyAccumulated))
        defaults.set(kind.rawValue, forKey: keyWidgetMode)

        if kind == .timer { TimerAlarm.schedule(endAtEpochMs: startedAtEpochMs + accumulatedMs) }
        if !fromIntent { reloadWidgets() }
    }

    static func stop(kind: TimeKind, accumulatedMs: Int, fromIntent: Bool = false) {
        sharedStateLogger.notice("[Widget] [SharedState] STOP \(kind.rawValue) -> accumulated: \(accumulatedMs)")
        defaults.set(false, forKey: kind.key(keyIsRunning))
        defaults.set(0, forKey: kind.key(keyStartedAt))
        defaults.set(accumulatedMs, forKey: kind.key(keyAccumulated))

        if kind == .timer { TimerAlarm.cancel() }
        if !fromIntent { reloadWidgets() }
    }

    static func reset(kind: TimeKind, accumulatedMs: Int = 0) {
        sharedStateLogger.notice("[Widget] [SharedState] RESET \(kind.rawValue) -> \(accumulatedMs)")
        defaults.set(false, forKey: kind.key(keyIsRunning))
        defaults.set(0, forKey: kind.key(keyStartedAt))
        defaults.set(accumulatedMs, forKey: kind.key(keyAccumulated))

        if kind == .timer { TimerAlarm.cancel() }
        reloadWidgets()
    }

    static func setTimer(totalMs: Int) {
        sharedStateLogger.notice("[Widget] [SharedState] SET TIMER -> \(totalMs)")
        let kind = TimeKind.timer
        defaults.set(totalMs, forKey: kind.key(keyTotal))
        defaults.set(false, forKey: kind.key(keyIsRunning))
        defaults.set(0, forKey: kind.key(keyStartedAt))
        defaults.set(totalMs, forKey: kind.key(keyAccumulated))

        TimerAlarm.cancel()
        reloadWidgets()
    }

    static func contentState(kind: TimeKind) -> StopwatchAttributes.ContentState {
        var running = isRunning(kind: kind)
        var startedAt = startedAtEpochMs(kind: kind)
        var accumulated = accumulatedMs(kind: kind)

        if kind == .timer, running, let s = startedAt, s + accumulated <= nowMs {
            running = false
            startedAt = nil
            accumulated = 0
        }

        let state = StopwatchAttributes.ContentState(startedAtEpochMs: startedAt, accumulatedMs: accumulated, isRunning: running, kind: kind)
        sharedStateLogger.notice("[Widget] [SharedState] contentState(\(kind.rawValue)) -> \(String(describing: state), privacy: .public)")
        return state
    }

    static func timerEndDate() -> Date? {
        let s = contentState(kind: .timer)
        guard s.isRunning, let started = s.startedAtEpochMs else { return nil }
        return Date(timeIntervalSince1970: Double(started + s.accumulatedMs) / 1000)
    }

    static func asDictionary(kind: TimeKind) -> [String: Any] {
        var dict: [String: Any] = [
            "kind": kind.rawValue,
            "isRunning": isRunning(kind: kind),
            "startedAtEpochMs": startedAtEpochMs(kind: kind) ?? NSNull(),
            "accumulatedMs": accumulatedMs(kind: kind),
        ]
        if kind == .timer { dict["totalMs"] = totalMs() }
        return dict
    }
}

enum TimerAlarm {
    private static let identifier = "com.szunyoghtamas.stopwatch.timerFinished"

    static func schedule(endAtEpochMs: Int) {
        let interval = Double(endAtEpochMs - StopwatchSharedState.nowMs) / 1000
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "timer_finished_title")
        content.body = String(localized: "timer_finished_body")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
