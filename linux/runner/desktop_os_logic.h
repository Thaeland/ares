#ifndef RUNNER_DESKTOP_OS_LOGIC_H_
#define RUNNER_DESKTOP_OS_LOGIC_H_

// Platform-free rules for the Linux desktop integration. No GTK here, so
// this header is unit-tested with clang++ -std=c++17 -Wall -Wextra -Werror
// on any host (tool/native_tests/run.sh).

#include <cstddef>
#include <string>
#include <string_view>

namespace ares::desktop {

// Item ids are Dart-defined action names: lower-case words and hyphens.
inline bool ValidTrayItemId(std::string_view id) {
  if (id.empty() || id.size() > 32) return false;
  for (char c : id) {
    if (!((c >= 'a' && c <= 'z') || c == '-')) return false;
  }
  return true;
}

// Keeps valid UTF-8 only, drops C0/C1 controls and DEL, and keeps at most
// [max_chars] characters. GTK labels require valid UTF-8.
inline std::string CleanLabel(std::string_view text, size_t max_chars) {
  std::string out;
  size_t chars = 0;
  size_t i = 0;
  while (i < text.size() && chars < max_chars) {
    const auto b0 = static_cast<unsigned char>(text[i]);
    size_t len = b0 < 0x80             ? 1
                 : (b0 & 0xE0) == 0xC0 ? 2
                 : (b0 & 0xF0) == 0xE0 ? 3
                 : (b0 & 0xF8) == 0xF0 ? 4
                                       : 0;
    char32_t cp = len == 1   ? b0
                  : len == 2 ? (b0 & 0x1F)
                  : len == 3 ? (b0 & 0x0F)
                             : (b0 & 0x07);
    bool valid = len != 0 && i + len <= text.size();
    for (size_t k = 1; valid && k < len; ++k) {
      const auto b = static_cast<unsigned char>(text[i + k]);
      valid = (b & 0xC0) == 0x80;
      cp = (cp << 6) | (b & 0x3F);
    }
    if (valid && ((len == 2 && cp < 0x80) || (len == 3 && cp < 0x800) ||
                  (len == 4 && cp < 0x10000) || cp > 0x10FFFF ||
                  (cp >= 0xD800 && cp <= 0xDFFF))) {
      valid = false;
    }
    if (!valid) {
      i += 1;  // Drop the stray byte.
      continue;
    }
    if (!(cp < 0x20 || (cp >= 0x7F && cp < 0xA0))) {
      out.append(text.substr(i, len));
      ++chars;
    }
    i += len;
  }
  return out;
}

// True for the arguments of a child window process (pop-out chat, companion
// or quick entry). Children never own a tray icon, hotkey or power watcher.
inline bool IsChildWindowMarker(std::string_view arg) {
  return arg == "--ares-workspace-chat-v1" ||
         arg == "--ares-pet-companion-v1" || arg == "--ares-quick-entry-v1";
}

}  // namespace ares::desktop

#endif  // RUNNER_DESKTOP_OS_LOGIC_H_
