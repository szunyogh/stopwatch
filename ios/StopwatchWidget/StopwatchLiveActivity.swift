import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct StopwatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StopwatchAttributes.self) { context in
            HStack {
                StopwatchTimeText(state: context.state, showMilliseconds: true)
                    .font(.custom("Roboto-Light", size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    StopwatchTimeText(state: context.state, showMilliseconds: true)
                        .font(.custom("Roboto-Light", size: 42))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(systemName: "stopwatch")
            } compactTrailing: {
                StopwatchTimeText(state: context.state, showMilliseconds: false)
                    .font(.custom("Roboto-Light", size: 13))
                    .frame(width: 52, alignment: .center)
            } minimal: {
                Image(systemName: "stopwatch")
            }
        }
    }
}

private struct StopwatchTimeText: View {
    let state: StopwatchAttributes.ContentState
    let showMilliseconds: Bool

    var body: some View {
        Group {
            if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
                let startDate = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000.0)
                    .addingTimeInterval(-Double(state.accumulatedMs) / 1000.0)

                if #available(iOS 18.0, *) {
                    if showMilliseconds {
                        Text(.currentDate, format: .stopwatch(
                            startingAt: startDate,
                            showsHours: false,
                            maxFieldCount: 3,
                            maxPrecision: .milliseconds(10)
                        ))
                    } else {
                        Text(.currentDate, format: .stopwatch(
                            startingAt: startDate,
                            showsHours: false,
                            maxPrecision: .seconds(1)
                        ))
                    }
                } else {
                    Text(
                        timerInterval: startDate...Date(timeIntervalSinceNow: 60 * 60 * 24),
                        countsDown: false,
                        showsHours: false
                    )
                }
            } else {
                Text(formatted(ms: state.elapsedMs))
            }
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
    }

    private func formatted(ms: Int) -> String {
        let totalMs = max(0, ms)
        let minutes = (totalMs / 1000) / 60
        let seconds = (totalMs / 1000) % 60
        guard showMilliseconds else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        let hundredths = (totalMs % 1000) / 10
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

// MARK: - Xcode Canvas previews
//
// These render the real widget (not just a mock) directly in the Xcode
// canvas, for both the running and paused state, without needing to build
// to the Simulator each time.

extension StopwatchAttributes {
    static var preview: StopwatchAttributes {
        StopwatchAttributes()
    }
}

extension StopwatchAttributes.ContentState {
    // Parameter order here must match the struct's declaration order
    // (startedAtEpochMs, accumulatedMs, isRunning) — Swift's memberwise
    // init doesn't let you reorder labeled arguments at the call site.
    static var running: StopwatchAttributes.ContentState {
        StopwatchAttributes.ContentState(
            startedAtEpochMs: Int(Date().timeIntervalSince1970 * 1000) - 48_054,
            accumulatedMs: 0,
            isRunning: true
        )
    }

    static var paused: StopwatchAttributes.ContentState {
        StopwatchAttributes.ContentState(
            startedAtEpochMs: nil,
            accumulatedMs: 48_054,
            isRunning: false
        )
    }
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: StopwatchAttributes.preview) {
    StopwatchLiveActivity()
} contentStates: {
    StopwatchAttributes.ContentState.running
    StopwatchAttributes.ContentState.paused
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: StopwatchAttributes.preview) {
    StopwatchLiveActivity()
} contentStates: {
    StopwatchAttributes.ContentState.running
    StopwatchAttributes.ContentState.paused
}

#Preview("Lock Screen Banner", as: .content, using: StopwatchAttributes.preview) {
    StopwatchLiveActivity()
} contentStates: {
    StopwatchAttributes.ContentState.running
    StopwatchAttributes.ContentState.paused
}
