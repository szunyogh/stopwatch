//
//  StopwatchWidgetBundle.swift
//  Runner
//
//  Created by Szunyogh Tamás on 2026. 09. 24..
//

import WidgetKit
import SwiftUI

@main
struct StopwatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        StopwatchLiveActivity()
        StopwatchHomeScreenWidget()
    }
}
