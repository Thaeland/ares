#pragma once

// Platform-free rules for the Windows desktop integration (tray, hotkey,
// power events). No windows.h here: the values are the documented Win32
// constants, so this header compiles and is unit-tested with
// clang++ -std=c++17 -Wall -Wextra -Werror on any host
// (tool/native_tests/run.sh).

#include <cstddef>
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace ares::desktop {

// ---- Text -----------------------------------------------------------------

// UTF-8 to UTF-16 for menu labels and the tooltip. Invalid sequences become
// U+FFFD; C0/C1 controls and DEL are dropped so a label cannot carry
// terminal or bidi-free control bytes into a shell menu. At most [max_units]
// code units are kept, never splitting a surrogate pair.
inline std::u16string MenuTextFromUtf8(std::string_view text,
                                       size_t max_units) {
  std::u16string out;
  size_t i = 0;
  auto append = [&](char32_t cp) {
    if (cp < 0x20 || (cp >= 0x7F && cp < 0xA0)) return;
    const size_t need = cp >= 0x10000 ? 2 : 1;
    if (out.size() + need > max_units) {
      i = text.size();  // Stop: never emit half a pair.
      return;
    }
    if (cp >= 0x10000) {
      cp -= 0x10000;
      out.push_back(static_cast<char16_t>(0xD800 + (cp >> 10)));
      out.push_back(static_cast<char16_t>(0xDC00 + (cp & 0x3FF)));
    } else {
      out.push_back(static_cast<char16_t>(cp));
    }
  };
  while (i < text.size()) {
    const auto b0 = static_cast<unsigned char>(text[i]);
    size_t len = 0;
    char32_t cp = 0;
    if (b0 < 0x80) {
      len = 1;
      cp = b0;
    } else if ((b0 & 0xE0) == 0xC0) {
      len = 2;
      cp = b0 & 0x1F;
    } else if ((b0 & 0xF0) == 0xE0) {
      len = 3;
      cp = b0 & 0x0F;
    } else if ((b0 & 0xF8) == 0xF0) {
      len = 4;
      cp = b0 & 0x07;
    }
    bool valid = len != 0 && i + len <= text.size();
    for (size_t k = 1; valid && k < len; ++k) {
      const auto b = static_cast<unsigned char>(text[i + k]);
      if ((b & 0xC0) != 0x80) {
        valid = false;
      } else {
        cp = (cp << 6) | (b & 0x3F);
      }
    }
    // Reject overlong forms, surrogates and values past U+10FFFF.
    if (valid && ((len == 2 && cp < 0x80) || (len == 3 && cp < 0x800) ||
                  (len == 4 && cp < 0x10000) || cp > 0x10FFFF ||
                  (cp >= 0xD800 && cp <= 0xDFFF))) {
      valid = false;
    }
    if (!valid) {
      append(0xFFFD);
      i += 1;
      continue;
    }
    i += len;
    append(cp);
  }
  return out;
}

// ---- Tray menu ------------------------------------------------------------

// Shell_NotifyIcon's szTip holds 128 wide characters including the NUL.
inline constexpr size_t kTrayTipUnits = 127;
inline constexpr size_t kTrayLabelUnits = 64;
inline constexpr size_t kTrayMaxItems = 16;
// Menu command ids: an item's id is kTrayFirstCommand + its index.
inline constexpr unsigned kTrayFirstCommand = 0xA100;

struct TrayItem {
  std::string id;
  std::u16string label;
  bool checked = false;
  bool separator_before = false;
};

// Item ids are Dart-defined action names: lower-case words and hyphens.
inline bool ValidTrayItemId(std::string_view id) {
  if (id.empty() || id.size() > 32) return false;
  for (char c : id) {
    if (!((c >= 'a' && c <= 'z') || c == '-')) return false;
  }
  return true;
}

// The item index for a TrackPopupMenu result, or nothing for 0 (dismissed)
// and any command this menu did not create.
inline std::optional<size_t> TrayIndexForCommand(unsigned command,
                                                 size_t count) {
  if (command < kTrayFirstCommand) return std::nullopt;
  const size_t index = command - kTrayFirstCommand;
  if (index >= count) return std::nullopt;
  return index;
}

// ---- Global hotkey ---------------------------------------------------------

// RegisterHotKey modifiers (winuser.h) and the app's hotkey id (0-0xBFFF).
inline constexpr unsigned kModAlt = 0x0001;
inline constexpr unsigned kModControl = 0x0002;
inline constexpr unsigned kModShift = 0x0004;
inline constexpr unsigned kModNoRepeat = 0x4000;
inline constexpr int kHotkeyId = 0xA7E5;

// The virtual-key code for a shortcuts_store key name, or nothing.
inline std::optional<unsigned> VirtualKeyForName(std::string_view name) {
  if (name.size() == 4 && name.substr(0, 3) == "key" && name[3] >= 'A' &&
      name[3] <= 'Z') {
    return static_cast<unsigned>(name[3]);  // VK_A..VK_Z == 'A'..'Z'
  }
  if (name.size() == 6 && name.substr(0, 5) == "digit" && name[5] >= '0' &&
      name[5] <= '9') {
    return static_cast<unsigned>(name[5]);  // VK_0..VK_9 == '0'..'9'
  }
  struct Entry {
    std::string_view name;
    unsigned vk;
  };
  static constexpr Entry kTable[] = {
      {"space", 0x20},        {"enter", 0x0D},       {"escape", 0x1B},
      {"tab", 0x09},          {"comma", 0xBC},       {"period", 0xBE},
      {"slash", 0xBF},        {"semicolon", 0xBA},   {"quoteSingle", 0xDE},
      {"backslash", 0xDC},    {"minus", 0xBD},       {"equal", 0xBB},
      {"bracketLeft", 0xDB},  {"bracketRight", 0xDD}, {"backquote", 0xC0},
      {"arrowLeft", 0x25},    {"arrowUp", 0x26},     {"arrowRight", 0x27},
      {"arrowDown", 0x28},    {"home", 0x24},        {"end", 0x23},
      {"pageUp", 0x21},       {"pageDown", 0x22},    {"insert", 0x2D},
      {"delete", 0x2E},
  };
  for (const auto& entry : kTable) {
    if (entry.name == name) return entry.vk;
  }
  return std::nullopt;
}

struct HotkeyRequest {
  unsigned vk;
  unsigned modifiers;
};

// RegisterHotKey arguments for a chord, or nothing when it is not allowed:
// the Windows key belongs to the shell, and Ctrl or Alt is required so
// ordinary typing never triggers it.
inline std::optional<HotkeyRequest> HotkeyFor(std::string_view key, bool meta,
                                              bool ctrl, bool alt,
                                              bool shift) {
  if (meta || !(ctrl || alt)) return std::nullopt;
  const auto vk = VirtualKeyForName(key);
  if (!vk) return std::nullopt;
  unsigned modifiers = kModNoRepeat;
  if (ctrl) modifiers |= kModControl;
  if (alt) modifiers |= kModAlt;
  if (shift) modifiers |= kModShift;
  return HotkeyRequest{*vk, modifiers};
}

}  // namespace ares::desktop
