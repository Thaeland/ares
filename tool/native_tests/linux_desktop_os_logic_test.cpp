// Host-side unit tests for linux/runner/desktop_os_logic.h.
// Build and run: tool/native_tests/run.sh

#include "../../linux/runner/desktop_os_logic.h"

#include <cstdio>
#include <string>

namespace {
int failures = 0;
int checks = 0;

void Check(bool ok, const char* what, int line) {
  ++checks;
  if (!ok) {
    ++failures;
    std::fprintf(stderr, "FAIL line %d: %s\n", line, what);
  }
}
#define CHECK(expr) Check((expr), #expr, __LINE__)

using ares::desktop::CleanLabel;

void TestLabels() {
  CHECK(CleanLabel("Open Ares", 64) == "Open Ares");
  CHECK(CleanLabel("\xD0\x9D\xD0\xBE\xD0\xB2\xD1\x8B\xD0\xB9", 64) ==
        "\xD0\x9D\xD0\xBE\xD0\xB2\xD1\x8B\xD0\xB9");  // Новый
  CHECK(CleanLabel("a\nb\x1b[0m\x7f", 64) == "ab[0m");
  CHECK(CleanLabel("a\xC2\x9B" "b", 64) == "ab");  // C1 CSI
  CHECK(CleanLabel("a\xFF\xFE" "b", 64) == "ab");
  CHECK(CleanLabel("a\xE3\x82", 64) == "a");
  CHECK(CleanLabel("\xC0\xAF", 64).empty());          // overlong
  CHECK(CleanLabel("\xED\xA0\x80", 64).empty());      // surrogate
  CHECK(CleanLabel("abcdef", 3) == "abc");
  // Bounded by characters, never splitting a multi-byte sequence.
  CHECK(CleanLabel("\xE6\x96\xB0\xE8\x81\x8A\xE5\xA4\xA9", 2) ==
        "\xE6\x96\xB0\xE8\x81\x8A");
  CHECK(CleanLabel("a\xF0\x9F\x98\x80" "b", 2) == "a\xF0\x9F\x98\x80");
}

void TestIds() {
  using ares::desktop::IsChildWindowMarker;
  using ares::desktop::ValidTrayItemId;
  CHECK(ValidTrayItemId("quick-entry"));
  CHECK(!ValidTrayItemId("quick_entry"));
  CHECK(!ValidTrayItemId(""));
  CHECK(!ValidTrayItemId(std::string(33, 'q')));
  CHECK(IsChildWindowMarker("--ares-workspace-chat-v1"));
  CHECK(IsChildWindowMarker("--ares-pet-companion-v1"));
  CHECK(IsChildWindowMarker("--ares-quick-entry-v1"));
  CHECK(!IsChildWindowMarker("--ares-quick-entry-v2"));
  CHECK(!IsChildWindowMarker("hermes://launch"));
}

}  // namespace

int main() {
  TestLabels();
  TestIds();
  std::printf("linux desktop_os_logic: %d checks, %d failures\n", checks,
              failures);
  return failures == 0 ? 0 : 1;
}
