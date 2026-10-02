import Flutter
import UIKit
import os

private let appLogger = Logger(subsystem: "com.szunyoghtamas.stopwatch", category: "AppLaunch")

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    appLogger.notice("[Timing] didFinishLaunching | since process start: \(StopwatchTiming.sinceProcessStartMs()) ms | state: \(UIApplication.shared.applicationState.rawValue)")

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    appLogger.notice("[Timing] Flutter engine initialized | since process start: \(StopwatchTiming.sinceProcessStartMs()) ms")

    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "StopwatchMethodChannel") {
        StopwatchMethodChannel.shared.register(with: registrar)
    }
  }
}
