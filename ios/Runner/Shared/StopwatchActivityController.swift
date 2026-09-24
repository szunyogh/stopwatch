//
//  StopwatchActivityController.swift
//

import ActivityKit
import OSLog

enum StopwatchActivityController {
    private static let logger = Logger(subsystem: "com.szunyogh.stopwatch", category: "LiveActivity")

    static func start() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities disabled by user/system.")
            return
        }

        let existing = Activity<StopwatchAttributes>.activities
        logger.debug("start() – existing activities: \(existing.count)")

        if existing.isEmpty {
            do {
                let activity = try Activity.request(
                    attributes: StopwatchAttributes(),
                    content: .init(state: StopwatchSharedState.contentState(), staleDate: nil)
                )
                logger.debug("Requested new activity: \(activity.id)")
            } catch {
                logger.error("Live Activity start failed: \(error.localizedDescription)")
            }
        } else {
            // Frissítsünk MINDEN futó activity-t (ha duplikáció van, akkor is helyes állapotba kerül mindegyik)
            for activity in existing {
                await activity.update(.init(state: StopwatchSharedState.contentState(), staleDate: nil))
                logger.debug("Updated activity \(activity.id) on start()")
            }
        }
    }

    static func update() async {
        let activities = Activity<StopwatchAttributes>.activities
        guard !activities.isEmpty else {
            logger.warning("update() called but Activity<StopwatchAttributes>.activities is EMPTY — nothing to update.")
            return
        }
        for activity in activities {
            await activity.update(.init(state: StopwatchSharedState.contentState(), staleDate: nil))
            logger.debug("Updated activity \(activity.id) on update()")
        }
    }

    static func end() async {
        let activities = Activity<StopwatchAttributes>.activities
        for activity in activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}