import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self
    LegacyAlarm.registerCategory()
      
    StopwatchLaunch.opener = { url in _ = await UIApplication.shared.open(url) }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "StopwatchMethodChannel") {
        StopwatchMethodChannel.shared.register(with: registrar)
    }
  }

    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if LegacyAlarm.owns(notification.request.identifier) {
            completionHandler([.banner, .list, .sound])
            return
        }
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard LegacyAlarm.owns(response.notification.request.identifier) else {
            super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            return
        }
        
        Task {
            await LegacyAlarm.handle(response)
            completionHandler()
        }
    }
}
