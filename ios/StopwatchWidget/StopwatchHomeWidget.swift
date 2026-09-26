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
        StopwatchTimeText(state: entry.state)
            .font(.custom("Roboto-Light", size: 25))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .containerBackground(for: .widget) {
                Color.clear
            }
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
        .configurationDisplayName("Stopper")
        .description("Stopper gyors indítás/leállítás a főképernyőről.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Xcode Canvas previews

#Preview("Small - Running", as: .systemSmall) {
    StopwatchHomeScreenWidget()
} timeline: {
    StopwatchEntry(
        date: .now,
        state: .init(startedAtEpochMs: Int(Date().timeIntervalSince1970 * 1000) - 48_054, accumulatedMs: 0, isRunning: true)
    )
}

#Preview("Small - Paused", as: .systemSmall) {
    StopwatchHomeScreenWidget()
} timeline: {
    StopwatchEntry(
        date: .now,
        state: .init(startedAtEpochMs: nil, accumulatedMs: 48_054, isRunning: false)
    )
}

#Preview("Medium - Running", as: .systemMedium) {
    StopwatchHomeScreenWidget()
} timeline: {
    StopwatchEntry(
        date: .now,
        state: .init(startedAtEpochMs: Int(Date().timeIntervalSince1970 * 1000) - 48_054, accumulatedMs: 0, isRunning: true)
    )
}
