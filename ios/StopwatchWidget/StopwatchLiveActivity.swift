import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct StopwatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StopwatchAttributes.self) { context in
            let running = context.state.isRunning && !context.isStale

            HStack(spacing: 12) {
                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.kind == .timer ? "widget_name_timer" : "widget_name")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    LiveActivityTimeText(state: context.state, showMilliseconds: context.state.kind == .stopwatch)
                        .font(.system(size: 28, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 8)

                ActivityActionButton(kind: context.state.kind, isRunning: running)
                    .frame(width: 110)
            }
            .padding(16)
            .activityBackgroundTint(Color(uiColor: .systemBackground))
            .widgetURL(StopwatchLaunch.url(for: context.state.kind))

        } dynamicIsland: { context in
            let running = context.state.isRunning && !context.isStale
            let symbol = context.state.kind == .timer ? "hourglass" : "stopwatch"

            return DynamicIsland {
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
                        LiveActivityTimeText(state: context.state, showMilliseconds: context.state.kind == .stopwatch)
                            .font(.system(size: 36, weight: .bold))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        ActivityActionButton(kind: context.state.kind, isRunning: running)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 2)
                }
            } compactLeading: {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            } compactTrailing: {
                LiveActivityTimeText(state: context.state, showMilliseconds: false)
                    .font(.system(size: 13, weight: .bold))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: 64, alignment: .trailing)
            } minimal: {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            }
            .widgetURL(StopwatchLaunch.url(for: context.state.kind))
        }
    }
}

private struct ActivityActionButton: View {
    let kind: TimeKind
    let isRunning: Bool

    var body: some View {
        Group {
            if isRunning {
                Button(intent: StopwatchStopIntent(fromLiveActivity: true, kind: kind)) { label }
            } else {
                Button(intent: StopwatchStartIntent(fromLiveActivity: true, kind: kind)) { label }
            }
        }
        .buttonStyle(.plain)
    }

    private var label: some View {
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
            switch state.kind {
            case .stopwatch: stopwatchText
            case .timer: timerText
            }
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
    }

    @ViewBuilder
    private var stopwatchText: some View {
        if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
            let startDate = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000.0)
                .addingTimeInterval(-Double(state.accumulatedMs) / 1000.0)

            if #available(iOS 18.0, *) {
                Text(.currentDate, format: .stopwatch(
                    startingAt: startDate,
                    showsHours: true,
                    maxFieldCount: showMilliseconds ? 4 : 3,
                    maxPrecision: showMilliseconds ? .milliseconds(10) : .seconds(1)
                ))
            } else {
                Text(startDate, style: .timer)
            }
        } else {
            Text(TimeFormat.stopwatch(ms: state.valueMs, showMilliseconds: showMilliseconds, kind: .stopwatch))
        }
    }

    @ViewBuilder
    private var timerText: some View {
        if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
            let start = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000.0)
            let end = start.addingTimeInterval(Double(max(0, state.accumulatedMs)) / 1000.0)

            Text(timerInterval: start...end, pauseTime: nil, countsDown: true, showsHours: state.accumulatedMs >= 3_600_000)
        } else {
            Text(TimeFormat.stopwatch(ms: state.valueMs, showMilliseconds: showMilliseconds, kind: .timer))
        }
    }
}
