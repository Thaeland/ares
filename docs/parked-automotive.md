# Ares on the car display

**Android Automotive OS (AAOS):** install the local **Ares Parked** preview on a compatible AAOS development head unit or emulator. It runs the Ares Flutter app on the car itself. Park before opening it. Configure the gateway on the car: there is no dependency on a connected phone, and no copying of phone credentials to the car. Use a test account on a shared vehicle; removing the preview or clearing its app storage removes its local data, not server-side sessions.

**Android Auto (phone projection):** the [existing notification/reply integration](android-auto.md) is unchanged. There is no projected Ares launcher, parked phone mirror or general driving-mode dashboard. Google's [parked app categories](https://developer.android.com/training/cars/parked) do not include a general-purpose agent client; its [messaging requirements](https://developer.android.com/docs/quality-guidelines/car-app-quality#MF-5) require peer-to-peer messaging. The [templated messaging beta](https://developer.android.com/training/cars/communication/templated-messaging) is not a way to display arbitrary Flutter screens. No Play distribution or messaging-category approval is implied on either platform.

## Build and try it

Requires the normal [Ares development toolchain](../README.md) and an AAOS device running Android 13 (API 33) or newer that permits development APK installation. The example builds for arm64; change `--target-platform` to `android-x64` for an x86_64 emulator.

```sh
flutter pub get --enforce-lockfile
flutter build apk --debug --target-platform android-arm64 \
  --dart-define=ARES_PARKED_AUTOMOTIVE=true
APK=build/app/outputs/flutter-apk/app-debug.apk
adb -s "$SERIAL" install -r "$APK"
```

Choose **Ares Parked** in the vehicle launcher. Enter your gateway address and sign in as usual. `localhost` on the car is not your phone or workstation. Use the gateway's reachable HTTPS address. For a local emulator test only, `adb -s "$SERIAL" reverse tcp:18642 tcp:18642` connects the emulator's `127.0.0.1:18642` to a loopback test service on the workstation.

The preview uses the ordinary Android launcher activity with **no** `distractionOptimized` exemption. AAOS decides when it obscures that activity; do not turn off vehicle UX restrictions. The preview is text-first: no microphone, read-aloud, audio/video playback, notification permission, phone car-reply receiver or GitHub APK installer. Storage and updates are isolated under `com.hermesagent.hermes_android.automotive.preview`; this is a debug build for testing, not a release for personal credentials on a production dashboard. Without the flag the phone build and its application ID remain unchanged. Release/profile variants and Play builds are intentionally unavailable with the preview flag.

## Verify it on a dedicated AAOS emulator

With the preview installed and the emulator parked, inspect the **packaged** APK and test the actual driver display. The emulator smoke check changes the simulated driving state and restores park; it refuses a physical device or a non-automotive emulator. Use an API 35 AAOS image with `cmd car_service emulate-driving-state` support.

```sh
"$ANDROID_HOME/cmdline-tools/latest/bin/apkanalyzer" manifest print "$APK" > parked-manifest.xml
python3 scripts/check_parked_automotive.py parked-manifest.xml --emulator "$SERIAL"
```

The expected sequence is Ares visible → OS blocking screen while driving → relaunch still blocked → Ares available after parking. Separately test large-screen onboarding, gateway sign-in and chat continuity, touch/rotary input, keyboard, sleep/resume and offline recovery on the actual target vehicle. Emulator results do not establish OEM behaviour or Play eligibility.
