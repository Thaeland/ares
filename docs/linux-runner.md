# Linux GTK runner

The executable is `ares`; its GTK application ID is `com.hermesagent.ares`, matching the macOS and Windows desktop identity. Build the whole bundle and move it as a directory. Running `intermediates_do_not_run/ares`, or copying just `ares`, loses the Flutter engine, plugins, ICU data and AOT application.

## Build on Linux

Use Flutter **3.44.0** (framework `559ffa3f75e7402d65a8def9c28389a9b2e6fe42`, Dart **3.12.0**) on the target architecture. On Debian 12 the native build needs `clang cmake ninja-build pkg-config libstdc++-12-dev libgtk-3-dev libsecret-1-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev`. On arm64, a checkout of the exact Flutter tag can bootstrap the Linux-arm64 Dart SDK and engine; the prebuilt Linux SDK archive for this version has an x64 host SDK. Install prerequisites **inside the build environment**, not on a personal desktop for a fixture run.

```sh
flutter precache --linux
flutter pub get --enforce-lockfile
flutter build linux --release --no-pub
# On arm64 (use x64 instead for a native x64 build):
bundle=build/linux/arm64/release/bundle
tar -C "$bundle" -czf ares-linux-arm64.tar.gz .
# Extract into an empty directory; start ./ares there in a graphical session.
```

`flutter pub get`, not just `dart pub get`, generates Flutter's native plugin registrations. No Linux-only pub dependency or custom engine is needed. The host must provide a GTK3 graphical session/GL driver and the runtime libraries used by the build, including GStreamer and libsecret. Saved credentials need an unlocked Secret Service on the session D-Bus. Audio recording has separate PulseAudio-compatible utilities and encoder requirements; it was not tested by this launch smoke.

## Native fixture smoke

Run as an unprivileged user **inside a disposable Linux container**. Stage the source, SDK, build packages and the fixture's Python dependencies first, then disconnect the container from all networks before launching Ares. Do not mount a home, D-Bus socket, display, Docker socket, configuration or credential store. The script rejects a network namespace with any interface except `lo`; it creates and removes a new HOME, session bus, keyring and Xvfb display for each layout. There is no listener on the host.

Smoke-only dependencies: `python3-venv`, `dbus-x11`, `gnome-keyring`, `xvfb`, `xauth`, `x11-utils`, `xdotool`, `scrot`, `tesseract-ocr` (English), `fonts-dejavu-core`, Mesa software GL. Put `tools/fake_gateway/requirements.txt` in a disposable virtual environment before disconnecting. From the source root, with the venv's Python:

```sh
python scripts/linux_fixture_smoke.py /path/to/unpacked/bundle/ares
```

The script uses the existing synthetic `fixture-copy` chat, not a live gateway. Its loopback-only adapter serves the dashboard read envelopes and accepts NextGen's ticket subprotocol with the fixture's single-use validator. Classic selects a roster row by rendered text; NextGen restores the saved chat. Both checks require an Ares GTK window, a successful WebSocket `session.resume` for that exact fixture ID, and OCR of transcript text, not just a running process. Unhandled Dart exceptions make the smoke fail even when a window stays up.

## Observed on Debian 12 / arm64

- **Baseline:** `v5/shell` commit `cfebbfa8863e2186a894cd9041a791aeef574871`, with this runner and its Linux metadata added. Dart/ARB, assets, `pubspec.yaml` and lock came from the commit, not the concurrently edited worktree. Flutter regenerated the localisations in the disposable copy. Lock SHA-256 remained `6f7298e3be20cff359b3b0439b7df8b320446ed955b35440788fea57a9e7e131`.
- **Build and relocation passed:** release ELF aarch64, `$ORIGIN/lib`, no missing `ldd` dependency on the executable or any of the seven bundled shared objects on this host. Extracted the local tarball into another directory before launch. Runner SHA-256 `efcbcbce7a7eeeda499ff9f180d3d67017543d2e293f63cb97714d0d84bdb42a`; baseline `libapp.so` SHA-256 `b121c1990f6ccef87f16ffe8322d586289dc151c06342c86ac45b7dc1a44873f`. No system install, public artifact or release.
- **Classic:** rendered the roster, selected `UI verification`, resumed `fixture-copy` and rendered the fixture user message. **Smoke failed**: opening the chat also logged `Unhandled Exception: UnimplementedError: getLostData() has not been implemented` from `_ChatScreenState._recoverLostImage` (`image_picker.retrieveLostData()`). This is Android recovery called from shared Dart, not a missing GTK registration. Do not suppress the exception in the runner.
- **NextGen:** restored `fixture-copy` from this layout's saved session preference, resumed it over WebSocket and rendered the Markdown reply. No unhandled Dart exception in this run. No inference, voice, live account or prompt submission was involved.
- **Desktop conditions:** X11/Xvfb, Mesa software rendering, 1280×720 GTK window under `com.hermesagent.ares`. This does not qualify Wayland, GPU drivers, a physical second monitor, x64, desktop notifications, a distribution installer or the other applicable client workflows. **LNX stays open**.

### Pop-out boundary

No additional GTK hook is needed for the shell's **separate-process** hand-off: the runner forwards the arguments after `argv[0]` (`fl_dart_project_set_dart_entrypoint_arguments`), keeps standard streams intact, and uses `G_APPLICATION_NON_UNIQUE`. The baseline binary predates the hand-off; this was tested separately:

1. The concurrent shell snapshot on the same base could not yet compile: the two layout adapters imported `lib/core/workspace/parallel_workspace.dart`, which was not present at capture. No stub was substituted into the shared worktree.
2. To isolate the native hand-off, **only in the container**, kept `lib/core/screens/workspace_screen.dart`, `lib/core/widgets/more_pane.dart`, and `lib/nextgen/ui/more_page.dart` at the baseline version. Compiled the captured production `lib/main.dart` and child bootstrap (SHA-256 prefixes `9e9f159f930a185e` and `d9dc6165ae84b45e`), `popout_owner.dart` (`0bcd0b294e8c2d0c`), `popout_protocol.dart` (`2f77a9b04e73cd60`), and the concurrent chat/vault changes. Snapshot lock SHA-256 `d2efee6b24d08b4dc9a8dcb263d0ddf5eeb640a21261eefcff98f47412a0ebcb`; resulting child-capable `libapp.so` SHA-256 `2c30dfa865a54968601aab837b3095e0be3c3bbce11b5b661f70d1943a6401a4`.
3. With an ordinary Ares window open, a test driver launched the **same executable** with `--ares-workspace-chat-v1`, a fresh fixture home and a valid fixture frame on stdin. In both Classic and NextGen it returned `ARES_WORKSPACE_CHAT_READY_V1`, displayed two Ares GTK windows in distinct processes, resumed `fixture-copy`, and rendered its transcript. Closing stdin exited the child with code 0, leaving one window and the original process alive. The Classic child also exhibited the picker exception above. This proves the child transport, **not** the parent button, workspace interaction, physical monitor placement, or every F05 acceptance clause.

## License evidence and distribution boundary

- Linux CMake/GTK scaffold: [Flutter 3.44.0 source template](https://github.com/flutter/flutter/tree/559ffa3f75e7402d65a8def9c28389a9b2e6fe42/packages/flutter_tools/templates/app/linux.tmpl), Copyright The Flutter Authors, BSD-3-Clause; [full text](../third_party/licenses/flutter-BSD-3-Clause.txt). Product ID, name, title and engine notice installation are Ares customisations. `data/licenses/flutter-engine.txt` is copied verbatim from the matching SDK's `sky_engine/LICENSE`, the notice file identified by its `LICENSE.flutter_gtk.md` (verified byte-for-byte). Keep `data/flutter_assets/NOTICES.Z`, third-party license assets and the MIT application license with the bundle.
- Checked the **locked source licenses** of every compiled native plugin: `audioplayers_linux 4.3.0` (MIT); `file_selector_linux 0.9.4`, `flutter_secure_storage_linux 3.0.2`, `record_linux 2.2.0`, `url_launcher_linux 3.2.2` (BSD-3-Clause). The generated FFI list includes `jni 1.0.0` (BSD-3-Clause); no JVM/JNI library was bundled in this build. All six package names occur in `NOTICES.Z`.
- The existing locked Dart `dbus 0.7.14` package is **MPL-2.0**, not BSD. Confirmed the package name and license text in the bundle's generated notices. No new core package was introduced for Linux; before distributing Linux binaries, review applicable source-availability/notice obligations for [the matching package source](https://pub.dev/packages/dbus/versions/0.7.14) and obtain release-owner clearance. The standard Linux libraries are not uniformly permissive: the build links distro GTK/GLib, libsecret and GStreamer dynamically (LGPL-family and component-specific terms). They were not copied into the tarball. Re-audit before packaging those libraries, codecs, or `ffmpeg`. Test tools do not ship in the app.
