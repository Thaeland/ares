#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

// These rely on types from windows.h and must come after it.
#include <appmodel.h>
#include <shobjidl.h>

#include "flutter_window.h"
#include "utils.h"

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
  auto command_line_arguments = GetCommandLineArguments();
  const bool pet_child = command_line_arguments.size() == 1 &&
      (command_line_arguments[0] == "--ares-workspace-chat-v1" ||
       command_line_arguments[0] == "--ares-pet-companion-v1") &&
      ::GetFileType(::GetStdHandle(STD_INPUT_HANDLE)) == FILE_TYPE_PIPE;
  const bool chat_child =
      pet_child &&
      command_line_arguments[0] == "--ares-workspace-chat-v1";
  // Preserve inherited IPC handles. A pop-out must not attach a console.
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!pet_child && !::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // One Ares instance per user: a second launch focuses the running window
  // and exits instead of opening a second chat session.
  HANDLE single_instance = pet_child ? nullptr :
      ::CreateMutexW(nullptr, TRUE, L"Ares.com.hermesagent.ares.single-instance");
  if (!pet_child && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existing = ::FindWindowW(Win32Window::WindowClassName(), L"Ares");
    if (existing) {
      ::ShowWindow(existing, SW_SHOW);
      ::SetForegroundWindow(existing);
    }
    if (single_instance) ::CloseHandle(single_instance);
    return EXIT_SUCCESS;
  }

  // Group the taskbar button under one app identity. Packaged (Store/MSIX)
  // builds get their identity from the package manifest instead.
  if (!HasPackageIdentity()) {
    ::SetCurrentProcessExplicitAppUserModelID(L"com.hermesagent.ares");
  }

  flutter::DartProject project(L"data");
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  const wchar_t* title = chat_child
      ? L"Ares - Chat"
      : pet_child ? L"Ares - Companion" : L"Ares";
  Win32Window::Size size =
      pet_child && !chat_child ? Win32Window::Size(360, 520)
                               : Win32Window::Size(1280, 720);
  if (!window.Create(title, origin, size)) {
    return EXIT_FAILURE;
  }
  if (pet_child && !chat_child) {
    HWND companion = ::FindWindowW(Win32Window::WindowClassName(), title);
    if (companion) {
      ::SetWindowPos(companion, HWND_TOPMOST, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE);
    }
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
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
