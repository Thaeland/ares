import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var aresChannels: AresAppleChannels?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    registerAresChannels()
    super.applicationDidFinishLaunching(notification)
  }

  private func registerAresChannels() {
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      aresChannels = AresAppleChannels(messenger: controller.engine.binaryMessenger)
      return
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
            self.aresChannels == nil,
            let controller = self.mainFlutterWindow?.contentViewController as? FlutterViewController
      else { return }
      self.aresChannels = AresAppleChannels(messenger: controller.engine.binaryMessenger)
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
