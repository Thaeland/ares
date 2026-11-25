#pragma once
#include <string>

namespace ares::toast {
// Caller must initialise an STA. WinRT failures are propagated to the channel.
bool Enabled();
void Show(int id, const std::string& token, const std::string& body,
          const std::string& sound, bool suppress_popup);
void Cancel(int id);
void CancelAll();
}  // namespace ares::toast
