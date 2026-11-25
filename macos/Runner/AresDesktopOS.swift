// Ares desktop integration for the primary macOS window
// (docs/desktop-os-native.md):
//
//   com.hermesagent.ares/shell   setTray, showWindow, quit; onTrayAction
//   com.hermesagent.ares/hotkey  register, unregister; onHotKey
//
// Only the primary process creates this. Pop-out, companion and quick-entry
// children are separate processes started with a marker argument and never
// own a menu-bar item.

import Carbon.HIToolbox
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
  private let hotkeyChannel: FlutterMethodChannel
  private weak var window: NSWindow?

  private var hotKeyRef: EventHotKeyRef?
  private var hotKeyHandler: EventHandlerRef?

  private var statusItem: NSStatusItem?
  private var trayItemIds: [String] = []

  /// Closing the main window hides it while the menu-bar item is shown.
  private(set) var closeToTray = false

  init(messenger: FlutterBinaryMessenger, window: NSWindow?) {
    shellChannel = FlutterMethodChannel(
      name: "com.hermesagent.ares/shell",
      binaryMessenger: messenger
    )
    hotkeyChannel = FlutterMethodChannel(
      name: "com.hermesagent.ares/hotkey",
      binaryMessenger: messenger
    )
    self.window = window
    super.init()
    // A hidden window must be shown again, not recreated.
    window?.isReleasedWhenClosed = false
    shellChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleShell(call, result: result)
    }
    hotkeyChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleHotkey(call, result: result)
    }
  }

  func shutdown() {
    // Exit releases the hotkey even if Dart never got to unregister it.
    unregisterHotKey()
    if let handler = hotKeyHandler {
      RemoveEventHandler(handler)
      hotKeyHandler = nil
    }
    removeStatusItem()
    shellChannel.setMethodCallHandler(nil)
    hotkeyChannel.setMethodCallHandler(nil)
  }

  // MARK: - Global hotkey (Carbon; needs no Accessibility permission)

  private func handleHotkey(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "unregister":
      unregisterHotKey()
      result(nil)
    case "register":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad-args", message: "register expects a map", details: nil))
        return
      }
      result(registerHotKey(args))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func registerHotKey(_ args: [String: Any]) -> String {
    let command = args["meta"] as? Bool == true
    let control = args["ctrl"] as? Bool == true
    let option = args["alt"] as? Bool == true
    let shift = args["shift"] as? Bool == true
    guard command || control || option,
          let key = args["key"] as? String,
          let code = AresHotkeyKeys.keyCode(for: key)
    else { return "invalid" }
    unregisterHotKey()
    guard installHotKeyHandler() else { return "unsupported" }
    var modifiers: UInt32 = 0
    if command { modifiers |= UInt32(cmdKey) }
    if control { modifiers |= UInt32(controlKey) }
    if option { modifiers |= UInt32(optionKey) }
    if shift { modifiers |= UInt32(shiftKey) }
    let id = EventHotKeyID(signature: OSType(0x4152_4553), id: 1)  // 'ARES'
    var ref: EventHotKeyRef?
    let status = RegisterEventHotKey(
      UInt32(code), modifiers, id, GetApplicationEventTarget(), 0, &ref)
    if status == noErr, let ref = ref {
      hotKeyRef = ref
      return "registered"
    }
    return status == OSStatus(eventHotKeyExistsErr) ? "conflict" : "unsupported"
  }

  private func unregisterHotKey() {
    if let ref = hotKeyRef {
      UnregisterEventHotKey(ref)
      hotKeyRef = nil
    }
  }

  private func installHotKeyHandler() -> Bool {
    if hotKeyHandler != nil { return true }
    var spec = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )
    let status = InstallEventHandler(
      GetApplicationEventTarget(),
      { _, _, userData -> OSStatus in
        guard let userData = userData else { return noErr }
        let owner = Unmanaged<AresDesktopOS>.fromOpaque(userData).takeUnretainedValue()
        DispatchQueue.main.async { owner.hotKeyPressed() }
        return noErr
      },
      1,
      &spec,
      Unmanaged.passUnretained(self).toOpaque(),
      &hotKeyHandler
    )
    return status == noErr
  }

  private func hotKeyPressed() {
    guard hotKeyRef != nil else { return }
    hotkeyChannel.invokeMethod("onHotKey", arguments: nil)
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

/// shortcuts_store key names to Carbon virtual key codes.
enum AresHotkeyKeys {
  static func keyCode(for name: String) -> Int? {
    if name.count == 4, name.hasPrefix("key"), let letter = name.last,
       let code = letters[letter] {
      return code
    }
    if name.count == 6, name.hasPrefix("digit"), let digit = name.last,
       let code = digits[digit] {
      return code
    }
    return named[name]
  }

  private static let letters: [Character: Int] = [
    "A": kVK_ANSI_A, "B": kVK_ANSI_B, "C": kVK_ANSI_C, "D": kVK_ANSI_D,
    "E": kVK_ANSI_E, "F": kVK_ANSI_F, "G": kVK_ANSI_G, "H": kVK_ANSI_H,
    "I": kVK_ANSI_I, "J": kVK_ANSI_J, "K": kVK_ANSI_K, "L": kVK_ANSI_L,
    "M": kVK_ANSI_M, "N": kVK_ANSI_N, "O": kVK_ANSI_O, "P": kVK_ANSI_P,
    "Q": kVK_ANSI_Q, "R": kVK_ANSI_R, "S": kVK_ANSI_S, "T": kVK_ANSI_T,
    "U": kVK_ANSI_U, "V": kVK_ANSI_V, "W": kVK_ANSI_W, "X": kVK_ANSI_X,
    "Y": kVK_ANSI_Y, "Z": kVK_ANSI_Z,
  ]

  private static let digits: [Character: Int] = [
    "0": kVK_ANSI_0, "1": kVK_ANSI_1, "2": kVK_ANSI_2, "3": kVK_ANSI_3,
    "4": kVK_ANSI_4, "5": kVK_ANSI_5, "6": kVK_ANSI_6, "7": kVK_ANSI_7,
    "8": kVK_ANSI_8, "9": kVK_ANSI_9,
  ]

  private static let named: [String: Int] = [
    "space": kVK_Space, "enter": kVK_Return, "escape": kVK_Escape,
    "tab": kVK_Tab, "comma": kVK_ANSI_Comma, "period": kVK_ANSI_Period,
    "slash": kVK_ANSI_Slash, "semicolon": kVK_ANSI_Semicolon,
    "quoteSingle": kVK_ANSI_Quote, "backslash": kVK_ANSI_Backslash,
    "minus": kVK_ANSI_Minus, "equal": kVK_ANSI_Equal,
    "bracketLeft": kVK_ANSI_LeftBracket, "bracketRight": kVK_ANSI_RightBracket,
    "backquote": kVK_ANSI_Grave, "arrowLeft": kVK_LeftArrow,
    "arrowRight": kVK_RightArrow, "arrowUp": kVK_UpArrow,
    "arrowDown": kVK_DownArrow, "home": kVK_Home, "end": kVK_End,
    "pageUp": kVK_PageUp, "pageDown": kVK_PageDown,
    "delete": kVK_ForwardDelete,
  ]
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
