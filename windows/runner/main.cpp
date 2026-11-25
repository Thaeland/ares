#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

// These rely on types from windows.h and must come after it.
#include <appmodel.h>
#include <shobjidl.h>

#include "flutter_window.h"
#include "utils.h"
#include "toast_identity.h"
#include <roapi.h>

namespace {

// True when running with MSIX package identity (Microsoft Store / sideload).
bool HasPackageIdentity() {
  UINT32 length = 0;
  return ::GetCurrentPackageFullName(&length, nullptr) !=
         APPMODEL_ERROR_NO_PACKAGE;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  if (FAILED(RoInitialize(RO_INIT_SINGLETHREADED))) return EXIT_FAILURE;
  auto args = GetCommandLineArguments();
  auto token = args.size() == 1 ? ares::toast::ParseActivation(args.front(), HasPackageIdentity()) : "";

  // One Ares instance per user: a second launch focuses the running window
  // and exits instead of opening a second chat session.
  HANDLE single_instance =
      ::CreateMutexW(nullptr, TRUE, (ares::toast::WindowClass() + L".mutex").c_str());
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existing = nullptr;
    // The primary may still be creating its first window.
    for (int i = 0; i < 100 && !existing; ++i) {
      existing = FindWindowW(Win32Window::WindowClassName(), nullptr);
      if (!existing) Sleep(20);
    }
    if (existing) {
      if (!token.empty()) {
        DWORD pid = 0;
        GetWindowThreadProcessId(existing, &pid);
        AllowSetForegroundWindow(pid);
        COPYDATASTRUCT data{0x41524553, static_cast<DWORD>(token.size()), token.data()};
        DWORD_PTR received = 0;
        SendMessageTimeoutW(existing, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&data),
                            SMTO_ABORTIFHUNG, 2000, &received);
      } else if (args.empty()) {
        ::ShowWindow(existing, IsIconic(existing) ? SW_RESTORE : SW_SHOW);
        ::SetForegroundWindow(existing);
      }
    }
    if (single_instance) ::CloseHandle(single_instance);
    RoUninitialize();
    return EXIT_SUCCESS;
  }

  // Group the taskbar button under one app identity. Packaged (Store/MSIX)
  // builds get their identity from the package manifest instead.
  if (!HasPackageIdentity()) {
    ::SetCurrentProcessExplicitAppUserModelID(L"com.hermesagent.ares");
  }

  flutter::DartProject project(L"data");

  // Protocol arguments are untrusted and are not Dart entry-point options.
  if (args.empty() || args.front().rfind("ares-", 0) != 0)
    project.set_dart_entrypoint_arguments(std::move(args));

  FlutterWindow window(project, std::move(token));
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Ares", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (single_instance) {
    ::ReleaseMutex(single_instance);
    ::CloseHandle(single_instance);
  }
  RoUninitialize();
  return EXIT_SUCCESS;
}
