import Foundation
import ActivityKit

struct StopwatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startedAtEpochMs: Int?
        var accumulatedMs: Int
        var isRunning: Bool
    }
}

extension StopwatchAttributes.ContentState {
    var elapsedMs: Int {
        if isRunning, let startedAtEpochMs {
            let now = Int(Date().timeIntervalSince1970 * 1000)
            return accumulatedMs + (now - startedAtEpochMs)
        }
        return accumulatedMs
    }
}
