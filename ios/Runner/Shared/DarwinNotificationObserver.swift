//
//  DarwinNotificationObserver.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import Foundation

enum DarwinNotification {
    static let stateChangedName = "com.example.stopwatch.stateChanged"

    static func post() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(stateChangedName as CFString),
            nil, nil, true
        )
    }
}

final class DarwinNotificationObserver {
    private let name: CFString
    private let callback: () -> Void

    init(name: String = DarwinNotification.stateChangedName, callback: @escaping () -> Void) {
        self.name = name as CFString
        self.callback = callback
        start()
    }

    private func start() {
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { _, observerPointer, _, _, _ in
                guard let observerPointer else { return }
                let mySelf = Unmanaged<DarwinNotificationObserver>.fromOpaque(observerPointer).takeUnretainedValue()
                mySelf.callback()
            },
            name,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(name),
            nil
        )
    }
}
