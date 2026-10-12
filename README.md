# Blockpons

An **original** block-placement puzzle being developed for Web, Android and iOS.
This is an independent project and is not affiliated with Hungry Studio or Block Blast!.

## Status — first playable prototype in development
The first implementation includes an 8 × 8 board, three piece offers, touch/mouse
drag-and-drop, tap-to-place, row/column clearing, a provisional combo-based score,
local best score, game-over detection and retry.

**Not yet verified on physical devices.** iOS packaging/signing is not complete.

## Tech
- Flutter / Dart, single shared game source.
- Pure Dart game rules in `lib/game/domain/` with deterministic unit tests.
- Original, code-drawn visuals. No copied external game art/audio.
- No account, tracking, backend or private credentials.

## Play locally
Install Flutter 3.35.0, then:

```bash
flutter create . --project-name blockpons --platforms=web,android,ios --no-pub
flutter pub get
flutter run -d chrome
```

For tests, run `flutter test`. See [development guide](docs/DEVELOPMENT.md).
CI builds downloadable Web and Android debug artifacts for each PR.

## Rules
See [provisional Blockpons rules](docs/RULES.md). The formula and piece distribution
are **our own design**, not a claim of matching another app.

## Project tracking
- [All Issues](https://github.com/momentspace/blockpons/issues)
- [MVP Epic #1](https://github.com/momentspace/blockpons/issues/1)
- [Product scope](docs/PRODUCT.md)
- [ADR-0001](docs/adr/0001-cross-platform-strategy.md)

## Privacy, original assets, licensing
Read [security & asset rules](docs/SECURITY_AND_ASSETS.md) and
[asset provenance](assets/PROVENANCE.md). Never commit tokens, keystores,
certificates, private config, user data or other sensitive material.

No open-source license has been selected. Public source visibility does not
itself grant a license to redistribute or reuse the code.
