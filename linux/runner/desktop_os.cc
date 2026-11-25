#include "desktop_os.h"

#include <unistd.h>

#include <algorithm>
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
  // Power: logind PrepareForSleep (system bus), the session's Lock/Unlock
  // and LockedHint, and screensaver ActiveChanged (session bus). Keep-awake
  // holds an xdg-desktop-portal Inhibit request (suspend only), or, without
  // a portal, an org.freedesktop.ScreenSaver Inhibit cookie (idle).
  FlMethodChannel* power = nullptr;
  GCancellable* cancellable = nullptr;
  GDBusConnection* system_bus = nullptr;
  GDBusConnection* session_bus = nullptr;
  std::vector<guint> system_signals;
  std::vector<guint> session_signals;
  std::vector<std::string> awake_owners;
  std::string inhibit_handle;
  guint32 screensaver_cookie = 0;
  // Screen capture through the xdg-desktop-portal Screenshot dialog, which
  // is also the user's consent. One capture at a time.
  FlMethodChannel* capture = nullptr;
  FlMethodCall* capture_call = nullptr;
  guint capture_signal = 0;
  std::string capture_directory;
  std::string capture_request;
};

namespace {

void FailCapture(AresDesktopOs* self, const char* code);

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

void EmitPower(AresDesktopOs* self, const char* event) {
  if (self->power == nullptr) return;
  g_autoptr(FlValue) value = fl_value_new_string(event);
  fl_method_channel_invoke_method(self->power, "onPowerEvent", value, nullptr,
                                  nullptr, nullptr);
}

void PrepareForSleepCb(GDBusConnection*, const gchar*, const gchar*,
                       const gchar*, const gchar*, GVariant* parameters,
                       gpointer user_data) {
  if (!g_variant_is_of_type(parameters, G_VARIANT_TYPE("(b)"))) return;
  gboolean starting = FALSE;
  g_variant_get(parameters, "(b)", &starting);
  EmitPower(static_cast<AresDesktopOs*>(user_data),
            starting ? "suspend" : "resume");
}

void SessionLockCb(GDBusConnection*, const gchar*, const gchar*,
                   const gchar*, const gchar* signal, GVariant*,
                   gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  if (g_strcmp0(signal, "Lock") == 0) EmitPower(self, "lock");
  if (g_strcmp0(signal, "Unlock") == 0) EmitPower(self, "unlock");
}

void LockedHintCb(GDBusConnection*, const gchar*, const gchar*, const gchar*,
                  const gchar*, GVariant* parameters, gpointer user_data) {
  if (!g_variant_is_of_type(parameters, G_VARIANT_TYPE("(sa{sv}as)"))) return;
  g_autoptr(GVariant) changed = g_variant_get_child_value(parameters, 1);
  gboolean locked = FALSE;
  if (g_variant_lookup(changed, "LockedHint", "b", &locked)) {
    EmitPower(static_cast<AresDesktopOs*>(user_data),
              locked ? "lock" : "unlock");
  }
}

void ScreenSaverCb(GDBusConnection*, const gchar*, const gchar*, const gchar*,
                   const gchar*, GVariant* parameters, gpointer user_data) {
  if (!g_variant_is_of_type(parameters, G_VARIANT_TYPE("(b)"))) return;
  gboolean active = FALSE;
  g_variant_get(parameters, "(b)", &active);
  EmitPower(static_cast<AresDesktopOs*>(user_data), active ? "lock" : "unlock");
}

// logind names this process's session; its lock signals are per session.
void SessionPathCb(GObject* source, GAsyncResult* result, gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) reply = g_dbus_connection_call_finish(
      G_DBUS_CONNECTION(source), result, &error);
  if (reply == nullptr) return;  // Cancelled (window gone) or no session.
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* path = nullptr;
  g_variant_get(reply, "(&o)", &path);
  if (path == nullptr || self->system_bus == nullptr) return;
  self->system_signals.push_back(g_dbus_connection_signal_subscribe(
      self->system_bus, "org.freedesktop.login1",
      "org.freedesktop.login1.Session", nullptr, path, nullptr,
      G_DBUS_SIGNAL_FLAGS_NONE, SessionLockCb, self, nullptr));
  self->system_signals.push_back(g_dbus_connection_signal_subscribe(
      self->system_bus, "org.freedesktop.login1",
      "org.freedesktop.DBus.Properties", "PropertiesChanged", path,
      "org.freedesktop.login1.Session", G_DBUS_SIGNAL_FLAGS_NONE,
      LockedHintCb, self, nullptr));
}

void WatchPower(AresDesktopOs* self) {
  self->cancellable = g_cancellable_new();
  self->system_bus = g_bus_get_sync(G_BUS_TYPE_SYSTEM, nullptr, nullptr);
  if (self->system_bus != nullptr) {
    self->system_signals.push_back(g_dbus_connection_signal_subscribe(
        self->system_bus, "org.freedesktop.login1",
        "org.freedesktop.login1.Manager", "PrepareForSleep",
        "/org/freedesktop/login1", nullptr, G_DBUS_SIGNAL_FLAGS_NONE,
        PrepareForSleepCb, self, nullptr));
    g_dbus_connection_call(
        self->system_bus, "org.freedesktop.login1", "/org/freedesktop/login1",
        "org.freedesktop.login1.Manager", "GetSessionByPID",
        g_variant_new("(u)", static_cast<guint32>(getpid())),
        G_VARIANT_TYPE("(o)"), G_DBUS_CALL_FLAGS_NONE, 5000,
        self->cancellable, SessionPathCb, self);
  }
  self->session_bus = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, nullptr);
  if (self->session_bus != nullptr) {
    for (const char* iface :
         {"org.freedesktop.ScreenSaver", "org.gnome.ScreenSaver"}) {
      self->session_signals.push_back(g_dbus_connection_signal_subscribe(
          self->session_bus, nullptr, iface, "ActiveChanged", nullptr, nullptr,
          G_DBUS_SIGNAL_FLAGS_NONE, ScreenSaverCb, self, nullptr));
    }
  }
}

void ReleaseInhibit(AresDesktopOs* self) {
  if (self->session_bus != nullptr && !self->inhibit_handle.empty()) {
    g_dbus_connection_call(self->session_bus, "org.freedesktop.portal.Desktop",
                           self->inhibit_handle.c_str(),
                           "org.freedesktop.portal.Request", "Close", nullptr,
                           nullptr, G_DBUS_CALL_FLAGS_NONE, -1, nullptr,
                           nullptr, nullptr);
  }
  if (self->session_bus != nullptr && self->screensaver_cookie != 0) {
    g_dbus_connection_call(
        self->session_bus, "org.freedesktop.ScreenSaver",
        "/org/freedesktop/ScreenSaver", "org.freedesktop.ScreenSaver",
        "UnInhibit", g_variant_new("(u)", self->screensaver_cookie), nullptr,
        G_DBUS_CALL_FLAGS_NONE, -1, nullptr, nullptr, nullptr);
  }
  self->inhibit_handle.clear();
  self->screensaver_cookie = 0;
}

// True when |name| has an owner on |bus| or D-Bus can start it.
bool BusNameAvailable(GDBusConnection* bus, const char* name) {
  g_autoptr(GVariant) owned = g_dbus_connection_call_sync(
      bus, "org.freedesktop.DBus", "/org/freedesktop/DBus",
      "org.freedesktop.DBus", "NameHasOwner", g_variant_new("(s)", name),
      G_VARIANT_TYPE("(b)"), G_DBUS_CALL_FLAGS_NONE, 1000, nullptr, nullptr);
  gboolean has_owner = FALSE;
  if (owned != nullptr) g_variant_get(owned, "(b)", &has_owner);
  if (has_owner) return true;
  g_autoptr(GVariant) activatable = g_dbus_connection_call_sync(
      bus, "org.freedesktop.DBus", "/org/freedesktop/DBus",
      "org.freedesktop.DBus", "ListActivatableNames", nullptr,
      G_VARIANT_TYPE("(as)"), G_DBUS_CALL_FLAGS_NONE, 1000, nullptr, nullptr);
  if (activatable == nullptr) return false;
  g_autofree const gchar** names = nullptr;
  g_variant_get(activatable, "(^a&s)", &names);
  for (const gchar** it = names; it != nullptr && *it != nullptr; ++it) {
    if (strcmp(*it, name) == 0) return true;
  }
  return false;
}

// Keep-awake works only with a portal or a screensaver service to ask.
bool KeepAwakeAvailable(AresDesktopOs* self) {
  if (self->session_bus == nullptr) return false;
  return BusNameAvailable(self->session_bus,
                          "org.freedesktop.portal.Desktop") ||
         BusNameAvailable(self->session_bus, "org.freedesktop.ScreenSaver");
}

// Without a portal: org.freedesktop.ScreenSaver.Inhibit (KDE, GNOME, Xfce
// and others), which blocks idle blanking and idle suspend until UnInhibit or
// until this connection closes.
bool TakeScreenSaverInhibit(AresDesktopOs* self) {
  g_autoptr(GVariant) reply = g_dbus_connection_call_sync(
      self->session_bus, "org.freedesktop.ScreenSaver",
      "/org/freedesktop/ScreenSaver", "org.freedesktop.ScreenSaver", "Inhibit",
      g_variant_new("(ss)", "Ares", "Ares is working on a reply"),
      G_VARIANT_TYPE("(u)"), G_DBUS_CALL_FLAGS_NONE, 2000, nullptr, nullptr);
  if (reply == nullptr) return false;
  g_variant_get(reply, "(u)", &self->screensaver_cookie);
  return self->screensaver_cookie != 0;
}

// Asks the desktop not to suspend (the display may still sleep). Returns
// false when neither the portal nor a screensaver service answers.
bool TakeInhibit(AresDesktopOs* self) {
  if (!self->inhibit_handle.empty() || self->screensaver_cookie != 0) {
    return true;
  }
  if (self->session_bus == nullptr) return false;
  GVariantBuilder options;
  g_variant_builder_init(&options, G_VARIANT_TYPE_VARDICT);
  g_variant_builder_add(&options, "{sv}", "reason",
                        g_variant_new_string("Ares is working on a reply"));
  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) reply = g_dbus_connection_call_sync(
      self->session_bus, "org.freedesktop.portal.Desktop",
      "/org/freedesktop/portal/desktop", "org.freedesktop.portal.Inhibit",
      "Inhibit", g_variant_new("(sua{sv})", "", 4u, &options),
      G_VARIANT_TYPE("(o)"), G_DBUS_CALL_FLAGS_NONE, 2000, nullptr, &error);
  if (reply != nullptr) {
    const gchar* handle = nullptr;
    g_variant_get(reply, "(&o)", &handle);
    if (handle != nullptr) self->inhibit_handle = handle;
  }
  if (!self->inhibit_handle.empty()) return true;
  return TakeScreenSaverInhibit(self);
}

void PowerCallCb(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  FlValue* args = fl_method_call_get_args(call);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, "isSupported") == 0) {
    g_autoptr(FlValue) value = fl_value_new_bool(KeepAwakeAvailable(self));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "setAwake") == 0) {
    const std::string owner = StringArg(args, "owner");
    if (owner.empty() || owner.size() > 128) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "bad-args", "setAwake expects {owner, enabled}", nullptr));
    } else {
      auto& owners = self->awake_owners;
      owners.erase(std::remove(owners.begin(), owners.end(), owner),
                   owners.end());
      if (BoolArg(args, "enabled") && owners.size() < 32) {
        owners.push_back(owner);
      }
      if (owners.empty()) {
        ReleaseInhibit(self);
      } else {
        TakeInhibit(self);
      }
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  Respond(call, response);
}

void StopPower(AresDesktopOs* self) {
  if (self->cancellable != nullptr) {
    g_cancellable_cancel(self->cancellable);
    g_clear_object(&self->cancellable);
  }
  if (self->capture_call != nullptr) FailCapture(self, "cancelled");
  if (self->capture != nullptr) {
    fl_method_channel_set_method_call_handler(self->capture, nullptr, nullptr,
                                              nullptr);
    g_clear_object(&self->capture);
  }
  ReleaseInhibit(self);
  for (guint id : self->system_signals) {
    g_dbus_connection_signal_unsubscribe(self->system_bus, id);
  }
  for (guint id : self->session_signals) {
    g_dbus_connection_signal_unsubscribe(self->session_bus, id);
  }
  self->system_signals.clear();
  self->session_signals.clear();
  g_clear_object(&self->system_bus);
  g_clear_object(&self->session_bus);
  if (self->power != nullptr) {
    fl_method_channel_set_method_call_handler(self->power, nullptr, nullptr,
                                              nullptr);
    g_clear_object(&self->power);
  }
}

void FinishCapture(AresDesktopOs* self, FlMethodResponse* response) {
  if (self->capture_signal != 0 && self->session_bus != nullptr) {
    g_dbus_connection_signal_unsubscribe(self->session_bus,
                                         self->capture_signal);
  }
  self->capture_signal = 0;
  self->capture_request.clear();
  FlMethodCall* call = self->capture_call;
  self->capture_call = nullptr;
  if (call != nullptr) {
    Respond(call, response);
    g_object_unref(call);
  }
}

void FailCapture(AresDesktopOs* self, const char* code) {
  g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
      fl_method_error_response_new(code, nullptr, nullptr));
  FinishCapture(self, response);
}

// Portal Request::Response(u response, a{sv} results): 0 success with a
// file:// "uri", 1 cancelled by the user, 2 any other failure.
void CaptureResponseCb(GDBusConnection*, const gchar*, const gchar* path,
                       const gchar*, const gchar*, GVariant* parameters,
                       gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  if (self->capture_call == nullptr || self->capture_request != path ||
      !g_variant_is_of_type(parameters, G_VARIANT_TYPE("(ua{sv})"))) {
    return;
  }
  guint32 code = 2;
  g_autoptr(GVariant) results = nullptr;
  g_variant_get(parameters, "(u@a{sv})", &code, &results);
  if (code == 1) {
    FailCapture(self, "cancelled");
    return;
  }
  const gchar* uri = nullptr;
  if (code != 0 || !g_variant_lookup(results, "uri", "&s", &uri)) {
    FailCapture(self, "failed");
    return;
  }
  g_autofree gchar* source_path = g_filename_from_uri(uri, nullptr, nullptr);
  if (source_path == nullptr) {
    FailCapture(self, "failed");
    return;
  }
  // Copy into Ares' private folder; the portal's file stays where the
  // desktop saved it.
  g_autofree gchar* name = g_strdup_printf(
      "screenshot-%" G_GINT64_FORMAT ".png", g_get_real_time() / 1000);
  g_autofree gchar* target_path =
      g_build_filename(self->capture_directory.c_str(), name, nullptr);
  g_autoptr(GFile) source = g_file_new_for_path(source_path);
  g_autoptr(GFile) target = g_file_new_for_path(target_path);
  if (!g_file_copy(source, target, G_FILE_COPY_NONE, nullptr, nullptr,
                   nullptr, nullptr)) {
    FailCapture(self, "failed");
    return;
  }
  g_autoptr(FlValue) value = fl_value_new_string(target_path);
  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  FinishCapture(self, response);
}

void ScreenshotCallCb(GObject* source, GAsyncResult* result,
                      gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) reply = g_dbus_connection_call_finish(
      G_DBUS_CONNECTION(source), result, &error);
  if (reply == nullptr) {
    if (g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) return;
    FailCapture(static_cast<AresDesktopOs*>(user_data), "unsupported");
    return;
  }
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* handle = nullptr;
  g_variant_get(reply, "(&o)", &handle);
  // Older portals ignore handle_token: follow the handle they returned.
  if (handle != nullptr && self->capture_request != handle &&
      self->capture_call != nullptr) {
    g_dbus_connection_signal_unsubscribe(self->session_bus,
                                         self->capture_signal);
    self->capture_request = handle;
    self->capture_signal = g_dbus_connection_signal_subscribe(
        self->session_bus, "org.freedesktop.portal.Desktop",
        "org.freedesktop.portal.Request", "Response", handle, nullptr,
        G_DBUS_SIGNAL_FLAGS_NONE, CaptureResponseCb, self, nullptr);
  }
}

void StartCapture(AresDesktopOs* self, FlMethodCall* call) {
  const std::string directory =
      StringArg(fl_method_call_get_args(call), "directory");
  if (directory.empty() || !g_file_test(directory.c_str(), G_FILE_TEST_IS_DIR)) {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("bad-args", "capture expects {directory}",
                                     nullptr));
    Respond(call, response);
    return;
  }
  if (self->session_bus == nullptr || self->capture_call != nullptr) {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_error_response_new(
            self->session_bus == nullptr ? "unsupported" : "failed", nullptr,
            nullptr));
    Respond(call, response);
    return;
  }
  self->capture_call = FL_METHOD_CALL(g_object_ref(call));
  self->capture_directory = directory;
  // Subscribe before calling, at the request path the portal will use.
  g_autofree gchar* token = g_strdup_printf("ares%u", g_random_int());
  std::string sender = g_dbus_connection_get_unique_name(self->session_bus);
  if (!sender.empty() && sender[0] == ':') sender.erase(0, 1);
  std::replace(sender.begin(), sender.end(), '.', '_');
  self->capture_request =
      "/org/freedesktop/portal/desktop/request/" + sender + "/" + token;
  self->capture_signal = g_dbus_connection_signal_subscribe(
      self->session_bus, "org.freedesktop.portal.Desktop",
      "org.freedesktop.portal.Request", "Response",
      self->capture_request.c_str(), nullptr, G_DBUS_SIGNAL_FLAGS_NONE,
      CaptureResponseCb, self, nullptr);
  GVariantBuilder options;
  g_variant_builder_init(&options, G_VARIANT_TYPE_VARDICT);
  g_variant_builder_add(&options, "{sv}", "handle_token",
                        g_variant_new_string(token));
  // Interactive: the user picks the screen, window or area, and consents.
  g_variant_builder_add(&options, "{sv}", "interactive",
                        g_variant_new_boolean(TRUE));
  g_variant_builder_add(&options, "{sv}", "modal",
                        g_variant_new_boolean(TRUE));
  g_dbus_connection_call(
      self->session_bus, "org.freedesktop.portal.Desktop",
      "/org/freedesktop/portal/desktop", "org.freedesktop.portal.Screenshot",
      "Screenshot", g_variant_new("(sa{sv})", "", &options),
      G_VARIANT_TYPE("(o)"), G_DBUS_CALL_FLAGS_NONE, -1, self->cancellable,
      ScreenshotCallCb, self);
}

void CaptureCallCb(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto* self = static_cast<AresDesktopOs*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  if (strcmp(method, "capture") == 0) {
    StartCapture(self, call);
    return;
  }
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, "status") == 0 ||
      strcmp(method, "requestPermission") == 0) {
    // The portal dialog is the consent for each capture.
    g_autoptr(FlValue) value = fl_value_new_map();
    fl_value_set_string_take(value, "supported",
                             fl_value_new_bool(self->session_bus != nullptr));
    fl_value_set_string_take(value, "permission",
                             fl_value_new_string("not-required"));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  } else if (strcmp(method, "openSettings") == 0) {
    g_autoptr(FlValue) value = fl_value_new_bool(FALSE);
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
  // Exit releases the hotkey and keep-awake even if Dart never got to.
  StopPower(self);
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
  self->power = fl_method_channel_new(messenger, "com.hermesagent.ares/power",
                                      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->power, PowerCallCb, self,
                                            nullptr);
  self->capture = fl_method_channel_new(
      messenger, "com.hermesagent.ares/capture", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->capture, CaptureCallCb, self,
                                            nullptr);
  WatchPower(self);
  g_signal_connect(window, "delete-event", G_CALLBACK(DeleteEventCb), self);
  g_signal_connect(window, "destroy", G_CALLBACK(WindowDestroyCb), self);
}
