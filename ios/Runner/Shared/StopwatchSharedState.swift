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

    static func reloadWidgets() {
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

    static func contentState(kind: TimeKind, asOf date: Date = Date()) -> StopwatchAttributes.ContentState {
        let running = isRunning(kind: kind)
        let startedAt = startedAtEpochMs(kind: kind)
        let accumulated = accumulatedMs(kind: kind)
        let total: Int? = kind == .timer ? totalMs() : nil

        if kind == .timer, running, let s = startedAt, s + accumulated <= Int(date.timeIntervalSince1970 * 1000) {
            return .init(startedAtEpochMs: nil, accumulatedMs: total ?? 0, isRunning: false, kind: .timer, totalMs: total)
        }
        return .init(startedAtEpochMs: startedAt, accumulatedMs: accumulated, isRunning: running, kind: kind, totalMs: total)
    }
    
    @discardableResult
    static func settleExpiredTimer() -> Bool {
        let kind = TimeKind.timer
        guard isRunning(kind: kind),
              let s = startedAtEpochMs(kind: kind),
              s + accumulatedMs(kind: kind) <= nowMs else { return false }

        sharedStateLogger.notice("[Widget] [SharedState] SETTLE expired timer -> reset to \(totalMs())")
        defaults.set(false, forKey: kind.key(keyIsRunning))
        defaults.set(0, forKey: kind.key(keyStartedAt))
        defaults.set(totalMs(), forKey: kind.key(keyAccumulated))
        return true
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
