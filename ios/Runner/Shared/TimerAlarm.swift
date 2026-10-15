import Foundation
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
import SwiftUI
import ActivityKit
#endif

enum TimerAlarm {
    static func schedule(endAtEpochMs: Int) {
        cancel()

        let end = Date(timeIntervalSince1970: Double(endAtEpochMs) / 1000)
        guard end > Date() else { return }

        Task {
            #if canImport(AlarmKit)
            if #available(iOS 26.0, *), await AlarmKitTimer.schedule(endDate: end) { return }
            #endif
            LegacyAlarm.schedule(endDate: end)
        }
    }

    static func cancel() {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) { AlarmKitTimer.cancel() }
        #endif
        LegacyAlarm.cancel()
    }
}

enum LegacyAlarm {
    private static let prefix = "com.szunyoghtamas.stopwatch.timerFinished"
    private static let count = 20
    private static let spacing: TimeInterval = 30

    private static var ids: [String] { (0..<count).map { "\(prefix).\($0)" } }

    static func schedule(endDate: Date) {
        let center = UNUserNotificationCenter.current()
        let base = max(1, endDate.timeIntervalSinceNow)

        for i in 0..<count {
            let content = UNMutableNotificationContent()
            content.title = String(localized: "timer_finished_title")
            content.body = String(localized: "timer_finished_body")
            content.sound = UNNotificationSound(named: UNNotificationSoundName("timer_alarm.caf"))
            content.interruptionLevel = .timeSensitive

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: base + Double(i) * spacing, repeats: false)
            center.add(UNNotificationRequest(identifier: ids[i], content: content, trigger: trigger))
        }
    }

    static func cancel() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
}

#if canImport(AlarmKit)
struct TimerAlarmMetadata: AlarmMetadata {}

@available(iOS 26.0, *)
enum AlarmKitTimer {
    private static let idKey = "timer_alarmKitId"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.szunyoghtamas.stopwatch") }

    static func requestAuthorization() async {
        _ = try? await AlarmManager.shared.requestAuthorization()
    }

    /// true, ha sikerült beütemezni.
    static func schedule(endDate: Date) async -> Bool {
        let manager = AlarmManager.shared
        do {
            if manager.authorizationState == .notDetermined {
                _ = try await manager.requestAuthorization()
            }
            guard manager.authorizationState == .authorized else { return false }

            let stopButton = AlarmButton(text: "timer_finished_stop", textColor: .white, systemImageName: "stop.fill")
            let alert = AlarmPresentation.Alert(title: "timer_finished_title", stopButton: stopButton)
            let attributes = AlarmAttributes(presentation: AlarmPresentation(alert: alert), metadata: TimerAlarmMetadata(), tintColor: .red)
            let configuration = AlarmManager.AlarmConfiguration.alarm(schedule: .fixed(endDate), attributes: attributes, stopIntent: TimerAlarmStopIntent(), sound: .named("timer_alarm.caf"))

            let id = UUID()
            _ = try await manager.schedule(id: id, configuration: configuration)
            defaults?.set(id.uuidString, forKey: idKey)
            return true
        } catch {
            return false
        }
    }

    static func cancel() {
        guard let raw = defaults?.string(forKey: idKey), let id = UUID(uuidString: raw) else { return }
        try? AlarmManager.shared.stop(id: id)
        try? AlarmManager.shared.cancel(id: id)
        defaults?.removeObject(forKey: idKey)
    }
}
#endif // canImport(AlarmKit)
