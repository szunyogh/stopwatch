import Foundation

enum TimeFormat {
    static func stopwatch(ms: Int, showMilliseconds: Bool, kind: TimeKind) -> String {
        let total = max(0, ms)

        if kind == .stopwatch {
            let hours = total / 3_600_000
            let minutes = (total / 60_000) % 60
            let seconds = (total / 1000) % 60
            let hundredths = (total % 1000) / 10
            
            switch (hours > 0, showMilliseconds) {
                case (true, true): return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, hundredths)
                case (true, false): return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                case (false, true): return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
                case (false, false): return String(format: "%02d:%02d", minutes, seconds)
            }
        } else {
            let totalSeconds = (total + 999) / 1000
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds / 60) % 60
            let seconds = totalSeconds % 60

            if hours > 0 {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
}
