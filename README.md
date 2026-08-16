# Hatchlings: Idle Merge RPG

Phase 1 vertical slice — hatch eggs, merge 3, tap the beast, earn gold while away.

Project path: `/Users/hoonlee/hatchlings`

## Run (this machine)

Flutter 3.47 is installed via Homebrew. Env vars are in `~/.zshrc`.

```bash
cd /Users/hoonlee/hatchlings
flutter pub get
flutter test
flutter run -d chrome          # fastest smoke run
flutter build apk --debug      # Android APK (needs device/emulator for install)
```

iOS / macOS desktop need a full **Xcode** install from the App Store, then:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter run -d ios
```

## Slice

- Tap + auto DPS combat, stages 1–60
- Three gold upgrades (tap, auto, gold find)
- 5×4 nest, 3-merge evolution, 6 hatchlings
- Offline recap (8 hour cap) + local save
- Shop ads/IAP are stubs
