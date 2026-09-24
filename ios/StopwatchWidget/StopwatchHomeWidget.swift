//
//  StopwatchHomeWidget.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import WidgetKit
import SwiftUI
import AppIntents

struct StopwatchEntry: TimelineEntry {
    let date: Date
    let state: StopwatchAttributes.ContentState
}

struct StopwatchTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StopwatchEntry {
        StopwatchEntry(date: Date(), state: .init(startedAtEpochMs: nil, accumulatedMs: 0, isRunning: false))
    }

    func getSnapshot(in context: Context, completion: @escaping (StopwatchEntry) -> Void) {
        completion(StopwatchEntry(date: Date(), state: StopwatchSharedState.contentState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StopwatchEntry>) -> Void) {
        let entry = StopwatchEntry(date: Date(), state: StopwatchSharedState.contentState())
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

            if entry.state.isRunning {
                Button(intent: StopStopwatchIntent()) {
                    Image(systemName: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button(intent: StartStopwatchIntent()) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
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
