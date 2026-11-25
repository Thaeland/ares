#pragma once

#include <string>
#include <vector>
#include "toast_activation.h"

namespace ares {
enum class LaunchRole { primary, chat, toast, invalid };

inline LaunchRole ClassifyLaunch(const std::vector<std::string>& args,
                                 bool pipe_input, bool packaged) {
  if (args.empty()) return LaunchRole::primary;
  if (args.front() == "--ares-workspace-chat-v1") {
    return args.size() == 1 && pipe_input ? LaunchRole::chat : LaunchRole::invalid;
  }
  if (args.front().rfind("ares-", 0) == 0) {
    return args.size() == 1 && !toast::ParseActivation(args.front(), packaged).empty()
        ? LaunchRole::toast : LaunchRole::invalid;
  }
  for (const auto& arg : args) {
    if (arg == "--ares-workspace-chat-v1" || arg.rfind("ares-", 0) == 0) {
      return LaunchRole::invalid;  // Reserved arguments cannot be mixed with others.
    }
  }
  return LaunchRole::primary;
}
}  // namespace ares
