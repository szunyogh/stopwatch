import Foundation
import ActivityKit

public class StopwatchActivityController {
    private static let activeActivityIdKey = "com.szunyogh.stopwatch.activeActivityId"
    private static let appGroupSuiteName = "group.com.szunyogh.stopwatch"
    
    public static func start() {
        let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)
        
        if let savedId = sharedDefaults?.string(forKey: activeActivityIdKey),
            let _ = Activity<StopwatchAttributes>.activities.first(where: { $0.id == savedId }) {
            
            Task {
                await update(activityId: savedId)
                NSLog("[Widget] [ActivityController] Resumed existing activity via update(activityId:).")
            }
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
            
            NSLog("[Widget] [ActivityController] Started and saved Activity ID: \(activity.id)")
        } catch {
            NSLog("[Widget] [ActivityController] Failed to start: \(error.localizedDescription)")
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
            NSLog("[Widget] [ActivityController] No saved activity ID found.")
            return
        }
        
        let targetActivity = Activity<StopwatchAttributes>.activities.first { $0.id == savedId }
        let state = StopwatchSharedState.contentState()
        let content = ActivityContent(state: state, staleDate: nil)
        
        if let activity = targetActivity {
            NSLog("[Widget] [ActivityController] Updating exact activity ID: \(activity.id)")
            await activity.update(content)
        } else {
            NSLog("[Widget] [ActivityController] Activity with ID \(savedId) not found in system.")
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
