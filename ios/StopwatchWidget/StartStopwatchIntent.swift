//
//  StartStopwatchIntent.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import AppIntents

struct StartStopwatchIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Indítás"

    func perform() async throws -> some IntentResult {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        let accumulated = StopwatchSharedState.accumulatedMs

        StopwatchSharedState.start(startedAtEpochMs: now, accumulatedMs: accumulated)
        await StopwatchActivityController.start()
        DarwinNotification.post()

        return .result()
    }
}

struct StopStopwatchIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Leállítás"

    func perform() async throws -> some IntentResult {
        let elapsed = StopwatchSharedState.contentState().elapsedMs

        StopwatchSharedState.stop(accumulatedMs: elapsed)
        await StopwatchActivityController.update()
        DarwinNotification.post()

        return .result()
    }
}
