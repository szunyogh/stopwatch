import WidgetKit
import SwiftUI

@main
struct StopwatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        StopwatchLiveActivity()
        StopwatchHomeScreenWidget()
    }
}
