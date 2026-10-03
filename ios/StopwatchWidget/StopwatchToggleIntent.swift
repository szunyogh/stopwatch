import AppIntents
import ActivityKit
import Foundation
import WidgetKit
import os

private let intentLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "Intent")

extension Notification.Name {
    static let stopwatchChangedFromIntent = Notification.Name("stopwatchChangedFromIntent")
}

enum StopwatchActions {
    static func start(fromLiveActivity: Bool) async {
        guard !StopwatchSharedState.isRunning else {
            intentLogger.notice("[Widget] [Intent] start ignored: already running")
            return
        }

        let nowMs = Int(Date().timeIntervalSince1970 * 1000)
        let accumulatedMs = StopwatchSharedState.accumulatedMs

        intentLogger.notice("[Widget] [Intent] start -> startedAt: \(nowMs), accumulated: \(accumulatedMs), fromLiveActivity: \(fromLiveActivity)")

        StopwatchSharedState.start(
            startedAtEpochMs: nowMs,
            accumulatedMs: accumulatedMs,
            fromIntent: !fromLiveActivity
        )

        DarwinNotification.post()

        await StopwatchActivityController.start()

        intentLogger.notice("[Widget] [Intent] start done")
    }

    static func stop(fromLiveActivity: Bool) async {
        guard StopwatchSharedState.isRunning else {
            intentLogger.notice("[Widget] [Intent] stop ignored: not running")
            return
        }

        let elapsedMs = StopwatchSharedState.contentState().elapsedMs

        intentLogger.notice("[Widget] [Intent] stop -> accumulated: \(elapsedMs), fromLiveActivity: \(fromLiveActivity)")

        StopwatchSharedState.stop(accumulatedMs: elapsedMs, fromIntent: !fromLiveActivity)

        DarwinNotification.post()

        await StopwatchActivityController.update()

        intentLogger.notice("[Widget] [Intent] stop done")
    }
}

struct StopwatchStartIntent: AppIntent {
    static let title: LocalizedStringResource = "Stopperóra indítása"
    static var isDiscoverable: Bool { false }
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Live Activityből", default: false)
    var fromLiveActivity: Bool

    init() {}

    init(fromLiveActivity: Bool) {
        self.fromLiveActivity = fromLiveActivity
    }

    func perform() async throws -> some IntentResult {
        intentLogger.notice("[Widget] [Intent] StartIntent perform called")

        await StopwatchActions.start(fromLiveActivity: fromLiveActivity)

        return .result()
    }
}

struct StopwatchStopIntent: AppIntent {
    static let title: LocalizedStringResource = "Stopperóra leállítása"
    static var isDiscoverable: Bool { false }
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Live Activityből", default: false)
    var fromLiveActivity: Bool

    init() {}

    init(fromLiveActivity: Bool) {
        self.fromLiveActivity = fromLiveActivity
    }

    func perform() async throws -> some IntentResult {
        intentLogger.notice("[Widget] [Intent] StopIntent perform called")

        await StopwatchActions.stop(fromLiveActivity: fromLiveActivity)

        return .result()
    }
}