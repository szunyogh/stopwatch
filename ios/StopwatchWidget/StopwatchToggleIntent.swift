import AppIntents
import ActivityKit
import Foundation
import WidgetKit
import os

private let intentLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "Intent")

extension Notification.Name {
    static let stopwatchChangedFromIntent = Notification.Name("stopwatchChangedFromIntent")
}

enum StopwatchTiming {
    static var processStart: Date? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        guard sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0 else { return nil }
        let t = info.kp_proc.p_un.__p_starttime
        return Date(timeIntervalSince1970: TimeInterval(t.tv_sec) + TimeInterval(t.tv_usec) / 1_000_000)
    }

    static func sinceProcessStartMs() -> Int {
        guard let start = processStart else { return -1 }
        return Int(Date().timeIntervalSince(start) * 1000)
    }

    static func ms(since t: Date) -> Int {
        Int(Date().timeIntervalSince(t) * 1000)
    }
}

enum StopwatchActions {
    static func start(fromLiveActivity: Bool) async {
        guard !StopwatchSharedState.isRunning else {
            intentLogger.notice("[Intent] start ignored: already running")
            return
        }

        let t0 = Date()
        let nowMs = Int(t0.timeIntervalSince1970 * 1000)
        StopwatchSharedState.start(
            startedAtEpochMs: nowMs,
            accumulatedMs: StopwatchSharedState.accumulatedMs,
            fromIntent: !fromLiveActivity
        )
        intentLogger.notice("[Timing] start: state saved + widget reload requested: +\(StopwatchTiming.ms(since: t0)) ms")
        
        DarwinNotification.post()

        await StopwatchActivityController.start()
        intentLogger.notice("[Timing] start: all done: +\(StopwatchTiming.ms(since: t0)) ms")
    }

    static func stop(fromLiveActivity: Bool) async {
        guard StopwatchSharedState.isRunning else {
            intentLogger.notice("[Intent] stop ignored: not running")
            return
        }

        let t0 = Date()
        let elapsedMs = StopwatchSharedState.contentState().elapsedMs
        StopwatchSharedState.stop(accumulatedMs: elapsedMs, fromIntent: !fromLiveActivity)
        intentLogger.notice("[Timing] stop: state saved + widget reload requested: +\(StopwatchTiming.ms(since: t0)) ms")
        
        DarwinNotification.post()

        await StopwatchActivityController.update()
        intentLogger.notice("[Timing] stop: all done: +\(StopwatchTiming.ms(since: t0)) ms")
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
        let t0 = Date()
        intentLogger.notice("[Timing] Start perform BEGIN | process: \(ProcessInfo.processInfo.processName, privacy: .public) | since process start: \(StopwatchTiming.sinceProcessStartMs()) ms")
        await StopwatchActions.start(fromLiveActivity: fromLiveActivity)
        intentLogger.notice("[Timing] Start perform END | took: \(StopwatchTiming.ms(since: t0)) ms")
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
        let t0 = Date()
        intentLogger.notice("[Timing] Stop perform BEGIN | process: \(ProcessInfo.processInfo.processName, privacy: .public) | since process start: \(StopwatchTiming.sinceProcessStartMs()) ms")
        await StopwatchActions.stop(fromLiveActivity: fromLiveActivity)
        intentLogger.notice("[Timing] Stop perform END | took: \(StopwatchTiming.ms(since: t0)) ms")
        return .result()
    }
}
