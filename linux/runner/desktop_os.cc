#include "desktop_os.h"

#include <cstring>
#include <string>
#include <vector>

#ifdef GDK_WINDOWING_X11
#include <X11/Xlib.h>
#include <gdk/gdkx.h>
#endif

#include "desktop_os_logic.h"

namespace {

FlValue* MapValue(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  return fl_value_lookup_string(map, key);
}

bool BoolArg(FlValue* map, const char* key) {
  FlValue* value = MapValue(map, key);
  return value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_BOOL &&
         fl_value_get_bool(value);
}

std::string StringArg(FlValue* map, const char* key) {
  FlValue* value = MapValue(map, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return std::string();
  }
  return fl_value_get_string(value);
}

bool IsX11() {
#ifdef GDK_WINDOWING_X11
  return GDK_IS_X11_DISPLAY(gdk_display_get_default());
#else
  return false;
#endif
}

// The bundle's own icon, next to the executable; empty when absent.
std::string BundleIconPath() {
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
  if (exe == nullptr) return std::string();
  g_autofree gchar* dir = g_path_get_dirname(exe);
  g_autofree gchar* path =
      g_build_filename(dir, "data", "flutter_assets", "assets", "icon",
                       "icon.png", nullptr);
  return g_file_test(path, G_FILE_TEST_EXISTS) ? std::string(path)
                                               : std::string();
}

void Respond(FlMethodCall* call, FlMethodResponse* response) {
  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(call, response, &error)) {
    g_warning("desktop_os: failed to respond: %s", error->message);
  }
}

}  // namespace

struct _AresDesktopOs {
  GtkWindow* window = nullptr;
  FlMethodChannel* shell = nullptr;
  // GtkStatusIcon is the XEmbed tray: X11 desktops with a tray host. GNOME
  // needs a tray extension; Wayland has none (setTray reports false).
  GtkStatusIcon* tray = nullptr;
  GtkWidget* menu = nullptr;
  std::vector<std::string> item_ids;
  bool close_to_tray = false;
  // Global hotkey: a passive key grab on the X11 root window. Wayland has no
  // app-registered global shortcut, so register reports "unsupported".
  FlMethodChannel* hotkey = nullptr;
  unsigned hotkey_keycode = 0;
  unsigned hotkey_modifiers = 0;
  bool hotkey_filter = false;
};

namespace {

G_GNUC_BEGIN_IGNORE_DEPRECATIONS

bool TrayEmbedded(AresDesktopOs* self) {
  return self->tray != nullptr && gtk_status_icon_is_embedded(self->tray);
}

void RemoveTray(AresDesktopOs* self) {
  if (self->tray != nullptr) {
    gtk_status_icon_set_visible(self->tray, FALSE);
    g_clear_object(&self->tray);
  }
  if (self->menu != nullptr) {
    gtk_widget_destroy(self->menu);
    self->menu = nullptr;
  }
  self->item_ids.clear();
}

void ShowMain(AresDesktopOs* self) {
  GtkWidget* widget = GTK_WIDGET(self->window);
  gtk_widget_show(widget);
  gtk_window_deiconify(self->window);
  gtk_window_present(self->window);
}

void TrayActivateCb(GtkStatusIcon*, gpointer user_data) {
  ShowMain(static_cast<AresDesktopOs*>(user_data));
}

void TrayPopupCb(GtkStatusIcon*, guint, guint, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  if (self->menu == nullptr) return;
  gtk_menu_popup_at_pointer(GTK_MENU(self->menu), nullptr);
}

void MenuItemActivateCb(GtkMenuItem* item, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const size_t index =
      GPOINTER_TO_SIZE(g_object_get_data(G_OBJECT(item), "ares-index"));
  if (index >= self->item_ids.size() || self->shell == nullptr) return;
  g_autoptr(FlValue) id = fl_value_new_string(self->item_ids[index].c_str());
  fl_method_channel_invoke_method(self->shell, "onTrayAction", id, nullptr,
                                  nullptr, nullptr);
}

bool ApplyTray(AresDesktopOs* self, FlValue* args) {
  if (!BoolArg(args, "enabled") || !IsX11()) {
    self->close_to_tray = false;
    RemoveTray(self);
    return false;
  }
  if (self->tray == nullptr) {
    const std::string icon = BundleIconPath();
    self->tray = icon.empty()
                     ? gtk_status_icon_new_from_icon_name(APPLICATION_ID)
                     : gtk_status_icon_new_from_file(icon.c_str());
    g_signal_connect(self->tray, "activate", G_CALLBACK(TrayActivateCb), self);
    g_signal_connect(self->tray, "popup-menu", G_CALLBACK(TrayPopupCb), self);
  }
  std::string tooltip = ares::desktop::CleanLabel(StringArg(args, "tooltip"), 127);
  gtk_status_icon_set_tooltip_text(self->tray,
                                   tooltip.empty() ? "Ares" : tooltip.c_str());
  gtk_status_icon_set_title(self->tray, "Ares");

  if (self->menu != nullptr) gtk_widget_destroy(self->menu);
  self->menu = gtk_menu_new();
  self->item_ids.clear();
  FlValue* items = MapValue(args, "items");
  const size_t count = items != nullptr &&
                               fl_value_get_type(items) == FL_VALUE_TYPE_LIST
                           ? fl_value_get_length(items)
                           : 0;
  for (size_t i = 0; i < count && self->item_ids.size() < 16; ++i) {
    FlValue* entry = fl_value_get_list_value(items, i);
    const std::string id = StringArg(entry, "id");
    const std::string label =
        ares::desktop::CleanLabel(StringArg(entry, "label"), 64);
    if (!ares::desktop::ValidTrayItemId(id) || label.empty()) continue;
    if (BoolArg(entry, "separatorBefore") && !self->item_ids.empty()) {
      gtk_menu_shell_append(GTK_MENU_SHELL(self->menu),
                            gtk_separator_menu_item_new());
    }
    GtkWidget* item;
    if (MapValue(entry, "checked") != nullptr) {
      item = gtk_check_menu_item_new_with_label(label.c_str());
      gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(item),
                                     BoolArg(entry, "checked"));
    } else {
      item = gtk_menu_item_new_with_label(label.c_str());
    }
    g_object_set_data(G_OBJECT(item), "ares-index",
                      GSIZE_TO_POINTER(self->item_ids.size()));
    g_signal_connect(item, "activate", G_CALLBACK(MenuItemActivateCb), self);
    gtk_menu_shell_append(GTK_MENU_SHELL(self->menu), item);
    self->item_ids.push_back(id);
  }
  gtk_widget_show_all(self->menu);
  gtk_status_icon_set_visible(self->tray, TRUE);
  self->close_to_tray = BoolArg(args, "closeToTray");
  return true;
}

G_GNUC_END_IGNORE_DEPRECATIONS

#ifdef GDK_WINDOWING_X11
constexpr unsigned kLockVariants[] = {
    0, ares::desktop::kLockMask, ares::desktop::kMod2Mask,
    ares::desktop::kLockMask | ares::desktop::kMod2Mask};

void UngrabHotkey(AresDesktopOs* self) {
  if (self->hotkey_keycode == 0) return;
  GdkDisplay* display = gdk_display_get_default();
  if (display != nullptr && GDK_IS_X11_DISPLAY(display)) {
    Display* xdisplay = GDK_DISPLAY_XDISPLAY(display);
    const Window root = DefaultRootWindow(xdisplay);
    gdk_x11_display_error_trap_push(display);
    for (unsigned lock : kLockVariants) {
      XUngrabKey(xdisplay, static_cast<int>(self->hotkey_keycode),
                 self->hotkey_modifiers | lock, root);
    }
    XSync(xdisplay, False);
    gdk_x11_display_error_trap_pop_ignored(display);
  }
  self->hotkey_keycode = 0;
  self->hotkey_modifiers = 0;
}

GdkFilterReturn HotkeyFilter(GdkXEvent* native, GdkEvent*, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  auto* event = static_cast<XEvent*>(native);
  if (event->type != KeyPress || self->hotkey_keycode == 0 ||
      event->xkey.keycode != self->hotkey_keycode ||
      !ares::desktop::X11StateMatches(event->xkey.state,
                                      self->hotkey_modifiers)) {
    return GDK_FILTER_CONTINUE;
  }
  if (self->hotkey != nullptr) {
    fl_method_channel_invoke_method(self->hotkey, "onHotKey", nullptr, nullptr,
                                    nullptr, nullptr);
  }
  return GDK_FILTER_REMOVE;
}

const char* GrabHotkey(AresDesktopOs* self, FlValue* args) {
  const unsigned modifiers = ares::desktop::X11HotkeyModifiers(
      BoolArg(args, "meta"), BoolArg(args, "ctrl"), BoolArg(args, "alt"),
      BoolArg(args, "shift"));
  const std::string keysym_name =
      ares::desktop::X11KeysymName(StringArg(args, "key"));
  if (modifiers == 0 || keysym_name.empty()) return "invalid";
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr || !GDK_IS_X11_DISPLAY(display)) return "unsupported";
  Display* xdisplay = GDK_DISPLAY_XDISPLAY(display);
  const KeySym keysym = XStringToKeysym(keysym_name.c_str());
  const KeyCode keycode =
      keysym == NoSymbol ? 0 : XKeysymToKeycode(xdisplay, keysym);
  if (keycode == 0) return "invalid";
  UngrabHotkey(self);
  const Window root = DefaultRootWindow(xdisplay);
  gdk_x11_display_error_trap_push(display);
  for (unsigned lock : kLockVariants) {
    XGrabKey(xdisplay, keycode, modifiers | lock, root, False, GrabModeAsync,
             GrabModeAsync);
  }
  XSync(xdisplay, False);
  // BadAccess: another client already grabbed this chord.
  if (gdk_x11_display_error_trap_pop(display) != 0) {
    gdk_x11_display_error_trap_push(display);
    for (unsigned lock : kLockVariants) {
      XUngrabKey(xdisplay, keycode, modifiers | lock, root);
    }
    XSync(xdisplay, False);
    gdk_x11_display_error_trap_pop_ignored(display);
    return "conflict";
  }
  self->hotkey_keycode = keycode;
  self->hotkey_modifiers = modifiers;
  if (!self->hotkey_filter) {
    gdk_window_add_filter(gdk_get_default_root_window(), HotkeyFilter, self);
    self->hotkey_filter = true;
  }
  return "registered";
}
#else
void UngrabHotkey(AresDesktopOs*) {}
const char* GrabHotkey(AresDesktopOs*, FlValue*) { return "unsupported"; }
#endif

void HotkeyCallCb(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, "unregister") == 0) {
    UngrabHotkey(self);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "register") == 0) {
    g_autoptr(FlValue) value =
        fl_value_new_string(GrabHotkey(self, fl_method_call_get_args(call)));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  Respond(call, response);
}

gboolean QuitIdleCb(gpointer user_data) {
  g_application_quit(G_APPLICATION(user_data));
  g_object_unref(user_data);
  return G_SOURCE_REMOVE;
}

// Closing hides the window only while a tray host shows the icon, so the
// window can always be brought back.
gboolean DeleteEventCb(GtkWidget* widget, GdkEvent*, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  if (self->close_to_tray && TrayEmbedded(self)) {
    gtk_widget_hide(widget);
    return TRUE;
  }
  return FALSE;
}

void ShellCallCb(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  FlValue* args = fl_method_call_get_args(call);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, "showWindow") == 0) {
    ShowMain(self);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "quit") == 0) {
    self->close_to_tray = false;
    RemoveTray(self);
    GtkApplication* app = gtk_window_get_application(self->window);
    if (app != nullptr) g_idle_add(QuitIdleCb, g_object_ref(app));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "isTraySupported") == 0) {
    g_autoptr(FlValue) value = fl_value_new_bool(IsX11());
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setTray") == 0) {
    g_autoptr(FlValue) value = fl_value_new_bool(ApplyTray(self, args));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  Respond(call, response);
}

}  // namespace

namespace {

// The integration lives exactly as long as the primary window.
void WindowDestroyCb(GtkWidget*, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  // Exit releases the hotkey even if Dart never got to unregister it.
  UngrabHotkey(self);
#ifdef GDK_WINDOWING_X11
  if (self->hotkey_filter) {
    gdk_window_remove_filter(gdk_get_default_root_window(), HotkeyFilter, self);
  }
#endif
  if (self->hotkey != nullptr) {
    fl_method_channel_set_method_call_handler(self->hotkey, nullptr, nullptr,
                                              nullptr);
    g_clear_object(&self->hotkey);
  }
  RemoveTray(self);
  if (self->shell != nullptr) {
    fl_method_channel_set_method_call_handler(self->shell, nullptr, nullptr,
                                              nullptr);
    g_clear_object(&self->shell);
  }
  delete self;
}

}  // namespace

void ares_desktop_os_attach(FlView* view, GtkWindow* window) {
  auto* self = new _AresDesktopOs();
  self->window = window;
  FlEngine* engine = fl_view_get_engine(view);
  FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->shell = fl_method_channel_new(messenger, "com.hermesagent.ares/shell",
                                      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->shell, ShellCallCb, self,
                                            nullptr);
  self->hotkey = fl_method_channel_new(messenger, "com.hermesagent.ares/hotkey",
                                       FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->hotkey, HotkeyCallCb, self,
                                            nullptr);
  g_signal_connect(window, "delete-event", G_CALLBACK(DeleteEventCb), self);
  g_signal_connect(window, "destroy", G_CALLBACK(WindowDestroyCb), self);
}
