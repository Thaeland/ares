// Ares desktop integration for the primary macOS window
// (docs/desktop-os-native.md):
//
//   com.hermesagent.ares/shell   setTray, showWindow, quit; onTrayAction
//
// Only the primary process creates this. Pop-out, companion and quick-entry
// children are separate processes started with a marker argument and never
// own a menu-bar item.

import Cocoa
import FlutterMacOS

/// True when this process is a child window (pop-out chat, companion or
/// quick entry), started by the primary with a marker argument.
enum AresProcessRole {
  static let childMarkers: Set<String> = [
    "--ares-workspace-chat-v1",
    "--ares-pet-companion-v1",
    "--ares-quick-entry-v1",
  ]

  static var isChild: Bool {
    !childMarkers.isDisjoint(with: CommandLine.arguments.dropFirst())
  }
}

final class AresDesktopOS: NSObject {
  private let shellChannel: FlutterMethodChannel
  private weak var window: NSWindow?

  private var statusItem: NSStatusItem?
  private var trayItemIds: [String] = []

  /// Closing the main window hides it while the menu-bar item is shown.
  private(set) var closeToTray = false

  init(messenger: FlutterBinaryMessenger, window: NSWindow?) {
    shellChannel = FlutterMethodChannel(
      name: "com.hermesagent.ares/shell",
      binaryMessenger: messenger
    )
    self.window = window
    super.init()
    // A hidden window must be shown again, not recreated.
    window?.isReleasedWhenClosed = false
    shellChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleShell(call, result: result)
    }
  }

  func shutdown() {
    removeStatusItem()
    shellChannel.setMethodCallHandler(nil)
  }

  // MARK: - Shell

  private func handleShell(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showWindow":
      showMainWindow()
      result(nil)
    case "quit":
      closeToTray = false
      removeStatusItem()
      // Reply first; terminate on the next turn of the run loop.
      result(nil)
      DispatchQueue.main.async { NSApp.terminate(nil) }
    case "isTraySupported":
      result(true)
    case "setTray":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad-args", message: "setTray expects a map", details: nil))
        return
      }
      result(applyTray(args))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func showMainWindow() {
    NSApp.activate(ignoringOtherApps: true)
    guard let window = window else { return }
    if window.isMiniaturized { window.deminiaturize(nil) }
    window.makeKeyAndOrderFront(nil)
  }

  private func applyTray(_ args: [String: Any]) -> Bool {
    guard args["enabled"] as? Bool == true else {
      closeToTray = false
      removeStatusItem()
      return false
    }
    let item = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    statusItem = item
    if let button = item.button {
      let image = NSImage(systemSymbolName: "bubble.left.and.bubble.right", accessibilityDescription: "Ares")
      image?.isTemplate = true
      button.image = image
      button.toolTip = AresDesktopText.clean(args["tooltip"] as? String ?? "Ares", limit: 127)
    }
    let menu = NSMenu()
    menu.autoenablesItems = false
    trayItemIds = []
    for entry in (args["items"] as? [Any] ?? []).prefix(16) {
      guard let map = entry as? [String: Any],
            let id = map["id"] as? String, AresDesktopText.isItemId(id)
      else { continue }
      let label = AresDesktopText.clean(map["label"] as? String ?? "", limit: 64)
      guard !label.isEmpty else { continue }
      if map["separatorBefore"] as? Bool == true, !trayItemIds.isEmpty {
        menu.addItem(.separator())
      }
      let menuItem = NSMenuItem(title: label, action: #selector(trayItemChosen(_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = trayItemIds.count
      menuItem.state = map["checked"] as? Bool == true ? .on : .off
      menu.addItem(menuItem)
      trayItemIds.append(id)
    }
    item.menu = menu
    closeToTray = args["closeToTray"] as? Bool == true
    return true
  }

  private func removeStatusItem() {
    if let item = statusItem {
      NSStatusBar.system.removeStatusItem(item)
    }
    statusItem = nil
    trayItemIds = []
  }

  @objc private func trayItemChosen(_ sender: NSMenuItem) {
    guard trayItemIds.indices.contains(sender.tag) else { return }
    shellChannel.invokeMethod("onTrayAction", arguments: trayItemIds[sender.tag])
  }
}

/// Label rules shared with the Windows and Linux runners.
enum AresDesktopText {
  static func isItemId(_ id: String) -> Bool {
    guard (1...32).contains(id.count) else { return false }
    return id.unicodeScalars.allSatisfy { ("a"..."z").contains($0) || $0 == "-" }
  }

  /// Drops control characters and bounds the length.
  static func clean(_ text: String, limit: Int) -> String {
    let scalars = text.unicodeScalars.filter { scalar in
      !(scalar.value < 0x20 || (0x7F..<0xA0).contains(scalar.value))
    }
    return String(String.UnicodeScalarView(scalars).prefix(limit))
  }
}
