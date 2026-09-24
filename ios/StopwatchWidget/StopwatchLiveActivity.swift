//
//  StopwatchLiveActivity.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct StopwatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StopwatchAttributes.self) { context in
            HStack {
                LiveActivityTimeText(state: context.state)
                    .font(.system(size: 34, weight: .semibold, design: .monospaced))

                Spacer()

                if context.state.isRunning {
                    Button(intent: StopStopwatchIntent()) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button(intent: StartStopwatchIntent()) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    LiveActivityTimeText(state: context.state)
                        .font(.system(size: 28, weight: .semibold, design: .monospaced))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isRunning {
                        Button(intent: StopStopwatchIntent()) {
                            Image(systemName: "stop.fill")
                        }
                    } else {
                        Button(intent: StartStopwatchIntent()) {
                            Image(systemName: "play.fill")
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "stopwatch")
            } compactTrailing: {
                LiveActivityTimeText(state: context.state)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "stopwatch")
            }
        }
    }
}

private struct LiveActivityTimeText: View {
    let state: StopwatchAttributes.ContentState

    var body: some View {
        if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
            let virtualStart = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000)
                .addingTimeInterval(-Double(state.accumulatedMs) / 1000)
            Text(virtualStart, style: .timer)
                .monospacedDigit()
        } else {
            Text(formatted(ms: state.accumulatedMs))
                .monospacedDigit()
        }
    }

    private func formatted(ms: Int) -> String {
        let s = ms / 1000
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}