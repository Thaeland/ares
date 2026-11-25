#include "desktop_os.h"

#include <shellapi.h>
#include <windowsx.h>

#include <flutter/flutter_engine.h>
#include <flutter/standard_method_codec.h>

#include <string>
#include <variant>

#include "resource.h"

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

constexpr UINT kTrayCallback = WM_APP + 0x41;
constexpr UINT kTrayIconId = 1;

const EncodableValue* Field(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  return it == map.end() ? nullptr : &it->second;
}

bool BoolField(const EncodableMap& map, const char* key) {
  const auto* value = Field(map, key);
  const auto* flag = value ? std::get_if<bool>(value) : nullptr;
  return flag && *flag;
}

std::string StringField(const EncodableMap& map, const char* key) {
  const auto* value = Field(map, key);
  const auto* text = value ? std::get_if<std::string>(value) : nullptr;
  return text ? *text : std::string();
}

std::wstring Wide(const std::u16string& text) {
  return std::wstring(text.begin(), text.end());
}

}  // namespace

DesktopOs::DesktopOs(HWND window, flutter::FlutterEngine* engine)
    : window_(window),
      taskbar_created_(::RegisterWindowMessageW(L"TaskbarCreated")) {
  shell_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      engine->messenger(), "com.hermesagent.ares/shell",
      &flutter::StandardMethodCodec::GetInstance());
  shell_->SetMethodCallHandler([this](const auto& call, auto result) {
    HandleShell(call, std::move(result));
  });
}

DesktopOs::~DesktopOs() {
  RemoveTray();
  if (shell_) shell_->SetMethodCallHandler(nullptr);
  if (tray_icon_) ::DestroyIcon(tray_icon_);
}

void DesktopOs::HandleShell(
    const flutter::MethodCall<EncodableValue>& call, Result result) {
  const std::string& method = call.method_name();
  if (method == "showWindow") {
    ShowMain();
    result->Success();
    return;
  }
  if (method == "quit") {
    // Closing from inside a channel callback would destroy the engine that
    // is dispatching it; post the close instead. Close-to-tray is off now.
    close_to_tray_ = false;
    RemoveTray();
    ::PostMessageW(window_, WM_CLOSE, 0, 0);
    result->Success();
    return;
  }
  if (method == "isTraySupported") {
    result->Success(EncodableValue(true));
    return;
  }
  if (method != "setTray") {
    result->NotImplemented();
    return;
  }
  const auto* args = std::get_if<EncodableMap>(call.arguments());
  if (!args) {
    result->Error("bad-args", "setTray expects a map");
    return;
  }
  if (!BoolField(*args, "enabled")) {
    close_to_tray_ = false;
    RemoveTray();
    result->Success(EncodableValue(false));
    return;
  }
  std::vector<ares::desktop::TrayItem> items;
  const auto* list_value = Field(*args, "items");
  const auto* list = list_value ? std::get_if<EncodableList>(list_value) : nullptr;
  if (list) {
    for (const auto& entry : *list) {
      const auto* map = std::get_if<EncodableMap>(&entry);
      if (!map || items.size() >= ares::desktop::kTrayMaxItems) continue;
      ares::desktop::TrayItem item;
      item.id = StringField(*map, "id");
      item.label = ares::desktop::MenuTextFromUtf8(
          StringField(*map, "label"), ares::desktop::kTrayLabelUnits);
      if (!ares::desktop::ValidTrayItemId(item.id) || item.label.empty()) {
        continue;
      }
      item.checked = BoolField(*map, "checked");
      item.separator_before = BoolField(*map, "separatorBefore");
      items.push_back(std::move(item));
    }
  }
  items_ = std::move(items);
  tooltip_ = ares::desktop::MenuTextFromUtf8(StringField(*args, "tooltip"),
                                             ares::desktop::kTrayTipUnits);
  if (tooltip_.empty()) tooltip_ = u"Ares";
  const bool shown = InstallTray();
  close_to_tray_ = shown && BoolField(*args, "closeToTray");
  result->Success(EncodableValue(shown));
}

bool DesktopOs::InstallTray() {
  if (!tray_icon_) {
    tray_icon_ = static_cast<HICON>(::LoadImageW(
        ::GetModuleHandleW(nullptr), MAKEINTRESOURCEW(IDI_APP_ICON), IMAGE_ICON,
        ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), 0));
  }
  NOTIFYICONDATAW data{};
  data.cbSize = sizeof(data);
  data.hWnd = window_;
  data.uID = kTrayIconId;
  data.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP | NIF_SHOWTIP;
  data.uCallbackMessage = kTrayCallback;
  data.hIcon = tray_icon_;
  const std::wstring tip = Wide(tooltip_);
  ::wcsncpy_s(data.szTip, tip.c_str(), _TRUNCATE);
  if (tray_installed_) {
    tray_installed_ = ::Shell_NotifyIconW(NIM_MODIFY, &data) != FALSE;
    if (tray_installed_) return true;
  }
  if (!::Shell_NotifyIconW(NIM_ADD, &data)) return false;
  data.uVersion = NOTIFYICON_VERSION_4;
  ::Shell_NotifyIconW(NIM_SETVERSION, &data);
  tray_installed_ = true;
  return true;
}

void DesktopOs::RemoveTray() {
  if (!tray_installed_) return;
  NOTIFYICONDATAW data{};
  data.cbSize = sizeof(data);
  data.hWnd = window_;
  data.uID = kTrayIconId;
  ::Shell_NotifyIconW(NIM_DELETE, &data);
  tray_installed_ = false;
}

void DesktopOs::ShowMain() {
  if (!::IsWindowVisible(window_)) ::ShowWindow(window_, SW_SHOW);
  if (::IsIconic(window_)) ::ShowWindow(window_, SW_RESTORE);
  ::SetForegroundWindow(window_);
}

void DesktopOs::ShowMenu(int x, int y) {
  if (menu_open_ || items_.empty()) return;
  HMENU menu = ::CreatePopupMenu();
  if (!menu) return;
  for (size_t i = 0; i < items_.size(); ++i) {
    const auto& item = items_[i];
    if (item.separator_before && i > 0) {
      ::AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
    }
    const std::wstring label = Wide(item.label);
    ::AppendMenuW(menu, MF_STRING | (item.checked ? MF_CHECKED : MF_UNCHECKED),
                  static_cast<UINT_PTR>(ares::desktop::kTrayFirstCommand + i),
                  label.c_str());
  }
  // The menu closes on an outside click only if the owner is foreground.
  ::SetForegroundWindow(window_);
  menu_open_ = true;
  const UINT align = ::GetSystemMetrics(SM_MENUDROPALIGNMENT)
                         ? TPM_RIGHTALIGN
                         : TPM_LEFTALIGN;
  const BOOL command = ::TrackPopupMenuEx(
      menu, TPM_RETURNCMD | TPM_NONOTIFY | TPM_RIGHTBUTTON | align, x, y,
      window_, nullptr);
  menu_open_ = false;
  ::PostMessageW(window_, WM_NULL, 0, 0);
  ::DestroyMenu(menu);
  const auto index = ares::desktop::TrayIndexForCommand(
      static_cast<unsigned>(command), items_.size());
  if (index && shell_) {
    shell_->InvokeMethod(
        "onTrayAction", std::make_unique<EncodableValue>(items_[*index].id));
  }
}

std::optional<LRESULT> DesktopOs::HandleMessage(HWND, UINT message,
                                                WPARAM wparam, LPARAM lparam) {
  if (message == kTrayCallback) {
    switch (LOWORD(lparam)) {
      case NIN_SELECT:
      case NIN_KEYSELECT:
        ShowMain();
        break;
      case WM_CONTEXTMENU:
        ShowMenu(GET_X_LPARAM(wparam), GET_Y_LPARAM(wparam));
        break;
      default:
        break;
    }
    return 0;
  }
  if (taskbar_created_ != 0 && message == taskbar_created_) {
    // Explorer restarted: its notification area forgot the icon.
    if (tray_installed_) {
      tray_installed_ = false;
      InstallTray();
    }
    return std::nullopt;
  }
  if (message == WM_CLOSE && close_to_tray_ && tray_installed_) {
    ::ShowWindow(window_, SW_HIDE);
    return 0;
  }
  return std::nullopt;
}
