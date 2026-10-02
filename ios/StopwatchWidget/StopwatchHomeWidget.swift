import WidgetKit
import SwiftUI
import AppIntents
import os

private let widgetLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "WidgetTimeline")

struct StopwatchEntry: TimelineEntry {
    let date: Date
    let state: StopwatchAttributes.ContentState
}

struct StopwatchTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StopwatchEntry {
        widgetLogger.notice("[Widget] placeholder requested")
        return StopwatchEntry(date: Date(), state: .init(startedAtEpochMs: nil, accumulatedMs: 0, isRunning: false))
    }

    func getSnapshot(in context: Context, completion: @escaping (StopwatchEntry) -> Void) {
        let state = StopwatchSharedState.contentState()
        widgetLogger.notice("[Widget] getSnapshot requested. State: \(String(describing: state))")
        completion(StopwatchEntry(date: Date(), state: state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StopwatchEntry>) -> Void) {
        let state = StopwatchSharedState.contentState()
        widgetLogger.notice("[Widget] getTimeline requested. Rendering UI with State: \(String(describing: state))")
        let entry = StopwatchEntry(date: Date(), state: state)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct StopwatchWidgetView: View {
    var entry: StopwatchTimelineProvider.Entry

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("widget_name")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(.widgetText))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 8)

                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityHidden(true)
            }

            StopwatchTimeText(state: entry.state)
                .font(.system(size: 50, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Color(.widgetText))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if entry.state.isRunning {
                    Button(intent: StopwatchStopIntent()) { buttonLabel }
                } else {
                    Button(intent: StopwatchStartIntent()) { buttonLabel }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
    }
    
    private var buttonLabel: some View {
        Text(entry.state.isRunning ? "widget_button_text_stop" : "widget_button_text_start")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color(.buttonText))
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color(entry.state.isRunning ? .buttonStop : .buttonStart))
            )
    }
}

private struct StopwatchTimeText: View {
    let state: StopwatchAttributes.ContentState

    var body: some View {
        Group {
            if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
                let startDate = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000)
                    .addingTimeInterval(-Double(state.accumulatedMs) / 1000)

                if #available(iOS 18.0, *) {
                    Text(.currentDate, format: .stopwatch(
                        startingAt: startDate,
                        showsHours: false,
                        maxFieldCount: 3,
                        maxPrecision: .milliseconds(10)
                    ))
                    .id("widget-timer-\(startedAtEpochMs)")
                } else {
                    Text(startDate, style: .timer)
                        .id("widget-timer-\(startedAtEpochMs)")
                }
            } else {
                Text(formatted(ms: state.accumulatedMs))
                    .id("widget-stopped-\(state.accumulatedMs)")
            }
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
    }

    private func formatted(ms: Int) -> String {
        let totalMs = max(0, ms)
        let minutes = (totalMs / 1000) / 60
        let seconds = (totalMs / 1000) % 60
        let hundredths = (totalMs % 1000) / 10
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

struct StopwatchHomeScreenWidget: Widget {
    let kind: String = "StopwatchHomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StopwatchTimelineProvider()) { entry in
            StopwatchWidgetView(entry: entry)
        }
        .configurationDisplayName("widget_name")
        .description("widget_description")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
