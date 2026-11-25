import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let flutterViewController: FlutterViewController
    if arguments.contains("--ares-workspace-chat-v1") ||
        arguments.contains("--ares-pet-companion-v1") {
      let project = FlutterDartProject()
      project.dartEntrypointArguments = arguments
      flutterViewController = FlutterViewController(project: project)
      let companion = arguments.contains("--ares-pet-companion-v1")
      self.title = companion ? "Ares — Companion" : "Ares — Chat"
      self.isRestorable = false
      if companion {
        self.level = .floating
        self.setContentSize(NSSize(width: 360, height: 520))
      }
    } else {
      flutterViewController = FlutterViewController()
    }
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.contentMinSize = NSSize(width: 480, height: 420)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
