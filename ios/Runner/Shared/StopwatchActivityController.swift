import Foundation
import ActivityKit
import os

private let activityLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "ActivityController")

public class StopwatchActivityController {
    private static let activeActivityIdKey = "com.szunyoghtamas.stopwatch.activeActivityId"
    private static let appGroupSuiteName = "group.com.szunyoghtamas.stopwatch"
    
    public static func start() async {
        let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)

        if let savedId = sharedDefaults?.string(forKey: activeActivityIdKey),
            Activity<StopwatchAttributes>.activities.contains(where: { $0.id == savedId }) {

            await update(activityId: savedId)
            activityLogger.notice("[Widget] Resumed existing activity via update(activityId:).")
            return
        }

        let initialState = StopwatchSharedState.contentState()
        let attributes = StopwatchAttributes()

        do {
            let content = ActivityContent(state: initialState, staleDate: nil)
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            sharedDefaults?.set(activity.id, forKey: activeActivityIdKey)

            activityLogger.notice("[Widget] Started and saved Activity ID: \(activity.id)")
        } catch {
            activityLogger.error("[Widget] Failed to start: \(error.localizedDescription)")
        }
    }
    
    public static func update(activityId: String? = nil) async {
        let targetId: String?
        
        if let providedId = activityId {
            targetId = providedId
        } else {
            targetId = UserDefaults(suiteName: appGroupSuiteName)?.string(forKey: activeActivityIdKey)
        }
        
        guard let savedId = targetId else {
            activityLogger.notice("[Widget] [ActivityController] No saved activity ID found.")
            return
        }
        
        let targetActivity = Activity<StopwatchAttributes>.activities.first { $0.id == savedId }
        let state = StopwatchSharedState.contentState()
        let content = ActivityContent(state: state, staleDate: nil)
        
        if let activity = targetActivity {
            activityLogger.notice("[Widget] [ActivityController] Updating exact activity ID: \(activity.id)")
            await activity.update(content)
        } else {
            activityLogger.notice("[Widget] [ActivityController] Activity with ID \(savedId) not found in system.")
        }
    }
    
    public static func end() async {
        guard let savedId = UserDefaults(suiteName: appGroupSuiteName)?.string(forKey: activeActivityIdKey) else { return }
            
        let targetActivity = Activity<StopwatchAttributes>.activities.first { $0.id == savedId }
        
        let state = StopwatchSharedState.contentState()
        let content = ActivityContent(state: state, staleDate: nil)
        
        if let activity = targetActivity {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        
        UserDefaults(suiteName: appGroupSuiteName)?.removeObject(forKey: activeActivityIdKey)
    }
}
