# Attribution and status

This repository is a community derivative of
[rusty4444/hermes-android](https://github.com/rusty4444/hermes-android).

The Remote Gateway additions are maintained independently and are not an
official Hermes Agent, Nous Research, or upstream Hermes Android release.

The upstream snapshot used for the Remote Gateway work lacked a canonical
licence file, but its README already declared the application MIT-licensed.
The root [LICENSE](LICENSE) records those existing application terms in full;
it does not relicense third-party code or assets. Copyright and other rights
remain with their respective authors. Source history and contributor
attribution are preserved.

The bundled Cinzel font retains its [SIL Open Font License 1.1](assets/fonts/OFL.txt).
The embedded FCM distributor retains its upstream LGPL-2.1-or-later terms; see
the [Library notice](third_party/embedded-push-notice.md),
[verbatim licence](third_party/licenses/embedded-fcm-distributor-LGPL-2.1.txt)
and [source/relink instructions](third_party/embedded-push-relink.md).
Other dependencies retain their own licences and notices.

Telegram onboarding draws its QR code on the device with the Dart `qr` library
([BSD-3-Clause licence](third_party/licenses/qr-BSD-3-Clause.txt)); no QR
payload is sent to an image-generation service.

Real-time GPT-Live voice conversations use `flutter_webrtc` (`dart_webrtc`,
`webrtc_interface`, `logger`), distributed under the MIT Licence. The gateway
host performs session creation and holds any provider API key.

The completion sounds `ares_mail.wav` and `ares_reminder.wav` (in
`android/app/src/main/res/raw/`, `ios/Runner/` and `macos/Runner/`) and the
in-app chime are original tones made for this application. They contain no
recorded, sampled or third-party audio:
`lib/core/services/completion_tones.dart` synthesises them with plain
arithmetic, and `dart run tool/generate_completion_sounds.dart` rewrites the
bundled files byte for byte (`--check` reports drift). They are covered by the
application's [MIT notice](LICENSE).

Synthetic fixture credentials are test data only. No private gateway
credentials, release signing keys, device profiles, or operator logs are part
of the public source tree.
