#ifndef RUNNER_DESKTOP_OS_H_
#define RUNNER_DESKTOP_OS_H_

#include <windows.h>

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <memory>
#include <optional>
#include <vector>

#include "desktop_os_logic.h"

namespace flutter {
class FlutterEngine;
}

// The primary window's desktop integration (docs/desktop-os-native.md):
//
//   com.hermesagent.ares/shell  setTray, showWindow, quit; onTrayAction
//
// Created only for the primary window. Pop-out, companion and quick-entry
// children never construct it, so they own no tray icon. Activation stays
// primary-only: this adds no activator, COM server or second instance path.
class DesktopOs {
 public:
  DesktopOs(HWND window, flutter::FlutterEngine* engine);
  ~DesktopOs();

  DesktopOs(const DesktopOs&) = delete;
  DesktopOs& operator=(const DesktopOs&) = delete;

  // Window messages the integration owns (tray callbacks, close-to-tray).
  std::optional<LRESULT> HandleMessage(HWND window, UINT message, WPARAM wparam,
                                       LPARAM lparam);

 private:
  using Result = std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>;

  void HandleShell(const flutter::MethodCall<flutter::EncodableValue>& call,
                   Result result);
  bool InstallTray();
  void RemoveTray();
  void ShowMenu(int x, int y);
  void ShowMain();

  HWND window_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> shell_;

  bool tray_installed_ = false;
  bool close_to_tray_ = false;
  bool menu_open_ = false;
  std::u16string tooltip_;
  std::vector<ares::desktop::TrayItem> items_;
  HICON tray_icon_ = nullptr;
  UINT taskbar_created_ = 0;
};

#endif  // RUNNER_DESKTOP_OS_H_
