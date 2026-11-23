import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var aresChannels: AresAppleChannels?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    registerAresChannels()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    registerAresChannels()
  }

  private func registerAresChannels() {
    guard aresChannels == nil,
          let controller = window?.rootViewController as? FlutterViewController
    else { return }
    aresChannels = AresAppleChannels(messenger: controller.binaryMessenger)
  }
}
