# Hatchlings: Idle Merge RPG

전 세계 출시용 모바일 **아이들(방치) + 머지 + 탭** 하이브리드.  
Phase 1 세로 슬라이스가 동작한다: 알을 합치고, 탭으로 싸우고, 꺼도 골드가 쌓인다.

## 팀 문서 (기획 / 개발 / 테스트)

Cursor 로컬 플랜은 GitHub에 안 보인다. **아래 `docs/`를 공유 기준으로 쓴다.**

| 문서 | 설명 |
|------|------|
| **[docs/README.md](docs/README.md)** | 문서 인덱스 |
| **[docs/PLAN.md](docs/PLAN.md)** | 제품 기획 · 코어 루프 · 경제 · 화면 |
| **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** | 스택 · 폴더 · 협업 · 로컬 빌드 |
| **[docs/TESTING.md](docs/TESTING.md)** | 자동화 · 수동 QA · 밸런스 합격선 |
| **[docs/ROADMAP.md](docs/ROADMAP.md)** | 페이즈 1–3 · 제외 범위 · 다음 스프린트 |

Repo: https://github.com/fulfilled2506/hatchlings

## 바로 실행

```bash
cd hatchlings          # 클론한 경로
flutter pub get
flutter test
flutter run -d chrome  # 가장 빠른 스모크
flutter build apk --debug
```

iOS는 App Store에서 **Xcode 전체 설치** 후:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter run -d ios
```

## Phase 1 슬라이스 요약

- 탭 + 자동 DPS 전투, 스테이지 진행
- 골드 업그레이드 3종 (Tap / Auto / Gold Find)
- 5×4 둥지, 3머지 진화, 크리처 티어 0–6
- 오프라인 정산(최대 8시간) + 로컬 세이브
- Rebirth (스테이지 50+), 상점 광고/IAP는 스텁
- 밸런스: [`assets/data/balance.json`](assets/data/balance.json)
