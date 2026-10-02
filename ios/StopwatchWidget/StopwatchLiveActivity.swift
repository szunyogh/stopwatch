import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct StopwatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StopwatchAttributes.self) { context in
            HStack(spacing: 12) {
                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("widget_name")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    LiveActivityTimeText(state: context.state, showMilliseconds: true)
                        .font(.system(size: 28, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 8)

                Group {
                    if context.state.isRunning {
                        Button(intent: StopwatchStopIntent(fromLiveActivity: true)) {
                            buttonLabel(isRunning: context.state.isRunning)
                        }
                    } else {
                        Button(intent: StopwatchStartIntent(fromLiveActivity: true)) {
                            buttonLabel(isRunning: context.state.isRunning)
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 110)
            }
            .padding(16)
            .activityBackgroundTint(Color(uiColor: .systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("StopwatchIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .padding(.leading, 6)
                        .padding(.top, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        LiveActivityTimeText(state: context.state, showMilliseconds: true)
                            .font(.system(size: 36, weight: .bold))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Group {
                            if context.state.isRunning {
                                Button(intent: StopwatchStopIntent(fromLiveActivity: true)) {
                                    buttonLabel(isRunning: context.state.isRunning)
                                }
                            } else {
                                Button(intent: StopwatchStartIntent(fromLiveActivity: true)) {
                                    buttonLabel(isRunning: context.state.isRunning)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 2)
                }
            } compactLeading: {
                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            } compactTrailing: {
                LiveActivityTimeText(state: context.state, showMilliseconds: false)
                    .font(.system(size: 13, weight: .bold))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40, alignment: .trailing)
            } minimal: {
                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
        }
    }

    private func buttonLabel(isRunning: Bool) -> some View {
        Text(isRunning ? "widget_button_text_stop" : "widget_button_text_start")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color(.buttonText))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color(isRunning ? .buttonStop : .buttonStart))
            )
    }
}

struct LiveActivityTimeText: View {
    let state: StopwatchAttributes.ContentState
    let showMilliseconds: Bool

    var body: some View {
        Group {
            if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
                let startDate = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000.0)
                    .addingTimeInterval(-Double(state.accumulatedMs) / 1000.0)

                if showMilliseconds {
                    if #available(iOS 18.0, *) {
                        Text(.currentDate, format: .stopwatch(
                            startingAt: startDate,
                            showsHours: false,
                            maxFieldCount: 3,
                            maxPrecision: .milliseconds(10)
                        ))
                    } else {
                        Text(
                            timerInterval: startDate...Date(timeIntervalSinceNow: 60 * 60 * 24),
                            countsDown: false,
                            showsHours: false
                        )
                    }
                } else {
                    if #available(iOS 18.0, *) {
                        Text(.currentDate, format: .stopwatch(
                            startingAt: startDate,
                            showsHours: false,
                            maxFieldCount: 2,
                            maxPrecision: .seconds(1)
                        ))
                    } else {
                        Text(startDate, style: .timer)
                    }
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
