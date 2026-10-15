import Foundation
import ActivityKit
import os

private let activityLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "ActivityController")

public class StopwatchActivityController {
    private static let activeActivityIdKey = "com.szunyoghtamas.stopwatch.activeActivityId"
    private static let appGroupSuiteName = "group.com.szunyoghtamas.stopwatch"

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupSuiteName) }

    private static func relevance(kind: TimeKind, state: StopwatchAttributes.ContentState) -> Double {
        var score = state.isRunning ? 100.0 : 0.0
        if StopwatchSharedState.widgetMode == kind { score += 10 }
        return score
    }

    private static func content(kind: TimeKind) -> ActivityContent<StopwatchAttributes.ContentState> {
        let state = StopwatchSharedState.contentState(kind: kind)
        return ActivityContent(state: state, staleDate: state.endDate, relevanceScore: relevance(kind: kind, state: state))
    }

    private static func savedId(kind: TimeKind) -> String? {
        defaults?.string(forKey: kind.key(activeActivityIdKey))
    }

    public static func start(kind: TimeKind) async {
        if let id = savedId(kind: kind), Activity<StopwatchAttributes>.activities.contains(where: { $0.id == id }) {
            activityLogger.notice("[Widget] [\(kind.rawValue)] Resumed existing activity.")
        } else {
            do {
                let activity = try Activity.request(attributes: StopwatchAttributes(), content: content(kind: kind), pushType: nil)
                defaults?.set(activity.id, forKey: kind.key(activeActivityIdKey))
                activityLogger.notice("[Widget] [\(kind.rawValue)] Started activity: \(activity.id)")
            } catch {
                activityLogger.error("[Widget] [\(kind.rawValue)] Failed to start: \(error.localizedDescription)")
                return
            }
        }

        await refreshAll()
    }

    public static func update(kind: TimeKind) async {
        guard let id = savedId(kind: kind) else {
            activityLogger.notice("[Widget] [\(kind.rawValue)] No saved activity ID.")
            return
        }
        guard let activity = Activity<StopwatchAttributes>.activities.first(where: { $0.id == id }) else {
            activityLogger.notice("[Widget] [\(kind.rawValue)] Activity \(id) not found in system.")
            return
        }
        await activity.update(content(kind: kind))
    }

    public static func refreshAll() async {
        for kind in TimeKind.allCases {
            await update(kind: kind)
        }
    }

    public static func end(kind: TimeKind) async {
        guard let id = savedId(kind: kind) else { return }

        if let activity = Activity<StopwatchAttributes>.activities.first(where: { $0.id == id }) {
            await activity.end(content(kind: kind), dismissalPolicy: .immediate)
        }
        defaults?.removeObject(forKey: kind.key(activeActivityIdKey))

        await refreshAll()
    }
}
