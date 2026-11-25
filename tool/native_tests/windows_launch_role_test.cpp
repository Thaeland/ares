// Host-side unit tests for windows/runner/launch_role.h: the quick-entry
// window is a child role like a pop-out, never an activation path.
// Build and run: tool/native_tests/run.sh

#include "../../windows/runner/launch_role.h"

#include <cstdio>
#include <string>
#include <vector>

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

using ares::ClassifyLaunch;
using ares::LaunchRole;
using Args = std::vector<std::string>;

void TestQuickEntryRole() {
  const std::string token(32, 'a');
  CHECK(ClassifyLaunch({}, false, false) == LaunchRole::primary);
  // Only with a parent pipe on stdin, and only alone.
  CHECK(ClassifyLaunch(Args{"--ares-quick-entry-v1"}, true, false) ==
        LaunchRole::quick_entry);
  CHECK(ClassifyLaunch(Args{"--ares-quick-entry-v1"}, true, true) ==
        LaunchRole::quick_entry);
  CHECK(ClassifyLaunch(Args{"--ares-quick-entry-v1"}, false, false) ==
        LaunchRole::invalid);
  CHECK(ClassifyLaunch(Args{"--ares-quick-entry-v1", "x"}, true, false) ==
        LaunchRole::invalid);
  CHECK(ClassifyLaunch(Args{"x", "--ares-quick-entry-v1"}, true, false) ==
        LaunchRole::invalid);
  CHECK(ClassifyLaunch(Args{"--ares-quick-entry-v2"}, true, false) ==
        LaunchRole::primary);
  // Existing roles are unchanged.
  CHECK(ClassifyLaunch(Args{"--ares-workspace-chat-v1"}, true, false) ==
        LaunchRole::chat);
  CHECK(ClassifyLaunch(Args{"--ares-pet-companion-v1"}, true, false) ==
        LaunchRole::pet);
  CHECK(ClassifyLaunch(Args{"ares-notification:" + token}, false, false) ==
        LaunchRole::toast);
  CHECK(ClassifyLaunch(Args{"ares-notification:" + token,
                            "--ares-quick-entry-v1"},
                       true, false) == LaunchRole::invalid);
}

}  // namespace

int main() {
  TestQuickEntryRole();
  std::printf("windows launch_role: %d checks, %d failures\n", checks,
              failures);
  return failures == 0 ? 0 : 1;
}
