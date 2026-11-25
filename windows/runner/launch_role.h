#pragma once

#include <string>
#include <vector>
#include "toast_activation.h"

namespace ares {
enum class LaunchRole { primary, chat, pet, toast, invalid };

inline constexpr char kChatPopoutMarker[] = "--ares-workspace-chat-v1";
inline constexpr char kPetCompanionMarker[] = "--ares-pet-companion-v1";

inline LaunchRole ClassifyLaunch(const std::vector<std::string>& args,
                                 bool pipe_input, bool packaged) {
  if (args.empty()) return LaunchRole::primary;
  if (args.front() == kChatPopoutMarker) {
    return args.size() == 1 && pipe_input ? LaunchRole::chat : LaunchRole::invalid;
  }
  if (args.front() == kPetCompanionMarker) {
    return args.size() == 1 && pipe_input ? LaunchRole::pet : LaunchRole::invalid;
  }
  if (args.front().rfind("ares-", 0) == 0) {
    return args.size() == 1 && !toast::ParseActivation(args.front(), packaged).empty()
        ? LaunchRole::toast : LaunchRole::invalid;
  }
  for (const auto& arg : args) {
    if (arg == kChatPopoutMarker || arg == kPetCompanionMarker ||
        arg.rfind("ares-", 0) == 0) {
      return LaunchRole::invalid;  // Reserved arguments cannot be mixed with others.
    }
  }
  return LaunchRole::primary;
}
}  // namespace ares
