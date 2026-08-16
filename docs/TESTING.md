# 테스트 방안

목표는 **루프가 깨지지 않게 보호**하고, **밸런스가 숫자로 재현**되게 하는 것이다. UI 스냅샷보다 경제·머지·세이브가 우선이다.

---

## 피라미드

| 층 | 도구 | 범위 |
|----|------|------|
| 단위 | `flutter_test` | `Economy`, `formatCompact`, 오프라인 계산 |
| 컨트롤러 | `flutter_test` + `MemorySaveStore` | 머지, 탭 킬, 구매, 환생 |
| 슬라이스 | `slice_balance_test.dart` | 900초 적극 플레이 → 스테이지 밴드 |
| 수동 스모크 | Chrome / APK | 탭·머지·오프라인 팝업·탭 전환 |
| (페이즈 3) | CI | `flutter test` on PR, 선택적 `build apk` |

자동화 위치: [`test/`](../test/)

| 파일 | 검증 |
|------|------|
| `economy_test.dart` | HP/비용 곡선, DPS, 환생 크리스탈 |
| `format_test.dart` | K/M/B/aa 표기 |
| `offline_test.dart` | 8h 캡, 알 슬롯 채움, 짧은 부재 팝업 억제 |
| `game_controller_test.dart` | 3머지, 스왑, 탭 보상, 구매, 환생 보존 |
| `slice_balance_test.dart` | 15분 시뮬이 스테이지 40–80 근처 |
| `widget_test.dart` | 최소 스모크 (브랜딩 문자열) |

실행:

```bash
flutter test
flutter test test/slice_balance_test.dart
```

---

## 필수 수동 체크리스트 (릴리스 전)

### 코어 루프
- [ ] 첫 실행: 알 3개, 스테이지 1, 탭으로 적 HP 감소
- [ ] 같은 티어 3개 드래그 → 다음 티어 생성, 도감 해금
- [ ] 강화 구매 후 탭/자동 DPS 체감
- [ ] 앱 백그라운드 1분+ 후 복귀 → 오프라인 골드(조건 충족 시 팝업)

### 메타
- [ ] 스테이지 50 도달 전 Rebirth 잠금
- [ ] Rebirth 후 골드/강화 리셋, Gems·Crystals·도감 유지
- [ ] Shop 스텁: 광고 2×, 젬 +100, 광고제거 플래그

### 빌드
- [ ] `flutter test` green
- [ ] `flutter run -d chrome` 크래시 없음
- [ ] `flutter build apk --debug` 성공 (Android 담당)
- [ ] (iOS) Xcode 서명 후 실기 설치

---

## 밸런스 합격 기준 (페이즈 1)

| 플레이 스타일 | 목표 |
|---------------|------|
| 적극 탭 (~3 taps/s) 15분 | 스테이지 ≈ 45–55, 환생이 “보이기” 시작 |
| 캐주얼 30–45분 | 스테이지 ≈ 50 전후 첫 환생 가능 |
| 순수 방치 15분 | 스테이지가 적극 플레이보다 명확히 낮음 |

밴드가 깨지면 **코드가 아니라** `assets/data/balance.json`을 먼저 조정한다.

---

## 버그 리포트 템플릿

```text
기기/OS:
빌드: (commit SHA / debug|release)
재현:
1.
2.
기대:
실제:
세이브 초기화 여부: Y/N
스크린샷/영상:
```

---

## 페이즈 2–3에서 추가할 테스트

- 유물 구매 후 골드 배율 회귀 테스트
- 일일 미션 자정 리셋 (fake clock)
- AdMob/IAP: 인터페이스 fake로 보상 경로만 단위 테스트 + 실기기 1회 QA
- l10n: 주요 문자열 overflow 수동 체크 (특히 de, ru)
