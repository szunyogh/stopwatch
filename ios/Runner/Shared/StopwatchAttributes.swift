import Foundation
import ActivityKit

struct StopwatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startedAtEpochMs: Int?
        var accumulatedMs: Int
        var isRunning: Bool
        var kind: TimeKind = .stopwatch
    }
}

extension StopwatchAttributes.ContentState {
    private var sinceStartMs: Int {
        guard isRunning, let startedAtEpochMs else { return 0 }
        return Int(Date().timeIntervalSince1970 * 1000) - startedAtEpochMs
    }

    var valueMs: Int {
        switch kind {
        case .stopwatch: return accumulatedMs + sinceStartMs
        case .timer: return max(0, accumulatedMs - sinceStartMs)
        }
    }

    var elapsedMs: Int { valueMs }

    var endDate: Date? {
        guard kind == .timer, isRunning, let startedAtEpochMs else { return nil }
        return Date(timeIntervalSince1970: Double(startedAtEpochMs + accumulatedMs) / 1000)
    }
}
