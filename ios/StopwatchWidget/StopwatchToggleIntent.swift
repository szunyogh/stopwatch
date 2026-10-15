import AppIntents
import ActivityKit
import Foundation
import WidgetKit
import os

private let intentLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "Intent")

enum StopwatchActions {
    static func start(kind: TimeKind, fromLiveActivity: Bool) async {
        let current = StopwatchSharedState.contentState(kind: kind)
        guard !current.isRunning else {
            intentLogger.notice("[Widget] [Intent] start(\(kind.rawValue)) ignored: already running")
            return
        }

        var accumulatedMs = current.accumulatedMs
        if kind == .timer {
            if accumulatedMs <= 0 { accumulatedMs = StopwatchSharedState.totalMs() }
            guard accumulatedMs > 0 else { return }
        }

        let nowMs = StopwatchSharedState.nowMs
        intentLogger.notice("[Widget] [Intent] start(\(kind.rawValue)) -> startedAt: \(nowMs), accumulated: \(accumulatedMs)")

        StopwatchSharedState.start(kind: kind, startedAtEpochMs: nowMs, accumulatedMs: accumulatedMs, fromIntent: !fromLiveActivity)
        DarwinNotification.post()
        await StopwatchActivityController.start(kind: kind)
    }

    static func stop(kind: TimeKind, fromLiveActivity: Bool) async {
        let current = StopwatchSharedState.contentState(kind: kind)
        guard current.isRunning else {
            intentLogger.notice("[Widget] [Intent] stop(\(kind.rawValue)) ignored: not running")
            return
        }

        let valueMs = current.valueMs
        intentLogger.notice("[Widget] [Intent] stop(\(kind.rawValue)) -> accumulated: \(valueMs)")

        StopwatchSharedState.stop(kind: kind, accumulatedMs: valueMs, fromIntent: !fromLiveActivity)
        DarwinNotification.post()
        await StopwatchActivityController.update(kind: kind)
    }
    
    static func finishTimerAlarm() async {
        let expired = StopwatchSharedState.settleExpiredTimer()

        guard expired || !StopwatchSharedState.isRunning(kind: .timer) else { return }

        LegacyAlarm.cancel()
        StopwatchSharedState.reloadWidgets()
        await StopwatchActivityController.end(kind: .timer)
    }
}

struct StopwatchStartIntent: AppIntent {
    static let title: LocalizedStringResource = "Start stopwatch"
    static var isDiscoverable: Bool { false }
    static var openAppWhenRun: Bool = true

    @Parameter(title: "From Live Activity", default: false)
    var fromLiveActivity: Bool

    @Parameter(title: "Kind", default: "stopwatch")
    var kindRaw: String

    init() {}

    init(fromLiveActivity: Bool, kind: TimeKind = .stopwatch) {
        self.fromLiveActivity = fromLiveActivity
        self.kindRaw = kind.rawValue
    }

    init(kind: TimeKind) {
        self.fromLiveActivity = false
        self.kindRaw = kind.rawValue
    }

    func perform() async throws -> some IntentResult {
        let kind = TimeKind(rawValue: kindRaw) ?? .stopwatch
        await StopwatchActions.start(kind: kind, fromLiveActivity: fromLiveActivity)
        await StopwatchLaunch.open(kind)
        return .result()
    }
}

struct StopwatchStopIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop stopwatch"
    static var isDiscoverable: Bool { false }
    static var openAppWhenRun: Bool = true

    @Parameter(title: "From Live Activity", default: false)
    var fromLiveActivity: Bool

    @Parameter(title: "Kind", default: "stopwatch")
    var kindRaw: String

    init() {}

    init(fromLiveActivity: Bool, kind: TimeKind = .stopwatch) {
        self.fromLiveActivity = fromLiveActivity
        self.kindRaw = kind.rawValue
    }

    init(kind: TimeKind) {
        self.fromLiveActivity = false
        self.kindRaw = kind.rawValue
    }

    func perform() async throws -> some IntentResult {
        let kind = TimeKind(rawValue: kindRaw) ?? .stopwatch
        await StopwatchActions.stop(kind: kind, fromLiveActivity: fromLiveActivity)
        await StopwatchLaunch.open(kind)
        return .result()
    }
}

struct ToggleWidgetModeIntent: AppIntent {
    static let title: LocalizedStringResource = "Switch widget view"
    static var isDiscoverable: Bool { false }
    static let openAppWhenRun = false

    init() {}

    func perform() async throws -> some IntentResult {
        let next: TimeKind = StopwatchSharedState.widgetMode == .stopwatch ? .timer : .stopwatch
        StopwatchSharedState.setWidgetMode(next)
        return .result()
    }
}

@available(iOS 26.0, *)
struct TimerAlarmStopIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop timer alarm"
    static var isDiscoverable: Bool { false }

    init() {}

    func perform() async throws -> some IntentResult {
        await StopwatchActions.finishTimerAlarm()
        return .result()
    }
}
