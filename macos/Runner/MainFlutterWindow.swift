import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let flutterViewController: FlutterViewController
    if arguments.contains("--ares-workspace-chat-v1") {
      let project = FlutterDartProject()
      project.dartEntrypointArguments = arguments
      flutterViewController = FlutterViewController(project: project)
      self.title = "Ares — Chat"
      self.isRestorable = false
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
