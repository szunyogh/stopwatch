import Foundation

enum StopwatchLaunch {
    private static let appGroupId = "group.com.szunyoghtamas.stopwatch"
    private static let keyKind = "pendingTab"
    private static let keyAt = "pendingTabAt"
    private static let maxAge: TimeInterval = 15

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    static func url(for kind: TimeKind) -> URL { URL(string: "stopwatch://open/\(kind.rawValue)")! }

    static func set(_ kind: TimeKind) {
        defaults?.set(kind.rawValue, forKey: keyKind)
        defaults?.set(Date().timeIntervalSince1970, forKey: keyAt)
    }

    static func consume() -> TimeKind? {
        defer {
            defaults?.removeObject(forKey: keyKind)
            defaults?.removeObject(forKey: keyAt)
        }
        guard let raw = defaults?.string(forKey: keyKind), let kind = TimeKind(rawValue: raw) else { return nil }
        let at = defaults?.double(forKey: keyAt) ?? 0
        return Date().timeIntervalSince1970 - at <= maxAge ? kind : nil
    }

    @discardableResult
    static func handle(url: URL) -> Bool {
        guard url.scheme == "stopwatch", url.host == "open", let kind = TimeKind(rawValue: url.lastPathComponent) else { return false }
        set(kind)
        return true
    }
}
