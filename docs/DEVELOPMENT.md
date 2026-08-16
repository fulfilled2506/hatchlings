# 개발 방안

## 스택

| 레이어 | 선택 | 이유 |
|--------|------|------|
| 앱 | Flutter 3.47+ | iOS/Android 단일 코드, UI·상점 비중 큼 |
| 전투/보드 | Flame | 2D 게임 루프, Flutter HUD와 공존 |
| 상태 | `provider` + `GameController` | 단순 ChangeNotifier |
| 세이브 | SharedPreferences JSON | 페이즈 1. 이후 Isar로 교체 가능 (`SaveStore` 추상화) |
| 밸런스 | `assets/data/*.json` | 코드 없이 튜닝, 나중에 Remote Config |
| 수익화 | `Monetization` 인터페이스 + Stub | 페이즈 3에 AdMob/IAP 구현체만 교체 |

의도적으로 쓰지 않음: Unity(오버킬), 풀 서버 멀티, 가챠 인벤토리.

---

## 저장소 구조

```
lib/
  main.dart / app.dart
  core/          # Economy, format, GameSnapshot, strings
  data/          # ContentCatalog, SaveRepository, Monetization
  game/          # GameController, HatchlingsGame (Flame)
  features/      # merge, upgrades, collection, shop, prestige
  ui/            # HomeScreen, HUD, offline popup, theme
assets/data/     # balance.json, creatures.json
test/            # 단위·슬라이스 밸런스·컨트롤러 테스트
android|ios|macos|web/  # 플랫폼 러너
docs/            # 팀 공유 문서 (여기)
```

### 규칙
- **수식은 `lib/core/economy.dart`만.** UI/Flame에서 직접 성장률을 하드코딩하지 않는다.
- **밸런스 숫자는 JSON.** PR로 `balance.json`만 바꿔도 페이싱을 조정할 수 있어야 한다.
- **세이브 I/O는 `SaveStore`.** 컨트롤러는 스토리지 종류를 모른다.
- 새 화면은 `features/<name>/` + 하단 탭에 연결.
- 커밋 메시지: 짧게 why 중심 (기존 스타일 유지).

---

## 브랜치 / 협업

- 기본 작업 브랜치 예: `cursor/hatchlings-idle-slice` → 이후 `main`으로 PR
- 기능 단위: `feat/offline-cap-upgrade`, `fix/merge-third-match` 등
- 비밀키·`local.properties`·키스토어는 커밋 금지 (Flutter `.gitignore` 준수)

---

## 로컬 환경 (macOS)

```bash
cd /Users/hoonlee/hatchlings   # 또는 클론 경로
flutter pub get
flutter test
flutter run -d chrome          # 가장 빠른 확인
flutter build apk --debug      # Android
```

필요 도구:
- Flutter (Homebrew cask 가능)
- JDK 17, Android SDK 36 + NDK (Android 빌드)
- Xcode 전체 설치 (iOS/macOS만)

환경 변수 예 (`~/.zshrc`):

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

---

## 밸런스 튜닝 워크플로

1. `assets/data/balance.json` 수정
2. `flutter test test/slice_balance_test.dart` 로 15분 시뮬 밴드 확인
3. 실기/Chrome에서 5분 손플레이
4. 커밋 메시지에 목표 스테이지·의도 한 줄 적기

---

## 페이즈별 기술 부채

| 페이즈 | 추가 |
|--------|------|
| 2 | 유물 데이터 모델, 일일 미션 스케줄러, 도감 확장 |
| 3 | `google_mobile_ads`, `in_app_purchase`, Firebase Analytics/Crashlytics/Remote Config, l10n ARB |

수익화 구현 시 `lib/data/monetization.dart`의 Stub만 교체하고 UI는 그대로 둔다.
