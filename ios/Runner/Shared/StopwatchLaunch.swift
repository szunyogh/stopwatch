import Foundation
import UIKit

enum StopwatchLaunch {
    static let scheme = "com.szunyoghtamas.stopwatch"

    static func url(for kind: TimeKind) -> URL { URL(string: "\(scheme)://open/\(kind.rawValue)")! }

    @MainActor static var opener: ((URL) async -> Void)?

    @MainActor
    static func open(_ kind: TimeKind) async {
        await opener?(url(for: kind))
    }
}
