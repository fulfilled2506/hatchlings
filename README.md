# Hatchlings: Idle Merge RPG

Phase 1 vertical slice — hatch eggs, merge 3, tap the beast, earn gold while away.

## Run

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then from this folder:

```bash
flutter create . --org com.hatchlings --project-name hatchlings --platforms=ios,android
flutter pub get
flutter test
flutter run
```

`flutter create .` only adds iOS/Android wrappers. It will not overwrite `lib/` or `assets/`.

## Slice

- Tap + auto DPS combat, stages 1–60
- Three gold upgrades (tap, auto, gold find)
- 5×4 nest, 3-merge evolution, 6 hatchlings
- Offline recap (8 hour cap) + local save
- Shop ads/IAP are stubs
