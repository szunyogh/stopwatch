import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let rest = URLContexts.filter { !StopwatchLaunch.handle(url: $0.url) }
        if !rest.isEmpty { super.scene(scene, openURLContexts: rest) }
    }

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        connectionOptions.urlContexts.forEach { StopwatchLaunch.handle(url: $0.url) }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
}
