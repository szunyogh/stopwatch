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
        HStack {
            StopwatchTimeText(state: entry.state)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .minimumScaleFactor(0.5)

            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

private struct StopwatchTimeText: View {
    let state: StopwatchAttributes.ContentState

    var body: some View {
        if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
            let virtualStart = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000)
                .addingTimeInterval(-Double(state.accumulatedMs) / 1000)
            
            Text(virtualStart, style: .timer)
                .monospacedDigit()
                .id("widget-timer-\(startedAtEpochMs)")
        } else {
            Text(formatted(ms: state.accumulatedMs))
                .monospacedDigit()
                .id("widget-stopped-\(state.accumulatedMs)")
        }
    }

    private func formatted(ms: Int) -> String {
        let s = Int(round(Double(ms) / 1000.0))
        return String(format: "%02d:%02d", s / 60, s % 60)
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
