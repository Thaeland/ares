#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "ares_platform.h"
#include "toast_activation.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project, std::string initial_toast)
    : project_(project), initial_toast_(std::move(initial_toast)) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  platform_ = std::make_unique<AresPlatform>(GetHandle(),
                                             flutter_controller_->engine());
  toasts_ = std::make_unique<ToastChannel>(flutter_controller_->engine(),
      std::move(initial_toast_), GetHandle());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  // Release the channels before the engine they speak through.
  toasts_ = nullptr;
  platform_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_COPYDATA) {
    const auto* data = reinterpret_cast<const COPYDATASTRUCT*>(lparam);
    if (!data || data->dwData != 0x41524553 || !data->lpData ||
        data->cbData != ares::toast::kTokenSize) return FALSE;
    std::string token(static_cast<const char*>(data->lpData), data->cbData);
    if (!ares::toast::ValidToken(token)) return FALSE;
    if (toasts_) toasts_->Activate(std::move(token));
    else initial_toast_ = std::move(token);
    return TRUE;
  }
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
