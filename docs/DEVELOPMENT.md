# Local development and CI

## Prerequisites
- Flutter SDK **3.35.0** (Dart bundled).
- Chrome for Web.
- Android SDK for Android builds.
- On macOS, Xcode for iOS; Apple signing identity for installation and distribution.

## Bootstrap
The repository intentionally omits machine-specific Android/iOS generated templates.
Generate Flutter's official platform skeletons *locally* before running:

```sh
flutter create . --project-name blockpons --platforms=web,android,ios --no-pub
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

Other targets:
```sh
flutter build web --release
flutter build apk --debug
# macOS + Xcode only:
flutter build ios --no-codesign
```

The `flutter create` step generates `android/`, `ios/`, and `web/` using
your locally installed Flutter version. These platform folders are not part
of the first PR; the packaging/CI and platform Issues will follow up with
pinning audited generated scaffolds. Never commit local signing material.

## CI
GitHub Actions creates platform templates from Flutter 3.35.0, formats/analyzes/tests,
then builds the static Web preview and unsigned debug APK.
Artifacts are kept for 7 days. iOS build and real-device tests are *not*
covered by the first workflow.

## Security and asset provenance
No keys, secrets, local configuration, externally downloaded icons,
screenshots, or third-party audio are required to run the game.
All blocks and decorations use code-drawn Flutter vector shapes.
See `docs/SECURITY_AND_ASSETS.md` and `assets/PROVENANCE.md`.

## Current limitations
- UI is code-created and requires a first real browser/device smoke test.
- Animations/audio are intentionally minimal.
- Best score is stored locally; private browsing may refuse persistence.
- Android and iOS packaging/signing/distribution remain future work.
