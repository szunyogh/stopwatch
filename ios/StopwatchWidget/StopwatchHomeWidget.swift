import WidgetKit
import SwiftUI
import AppIntents
import os

private let widgetLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "WidgetTimeline")

struct StopwatchEntry: TimelineEntry {
    let date: Date
    let kind: TimeKind
    let state: StopwatchAttributes.ContentState
    let showsToggle: Bool
}

struct StopwatchTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StopwatchEntry {
        StopwatchEntry(date: Date(), kind: .stopwatch, state: .init(startedAtEpochMs: nil, accumulatedMs: 0, isRunning: false), showsToggle: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (StopwatchEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StopwatchEntry>) -> Void) {
        let entry = makeEntry()
        widgetLogger.notice("[Widget] getTimeline -> kind: \(entry.kind.rawValue), toggle: \(entry.showsToggle)")

        let policy: TimelineReloadPolicy = StopwatchSharedState.timerEndDate().map { TimelineReloadPolicy.after($0.addingTimeInterval(1)) } ?? .never
        completion(Timeline(entries: [entry], policy: policy))
    }

    private func makeEntry() -> StopwatchEntry {
        let stopwatch = StopwatchSharedState.contentState(kind: .stopwatch)
        let timer = StopwatchSharedState.contentState(kind: .timer)

        let both = stopwatch.isRunning && timer.isRunning
        let kind: TimeKind
        if both {
            kind = StopwatchSharedState.widgetMode
        } else if stopwatch.isRunning {
            kind = .stopwatch
        } else if timer.isRunning {
            kind = .timer
        } else {
            kind = StopwatchSharedState.widgetMode
        }

        return StopwatchEntry(date: Date(), kind: kind, state: kind == .timer ? timer : stopwatch, showsToggle: both)
    }
}

struct StopwatchWidgetView: View {
    var entry: StopwatchTimelineProvider.Entry

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(.widgetText))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 8)

                if entry.showsToggle {
                    modeToggle
                }

                Image("StopwatchIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityHidden(true)
            }

            TimeText(state: entry.state)
                .font(.system(size: 50, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Color(.widgetText))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if entry.state.isRunning {
                    Button(intent: StopwatchStopIntent(kind: entry.kind)) { buttonLabel }
                } else {
                    Button(intent: StopwatchStartIntent(kind: entry.kind)) { buttonLabel }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color.clear
        }
        .widgetURL(StopwatchLaunch.url(for: entry.kind))
    }

    private var title: LocalizedStringKey {
        entry.kind == .timer ? "widget_name_timer" : "widget_name"
    }

    private var modeToggle: some View {
        Button(intent: ToggleWidgetModeIntent()) {
            HStack(spacing: 2) {
                modeIcon("stopwatch", selected: entry.kind == .stopwatch)
                modeIcon("hourglass", selected: entry.kind == .timer)
            }
            .padding(3)
            .background(Capsule().fill(Color(.widgetText).opacity(0.12)))
        }
        .buttonStyle(.plain)
    }

    private func modeIcon(_ name: String, selected: Bool) -> some View {
        Image(systemName: name)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color(.widgetText).opacity(selected ? 1 : 0.4))
            .frame(width: 30, height: 26)
            .background(Capsule().fill(selected ? Color(.widgetText).opacity(0.18) : Color.clear))
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

struct TimeText: View {
    let state: StopwatchAttributes.ContentState

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
            let startDate = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000)
                .addingTimeInterval(-Double(state.accumulatedMs) / 1000)

            if #available(iOS 18.0, *) {
                Text(.currentDate, format: .stopwatch(startingAt: startDate, showsHours: true, maxFieldCount: 4, maxPrecision: .milliseconds(10)))
                    .id("sw-running-\(startedAtEpochMs)")
            } else {
                Text(startDate, style: .timer).id("sw-running-\(startedAtEpochMs)")
            }
        } else {
            Text(TimeFormat.stopwatch(ms: state.valueMs, showMilliseconds: true, kind: .stopwatch))
                .id("sw-stopped-\(state.accumulatedMs)")
        }
    }

    @ViewBuilder
    private var timerText: some View {
        if state.isRunning, let startedAtEpochMs = state.startedAtEpochMs {
            let start = Date(timeIntervalSince1970: Double(startedAtEpochMs) / 1000)
            let end = start.addingTimeInterval(Double(max(0, state.accumulatedMs)) / 1000)

            Text(timerInterval: start...end, pauseTime: nil, countsDown: true, showsHours: true)
                .id("tm-running-\(startedAtEpochMs)")
        } else {
            Text(TimeFormat.stopwatch(ms: state.valueMs, showMilliseconds: false, kind: .timer))
                .id("tm-stopped-\(state.accumulatedMs)")
        }
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
