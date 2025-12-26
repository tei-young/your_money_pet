# 📋 TODO & Task Tracking

> **실시간 업데이트 문서** - 개발 진행 상황과 남은 작업 추적

마지막 업데이트: 2025-12-24 (애니메이션 재설계: 10개 → 13개 상태, 통합 애니메이션 방식)

---

## 🚨 긴급 (High Priority)

### 1. Google 로그인/회원가입 구현 ⭐⭐⭐
**상태:** ✅ 완료 (2025-11-27, Android 테스트 완료)
**우선순위:** P0 (필수)
**담당:** TBD
**예상 소요:** 1-2일 (Firebase Auth 연동)
**실제 완료:**
- UI 구현 0.5일 (2025-01-15)
- Firebase 기본 설정 0.5일 (2025-11-26)
- AuthService 구현 0.5일 (2025-11-27)
- Google Sign-In 테스트 완료 (Android, 2025-11-27)

**요구사항:**
- Firebase Authentication 연동 ✅
- Google OAuth 로그인 ✅
- 직접 회원가입 (이메일/비밀번호) ✅
- 온보딩 완료 후 → 홈 화면 진입 전 필수 로그인 ✅
- ✅ 강제 로그인 방식 확정 ("나중에 하기" 없음)

**구현 화면:** ✅ 완료
```
온보딩 완료 → [로그인/회원가입 화면] → 홈 화면
                ↓
        ┌─────────────────┐
        │  학습을 시작해봐요! │
        │  로그인이 필요해요  │
        │                 │
        │  로그인 | 회원가입 │ ← 탭 전환
        │                 │
        │ [이메일 입력]    │
        │ [비밀번호 입력]  │
        │                 │
        │ [로그인하기]     │
        │                 │
        │ ──── 또는 ──── │
        │                 │
        │ [Google 로그인]  │
        └─────────────────┘
```

**완료된 작업:**
- [x] `lib/screens/auth/login_screen.dart` 생성 ✅
- [x] 로그인/회원가입 탭 전환 UI (토글 방식) ✅
- [x] 이메일/비밀번호 입력 폼 + 검증 ✅
- [x] Google 로그인 버튼 ✅
- [x] 목표 설정 → 로그인 화면 네비게이션 ✅
- [x] 목표 설정 시 UserProvider.createUser() 호출 ✅
- [x] **Firebase 기본 설정 완료** ✅ (2025-11-26)
  - [x] `firebase_options.dart` 생성 (FlutterFire CLI)
  - [x] Android: google-services.json + build.gradle 설정
  - [x] iOS: GoogleService-Info.plist 설정
  - [x] main.dart: Firebase.initializeApp() 호출
- [x] Firebase 패키지 업그레이드 (GoogleUtilities 8.x 지원) ✅
  - [x] firebase_core: 2.27.0 → 3.6.0
  - [x] cloud_firestore: 4.15.8 → 5.4.4
  - [x] firebase_auth: 4.17.8 → 5.3.1
  - [x] firebase_storage: 11.6.9 → 12.3.4
  - [x] firebase_analytics: 10.8.9 → 11.3.3
- [x] `firebase_auth`, `google_sign_in` 패키지 추가 ✅
- [x] **`lib/services/auth_service.dart` 생성** ✅
  - [x] Google Sign-In 구현
  - [x] 이메일/비밀번호 회원가입/로그인
  - [x] 한국어 에러 메시지 (14가지 Firebase 에러)
  - [x] 로그아웃 기능
- [x] **login_screen.dart에 AuthService 통합** ✅
  - [x] 이메일 로그인/회원가입 연동
  - [x] Google Sign-In 버튼 연동
  - [x] 에러 핸들링 및 로딩 상태
- [x] iOS CocoaPods 설정 (ios/Podfile) ✅
- [x] Android SHA-1 지문 추가 (Firebase Console) ✅
- [x] **Google Sign-In 테스트 완료 (Android)** ✅

**다음 작업 (Firestore 연동):**
- [ ] UserProvider에 Firebase UID 매핑
- [ ] 로그인 후 사용자 데이터 Firestore 동기화
- [ ] 회원가입 시 Firestore에 프로필 생성
- [ ] AuthStateChanges 리스너 추가

**참고:**
- Firestore Security Rules: `/users/{userId}` 본인만 읽기/쓰기
- 로그인 없이 온보딩 내용은 로컬 메모리에 임시 저장
- 로그인 시 Firestore에 영구 저장

---

### 2. 프레임 기반 캐릭터 애니메이션 구현
**상태:** 🔴 코드 재설계 필요 (2025-12-24) / 🟡 애니메이션 제작 대기
**우선순위:** P0 (긴급) ⭐⭐⭐
**담당:**
  - 개발팀: 13-state 시스템 코드 재설계 필요
  - 디자인팀: Midjourney/Runway로 통합 애니메이션 제작

**전략 변경:** Rive → 프레임 기반 PNG 시퀀스 (2025-12-13) → **통합 애니메이션 방식 (2025-12-24)**
- **배경:** 개별 상태 조합 시 프레임 불일치로 전환이 끊기는 UX 문제 발견
- **해결:** 화면별 통합 애니메이션 제작 (예: quiz_correct_flow = thinking → happy → idle 복귀를 하나의 애니메이션으로)
- **상세 문서:** `docs/FRAME_ANIMATION_GUIDE.md`, `docs/ANIMATION_UPDATE_2025-12-13.md`

**애니메이션 사양 (2025-12-24 재설계):**
- **포맷:** PNG (600x600px, 투명 배경) → WebP 변환 (40% 용량 절감)
- **프레임 레이트:** 24fps (영화급 부드러움)
- **제작 툴:** Midjourney Video / Runway → ffmpeg PNG 추출 → WebP 변환
- **총 상태:** 13개 (기존 10개 → 13개)
- **총 용량:** ~192MB (PNG) / ~96MB (WebP 변환 시)
- **핵심 변경:** 개별 상태 조합 방식 → 화면별 통합 애니메이션 방식

**완료된 개발 작업:**
- [x] 2025-12-13: 프레임 기반 애니메이션 시스템 구현
  - [x] `lib/models/character_frame_animation.dart` 생성
  - [x] `lib/widgets/animated_character.dart` 완전 재작성
  - [x] `lib/services/character_animation_preloader.dart` 생성
  - [x] `CharacterAnimationState` enum 확장 (idle, selected, happy, thinking, confused)
  - [x] 폴더 구조 생성 (`assets/animations/characters/`)
  - [x] `pubspec.yaml` asset 경로 등록
  - [x] Fallback 로직 (프레임 없을 시 Placeholder)
  - [x] Progressive loading 전략 구현
- [x] 2025-12-16: JSON 설정 시스템 구축
  - [x] `lib/services/animation_config_loader.dart` 생성 (JSON 로더)
  - [x] `animation_config.json` 4개 생성 (캐릭터별)
  - [x] `CharacterFrameAnimation.forStateAsync()` 추가
  - [x] `AnimatedCharacter` async 로딩 지원
  - [x] 코드 수정 없이 프레임 수 변경 가능
- [x] 2025-12-19: PNG 지원 및 버그 수정
  - [x] PNG 포맷 지원 (`.webp` → `.png`)
  - [x] 상태 전환 에러 방지 로직
  - [x] Placeholder fallback 개선
  - [x] **AnimationController 크래시 수정** (치명적 버그)
  - [x] SingleTickerProviderStateMixin → TickerProviderStateMixin
  - [x] Controller 재사용 패턴 도입
  - [x] **Placeholder 깜빡임 제거** (상태 전환 시)
  - [x] **온보딩 캐릭터 크기 증가**
    - 캐릭터 선택: 100→180, 성향 결과: 150→270, 성향 테스트: 80→160
  - [x] **오버플로우 수정** (패딩/간격 최적화)
  - [x] **성향 테스트 레이아웃 조정** (116px 상단 이동)
  - [x] hunter_cat idle/selected 테스트 완료
- [x] 2025-12-23: 애니메이션 상태 체계 재설계 (10-state)
  - [x] `CharacterAnimationState` enum 확장 (8개 → 14개, 실제 사용 10개)
  - [x] **idle → greeting 이름 변경** (기존 손 흔드는 애니메이션)
  - [x] **새로운 idle 개념 도입** (5초 복합 애니메이션, 캐릭터 성향 표현)
  - [x] **홈 화면 상태 4개 추가** (home_studying, home_excited, home_sleepy, home_celebration)
  - [x] 폴더 구조 변경 (idle/ → greeting/, 신규 폴더 5개 생성)
  - [x] animation_config.json 업데이트 (4개 캐릭터)
  - [x] pubspec.yaml 업데이트 (신규 폴더 경로 등록)
  - [x] 코드 사용처 업데이트 (idle → greeting/thinking)
  - [x] 문서 전면 개편 (FRAME_ANIMATION_GUIDE.md, README.md)
- [ ] 2025-12-24: **통합 애니메이션 방식 재설계 (13-state)** 🟡 진행 중
  - [x] **CharacterAnimationState enum 재설계** (14개 → 13개) ✅ 2025-12-24
    - [x] 기존 상태 삭제: `thinking`, `happy`, `confused`, `reactionPositive/Negative/Neutral` (6개)
    - [x] 새로운 상태 추가: `personalityIdle`, `personalitySelected`, `quizIdle`, `quizCorrectFlow`, `quizWrongFlow`, `resultCelebration` (6개)
    - [x] 이름 변경: `greeting` → `characterGreetingLoop`, `selected` → `characterSelected`, `idle` → `homeIdle` (3개)
    - [x] 결과: 13개 상태 (통합 애니메이션 방식)
    - [x] 파일: `lib/models/character_animation_config.dart:1-25`
    - [x] Commit: 1695ecc
  - [x] **Enum → 폴더명 변환 로직 구현** ✅ 2025-12-24
    - [x] `_stateToFolderName()` 헬퍼 함수 추가 (13개 상태 모두 매핑)
    - [x] `getFramePath()` 메서드 업데이트 (snake_case 폴더명 사용)
    - [x] `forState()` fallback 메서드 13개 상태로 재작성
    - [x] 파일: `lib/models/character_frame_animation.dart:22-224`
    - [x] Commit: 5e2f0b3
  - [x] **자동 전환 로직 구현** ✅ 2025-12-24
    - [x] `CharacterFrameAnimation`에 `autoTransitionTo` 필드 추가
    - [x] `AnimationConfigLoader`에서 JSON `autoTransitionTo` 읽기 지원
    - [x] `AnimatedCharacter`에 자동 전환 처리 로직 구현
    - [x] `_handleAutoTransition()`, `_stringToState()` 메서드 추가
    - [x] 파일: `lib/models/character_frame_animation.dart:7-27`, `lib/services/animation_config_loader.dart:65-72`, `lib/widgets/animated_character.dart:40-236`
    - [x] Commit: a6c6108
  - [x] **폴더 구조 재편 (git mv)** ✅ 2025-12-24
    - [x] 이름 변경: `greeting/` → `character_greeting_loop/`, `selected/` → `character_selected/`
    - [x] 삭제: `idle/`, `thinking/`, `happy/`, `confused/` (빈 폴더 또는 통합 애니메이션에 포함)
    - [x] 신규 생성 (7개): `personality_idle/`, `personality_selected/`, `quiz_idle/`, `quiz_correct_flow/`, `quiz_wrong_flow/`, `result_celebration/`, `home_idle/`
    - [x] 최종 결과: 4개 캐릭터 × 13개 상태 = 52개 폴더 완성
    - [x] 파일: `assets/animations/characters/*/`
    - [x] Commit: 088b510
  - [x] **animation_config.json 재작성** ✅ 2025-12-24
    - [x] 13개 상태로 업데이트
    - [x] `autoTransitionTo` 필드 추가 (personalitySelected, quizCorrectFlow, quizWrongFlow, homeCelebration)
    - [x] 유연한 타이밍 정책 반영 ("약 X초" 형식, 정확한 프레임 수는 제작 후 확정)
    - [x] 파일: `assets/animations/characters/*/animation_config.json` (4개)
    - [x] Commit: e5ab1c6
  - [x] **화면별 State 사용 업데이트** ✅ 2025-12-24
    - [x] 캐릭터 선택: `greeting` → `characterGreetingLoop`, `selected` → `characterSelected`
    - [x] 성향 퀴즈: `thinking` → `personalityIdle`
    - [x] 성향 결과: `selected` → `resultCelebration`
    - [x] 프리로더: `greeting/selected/happy/thinking/confused` → 13-state 온보딩 상태들
    - [x] 파일: `character_preview_screen.dart`, `personality_test_screen.dart`, `personality_result_screen.dart`, `character_animation_preloader.dart`
    - [x] Commit: bb8d045
  - [x] **pubspec.yaml 업데이트** ✅ 2025-12-24
    - [x] 52개 폴더 경로 등록 (4캐릭터 × 13상태)
    - [x] 10-state 경로 삭제 및 13-state 경로 등록
    - [x] Commit: 5950ff5
  - [x] **문서 전면 수정** ✅ 2025-12-24
    - [x] DEVELOPMENT_LOG.md: 2025-12-24 섹션 추가 (Task #1-7 완료 내역)
    - [x] FRAME_ANIMATION_GUIDE.md: 13-state, 통합 애니메이션 (이미 업데이트됨)
    - [x] ANIMATION_UPDATE_2025-12-13.md: 최종 스펙 업데이트 (Commit 4c3359a)
    - [x] README.md: 13-state 시스템, Rive → 프레임 애니메이션 변경
    - [x] assets/animations/characters/README.md: 폴더 구조 업데이트 (이미 업데이트됨)

**디자인팀 작업 (2025-12-24 재설계 - 13-state 통합 애니메이션):**

**⚠️ 중요 변경사항:**
- **타이밍 정책:** "정확히 XX프레임" → "약 X초" (유연한 정책)
- **프레임 수:** 제작 후 실제 프레임 수를 JSON에 기록
- **통합 애니메이션:** thinking/happy/confused는 별도 제작 안 함 (quiz_correct_flow/quiz_wrong_flow에 포함)

**Phase 1: 온보딩 (4개 × 4캐릭터 = 16개) 🎯 최우선**
- [ ] **character_greeting_loop** (약 5초, loop)
  - [x] hunter_cat: 125프레임 ✅ (기존 greeting 재활용)
  - [ ] money_bear, save_sheep, chaser_fox
- [ ] **character_selected** (약 1-2초, one-shot)
  - [ ] hunter_cat: 재제작 필요 ⚠️ (기존 200프레임은 너무 김)
  - [ ] money_bear, save_sheep, chaser_fox
- [ ] **personality_idle** (약 3초, loop)
  - [ ] 조용한 숨쉬기 + 호기심 표정
  - [ ] 모든 캐릭터
- [ ] **personality_selected** (약 2초, one-shot → auto to personality_idle)
  - [ ] 0-1초: 고개 끄덕임
  - [ ] 1-2초: idle 복귀
  - [ ] 모든 캐릭터

**Phase 2: 학습 퀴즈 (4개 × 4캐릭터 = 16개)**
- [ ] **quiz_idle** (약 3초, loop)
  - [ ] 조용한 숨쉬기 + 집중 표정
  - [ ] 모든 캐릭터
- [ ] **quiz_correct_flow** (약 4-6초, one-shot → auto to quiz_idle) ⭐ 통합 애니메이션
  - [ ] 0-1초: thinking (고민 표정)
  - [ ] 1-3초: happy (정답! 기쁨)
  - [ ] 3-4초: idle 복귀
  - [ ] 모든 캐릭터
- [ ] **quiz_wrong_flow** (약 4-6초, one-shot → auto to quiz_idle) ⭐ 통합 애니메이션
  - [ ] 0-1초: thinking (고민 표정)
  - [ ] 1-3초: confused (오답.. 당황)
  - [ ] 3-4초: idle 복귀
  - [ ] 모든 캐릭터
- [ ] **result_celebration** (약 3초, one-shot)
  - [ ] 0-2초: happy 유지
  - [ ] 2-3초: idle 전환
  - [ ] 모든 캐릭터

**Phase 3: 홈 화면 (5개 × 4캐릭터 = 20개)**
- [ ] **home_idle** (약 5초, loop)
  - [ ] 숨쉬기 + 윙크 + 캐릭터 성향 제스처
  - [ ] 모든 캐릭터
- [ ] **home_studying** (약 3초, loop)
  - [ ] 책 읽기 + 페이지 넘김
  - [ ] 모든 캐릭터
- [ ] **home_excited** (약 2초, loop)
  - [ ] 통통 튀기 + 신나는 표정
  - [ ] 모든 캐릭터
- [ ] **home_sleepy** (약 3초, loop)
  - [ ] 하품 + 눈 비비기
  - [ ] 모든 캐릭터
- [ ] **home_celebration** (약 2초, one-shot → auto to home_idle)
  - [ ] 점프 + 컨페티 + 승리 포즈
  - [ ] 모든 캐릭터

---

### 추가 작업 (2025-12-26): 홈 화면 랜덤 애니메이션 로직 ✅ 완료

**완료된 작업:**
- [x] **홈 화면 진입 시 5개 home state 중 랜덤 선택** ✅
  - [x] `_selectRandomHomeState()` 메서드 구현
  - [x] 5개 상태 중 랜덤 선택: `homeIdle`, `homeStudying`, `homeExcited`, `homeSleepy`, `homeCelebration`
  - [x] 매번 홈 화면 진입 시 다른 캐릭터 모습 표시
  - [x] 파일: `lib/screens/home/home_screen.dart`
  - [x] Commit: 068f974
- [x] **Icon 위젯 → AnimatedCharacter 위젯으로 교체** ✅
  - [x] 기존: `Icon(Icons.pets)` placeholder
  - [x] 변경: `AnimatedCharacter(state: _currentHomeState)`
  - [x] 프레임 애니메이션 준비 완료
- [x] **추후 유저 상태 기반 로직 확장 구조 설계** ✅
  - [x] 주석으로 확장 방향 명시 (학습 완료, 연속일, 시간대 등)
  - [x] 현재: 랜덤 선택
  - [x] 추후: 유저 상태에 따라 적절한 애니메이션 선택

**확인 사항:**
- [x] 성향 진단 퀴즈 화면: `AnimatedCharacter` 정상 사용 중 (`personalityIdle`)
- [x] 성향 진단 완료 화면: `AnimatedCharacter` 정상 사용 중 (`resultCelebration`)
- ⚠️ 두 화면 모두 프레임 파일 없어서 placeholder 표시 (코드는 정상)

**다음 단계:**
- [ ] 디자인팀에서 52개 애니메이션 프레임 제작 시 즉시 적용
- [ ] v1.1+: 유저 상태 기반 애니메이션 선택 로직 추가

---

**제작 워크플로우:**
1. Midjourney/Runway로 영상 제작 (목표 시간대로, 정확한 프레임 수는 무시)
2. ffmpeg로 PNG 추출: `ffmpeg -i input.mp4 -vf "fps=24,scale=600:600:flags=lanczos" frame_%02d.png`
3. rembg로 배경 제거 (투명 배경)
4. cwebp로 WebP 변환: `cwebp -q 85 input.png -o output.webp`
5. 실제 프레임 수 카운트 후 JSON에 기록
6. 폴더명 확인: snake_case (예: `character_greeting_loop/`, `quiz_correct_flow/`)

**총 제작 물량: 52개 애니메이션 (4캐릭터 × 13상태)**
- Phase 1: 16개 (온보딩 테스트 가능)
- Phase 2: 16개 (메인 기능 테스트 가능)
- Phase 3: 20개 (완성)

**파일 배치 예시 (2025-12-24 재설계 - 13-state):**
```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json           (13개 상태 설정)
│   ├── character_greeting_loop/        (약 5초, ~120 frames)
│   │   ├── frame_01.webp
│   │   ├── frame_02.webp
│   │   └── ... (실제 프레임 수는 제작 후 확정)
│   ├── character_selected/             (약 1-2초, ~24-48 frames)
│   ├── personality_idle/               (약 3초, ~72 frames)
│   ├── personality_selected/           (약 2초, ~48 frames)
│   ├── quiz_idle/                      (약 3초, ~72 frames)
│   ├── quiz_correct_flow/              (약 4-6초, ~96-144 frames) ⭐ 통합
│   ├── quiz_wrong_flow/                (약 4-6초, ~96-144 frames) ⭐ 통합
│   ├── result_celebration/             (약 3초, ~72 frames)
│   ├── home_idle/                      (약 5초, ~120 frames)
│   ├── home_studying/                  (약 3초, ~72 frames)
│   ├── home_excited/                   (약 2초, ~48 frames)
│   ├── home_sleepy/                    (약 3초, ~72 frames)
│   └── home_celebration/               (약 2초, ~48 frames)
├── money_bear/                         (동일한 13개 폴더)
├── save_sheep/                         (동일한 13개 폴더)
└── chaser_fox/                         (동일한 13개 폴더)
```

**파일명 규칙:**
- 폴더명: snake_case (예: `character_greeting_loop/`, `quiz_correct_flow/`)
- 파일명: `frame_01.webp`, `frame_02.webp`, ... (01부터 시작, 2자리 패딩)
- 포맷: WebP 권장 (PNG도 지원)

**테스트 방법:**
1. 프레임 파일 배치
2. `flutter pub get` 실행
3. 앱 실행 → 해당 캐릭터/상태 확인
4. 프레임 없으면 자동으로 Placeholder 표시

**참고:**
- 파일만 배치하면 자동 인식 (추가 코드 불필요)
- `CharacterFrameAnimation.forState()`에 프리셋 설정 완료

---

### 3. SharedPreferences 영구 저장
**상태:** 🟡 부분 구현 (TODO 주석만)
**우선순위:** P1
**담당:** TBD
**예상 소요:** 0.5일

**현재 문제:**
- 사용자 데이터가 메모리에만 저장
- 앱 재시작 시 온보딩부터 다시 시작
- `UserProvider._saveToStorage()` 미구현

**구현 내용:**
- [ ] `shared_preferences` 패키지 추가
- [ ] `UserProvider.loadUser()`에서 로컬 데이터 로드
- [ ] `UserProvider._saveToStorage()` 구현
- [ ] JSON 직렬화/역직렬화
- [ ] 로그인 전: SharedPreferences 사용
- [ ] 로그인 후: Firestore 동기화

**관련 파일:**
- `lib/providers/user_provider.dart:32-46` (loadUser)
- `lib/providers/user_provider.dart:132-140` (_saveToStorage)

---

## ✅ 이미 완료된 핵심 기능 (개발팀)

> **개발팀 작업 완료**: 모든 핵심 화면 구조 완성. 외부 콘텐츠/애니메이션 대기 중.

### ~~홈 화면~~ (완료)
**상태:** ✅ 기본 구조 완료 (개발팀)
- 캐릭터 표시 (Placeholder - Rive 파일 대기)
- 오늘의 학습 카드
- 스트릭 카운터
- 통계 영역 (학습일수, 포인트, 연속)
- SNS 공유 버튼

### ~~학습 화면~~ (완료)
**상태:** ✅ 기본 구조 + 디자인 완료 (개발팀)
- 콘텐츠 카드 스와이프 (PageView)
- 페이지 인디케이터
- 다음/이전 버튼
- 학습 완료 플로우
- ✅ **디자인 개선 완료** (2025-12-02)
  - 1차: 성향별 컬러 시스템, 캐릭터 상호작용, 타이포그래피, 애니메이션
  - 2차: 통일된 다크 퍼플 테마, 헤더 압축 (AppBar 제거), 공간 최적화
  - 배경: 진한 다크 퍼플 (Color(0xFF1A1625))
  - 액센트: 파스텔 보라 (Color(0xFFB794F6))
  - 헤더 압축: 208px → 124px (84px 절약)
- **Firestore 연동 필요** (현재 더미 데이터)

### ~~퀴즈 화면~~ (완료)
**상태:** ✅ 기본 구조 + 디자인 완료 (개발팀)
- 5문항 객관식 퀴즈
- 정답/오답 즉시 피드백
- 진행 바
- 점수 계산 및 보상
- ✅ **디자인 개선 완료** (2025-12-02)
  - 1차: 학습 화면과 동일한 3단계 개선, 정답/오답 캐릭터 반응
  - 2차: 통일된 다크 테마, 헤더 압축, **피드백 영역 완전 제거**
  - 피드백은 캐릭터 말풍선에서만 표시
  - 해설 카드만 깔끔하게 표시
  - 한 화면에 모든 내용 표시 가능
- **Firestore 연동 필요** (현재 더미 데이터)

### ~~학습 탭 (진도 관리)~~ (완료)
**상태:** ✅ 기본 구조 완료 (개발팀)
- 진행 상황 카드
- Day 목록
- Month별 분류

### ~~설정 화면~~ (완료)
**상태:** ✅ 기본 구조 완료 (개발팀)
- 프로필 카드
- 설정 옵션들

---

## 🟠 중요 (Medium Priority)

### 4. 실제 학습 콘텐츠 작성
**상태:** 🔴 TODO (외부 전문가 작업)
**우선순위:** P2
**담당:** 콘텐츠 작성 전문가
**예상 소요:** 2-4주
**개발팀 작업:** 없음 (콘텐츠만 전달받음)

**목표:**
- Day 1-10: 각 성향별 콘텐츠 (총 40개)
- 퀴즈 문항: 5문항 × 10일 × 4성향 = 200개

**성향별 커리큘럼:**
- **안전형**: 예적금, 복리, 채권
- **밸런스형**: 예적금 + 펀드 기초
- **공격형**: 주식 기초, ETF
- **도전형**: 가상화폐, 선물옵션 입문

**작성 형식:**
- JSON 템플릿 준비 완료 (assets/data/)
- 백오피스 웹에서 직접 입력 예정
- **중요**: Firestore에 저장, 앱에서 실시간으로 불러옴

---

### 5. Firebase Firestore 콘텐츠 시스템 구현
**상태:** 🔴 TODO
**우선순위:** P0 (필수) ⚠️
**담당:** 개발팀
**예상 소요:** 2-3일

**중요**: 학습 콘텐츠는 **반드시 Firestore에 저장**하고 앱에서 실시간으로 불러와야 함. 앱 재배포 없이 콘텐츠 업데이트가 가능해야 함.

**구현 내용:**
- [ ] Firebase 프로젝트 설정 (이미 완료)
- [ ] Firestore Collections 설계:
  - `learning_contents/{contentId}` - 학습 콘텐츠
  - `quiz_contents/{quizId}` - 퀴즈 콘텐츠
  - `users/{userId}/profile` - 사용자 프로필
  - `users/{userId}/learning_progress/{dayId}` - 학습 진행 상황
- [ ] `lib/services/content_service.dart` 구현
  - Firestore에서 콘텐츠 불러오기
  - 캐싱 전략 (오프라인 대응)
  - 실시간 업데이트 감지
- [ ] Security Rules 설정
  - 콘텐츠: 모두 읽기, 관리자만 쓰기
  - 사용자 데이터: 본인만 읽기/쓰기
- [ ] LearningProvider/QuizProvider와 통합

**관련 문서:**
- `docs/BACKOFFICE_DESIGN.md` - Firestore 구조 상세 설계

---

### 6. 홈 화면 구현
**상태:** 🟡 스켈레톤만 존재
**우선순위:** P2
**담당:** TBD
**예상 소요:** 1일

**구현 화면:**
```
┌─────────────────────┐
│ 🐻 [캐릭터 애니메이션] │
│                     │
│ Day 7 학습하기 📚   │
│ 오늘의 주제: 복리의 힘│
│                     │
│ 🔥 7일 연속 학습 중  │
│ ⭐ 350P             │
│                     │
│ [학습 시작하기]      │
└─────────────────────┘
```

**관련 파일:**
- `lib/screens/home/home_screen.dart` (생성 필요)

---

### 7. 학습 화면 구현
**상태:** 🔴 TODO
**우선순위:** P2
**담당:** TBD
**예상 소요:** 2일

**기능:**
- 콘텐츠 카드 스와이프 (PageView)
- 페이지 인디케이터 (●●○○○)
- 다음/이전 버튼
- 학습 완료 시 퀴즈로 이동

---

### 8. 퀴즈 화면 구현
**상태:** 🔴 TODO
**우선순위:** P2
**담당:** TBD
**예상 소요:** 1-2일

**기능:**
- 5문항 객관식
- 정답/오답 즉시 피드백
- 해설 표시
- 점수 계산
- 완료 시 보상 화면

---

## 🟢 보통 (Low Priority)

### 9. 학습 탭 (진도 관리)
**상태:** 🔴 TODO
**우선순위:** P3
**예상 소요:** 1일

**기능:**
- 월별 진도 카드
- 전체 진도 (Day X/365)
- Day 목록
- 필터 (전체/완료/진행중/잠김)

---

### 10. 설정 화면 개선
**상태:** 🟡 기본 구조만 존재
**우선순위:** P3
**예상 소요:** 0.5일

**추가 기능:**
- 알림 설정
- 앱 버전 표시
- 로그아웃
- 데이터 초기화 (개발용)

---

### 11. SNS 공유 기능
**상태:** 🔴 TODO
**우선순위:** P3 (MVP 필수이지만 우선순위 낮음)
**예상 소요:** 1일

**기능:**
- 학습 완료 시 이미지 생성
- 카카오톡, 인스타그램, 페이스북 공유
- 이미지 저장

---

### 12. Day 30 완료 화면
**상태:** 🔴 TODO
**우선순위:** P3
**예상 소요:** 0.5일

**화면:**
```
🎉 Month 1 완료!

[다른 성향 체험하기]
[학습 복습하기]
```

---

## 🔵 백로그 (Future)

### v1.1 이후
- [ ] 캐릭터 진화 시스템
- [ ] 꾸미기 아이템
- [ ] 실천 인증
- [ ] 소셜 기능 (친구 초대)
- [ ] 커뮤니티
- [ ] 다크 모드
- [ ] 오프라인 모드

### 백오피스
- [ ] 관리자 인증
- [ ] 사용자 관리 페이지
- [ ] 콘텐츠 관리 페이지 (WYSIWYG)
- [ ] 퀴즈 관리 페이지
- [ ] 통계 대시보드

---

## 📊 진행 상황

### MVP v1.0 완료율 (현실적 평가)
```
온보딩:          ████████░░ 80% (기본 완료, UX 개선 필요)
핵심 화면:       ██████░░░░ 60% (구조 완료, 완성도↓ 테스트↓)
게이미피케이션:  ██████░░░░ 60% (로직 완료, UI/테스트 개선 필요)
콘텐츠:          ░░░░░░░░░░  0% (더미 데이터만, 템플릿은 준비됨)
애니메이션:      ██░░░░░░░░ 20% (Placeholder만, Rive 제작 대기)
Firebase:        ██████░░░░ 60% (Auth 완료, Firestore 영속화 대기)
예외처리/완성도: ███░░░░░░░ 30% (일부 구현, 통합 테스트 필요)
──────────────────────────────────────────
전체:            ████░░░░░░ 44% (구조는 완성, 완성도/테스트 필요)
```

**⚠️ 현실 체크**:
- ✅ 모든 핵심 화면 **구조** 완성
- 🔴 프로덕션 수준 **완성도** 미달
- 🔴 실제 콘텐츠, 예외 처리, 통합 테스트 필요

### 완료된 작업 ✅
- [x] Flutter 프로젝트 초기 설정
- [x] 기본 UI 컴포넌트 구축
- [x] 테마 시스템 구현
- [x] 스플래시 화면
- [x] 앱 소개 화면 (3 슬라이드)
- [x] 캐릭터 선택 화면
- [x] 성향 퀴즈 화면
- [x] 성향 결과 화면
- [x] 이름 설정 화면
- [x] 목표 설정 화면
- [x] CharacterProvider 구현
- [x] AnimatedCharacter 위젯 (Placeholder)
- [x] SpeechBubble 위젯
- [x] 캐릭터 우선 플로우 리팩토링
- [x] 스크롤 바운스 효과 제거
- [x] 구어체 톤앤매너 적용
- [x] 문서화 (DEVELOPMENT_LOG.md, BACKOFFICE_DESIGN.md, TODO.md)
- [x] **로그인/회원가입 화면 UI** (2025-01-15)
  - [x] 토글 방식 (로그인 ↔ 회원가입)
  - [x] 이메일/비밀번호 검증
  - [x] Google 로그인 버튼 (Firebase 대기)
  - [x] 목표 설정 → 로그인 화면 네비게이션
- [x] **Firebase 기본 설정** (2025-11-26)
  - [x] firebase_options.dart 생성
  - [x] Android/iOS 네이티브 설정
  - [x] Firebase 초기화 (main.dart)
- [x] **Firebase Authentication 구현** (2025-11-27)
  - [x] AuthService 생성 (Google + 이메일/비밀번호)
  - [x] login_screen.dart 통합
  - [x] 한국어 에러 메시지
  - [x] Android Google Sign-In 테스트 완료
- [x] **핵심 화면 구현** (기존에 구현되어 있음)
  - [x] MainScreen (하단 탭 네비게이션)
  - [x] HomeScreen (캐릭터, 학습 카드, 통계)
  - [x] LearningTabScreen (진도 관리)
  - [x] LearningScreen (카드 스와이프)
  - [x] QuizScreen (5문항 객관식)
  - [x] SettingsScreen (프로필, 설정)
- [x] **PersonalityType 런타임 에러 수정** (2025-11-29)
  - [x] Extension → Enhanced Enum 변환
  - [x] compile-time 필드로 변경 (color, lightColor, displayName 등)
  - [x] 프로덕션 안정성 확보
- [x] **홈화면 UI 개선** (2025-11-29)
  - [x] 성향별 캐릭터 이름 표시 제거 (Rive 애니메이션 준비)
- [x] **학습/퀴즈 화면 디자인 대폭 개선** (2025-12-02)
  - [x] 1차: 3단계 컬러 시스템, 캐릭터 상호작용, 타이포그래피, 애니메이션
  - [x] 2차: 통일된 다크 퍼플 테마 + 헤더 압축 최적화
    - [x] 캐릭터 네이밍 최신화 (세이브쉽, 헌터캣, 체이서폭스)
    - [x] 진한 다크 퍼플 배경 (Color(0xFF1A1625)) + 파스텔 보라 액센트
    - [x] 헤더 압축 (AppBar → 미니멀 헤더, 84px 절약)
    - [x] 퀴즈 피드백 영역 완전 제거 (캐릭터 말풍선만 사용)
    - [x] 한 화면에 모든 내용 표시 가능하도록 최적화

---

## 🐛 알려진 이슈

### Critical
- ✅ **해결됨 (2025-11-29)**: PersonalityType.color 런타임 에러
  - **문제**: Extension 기반으로 구현된 PersonalityType 속성이 특정 Flutter 환경에서 런타임에 인식되지 않음
  - **증상**: "Class 'PersonalityType' has no instance getter 'color'" 에러, 빨간 화면
  - **해결**: Extension → Enhanced Enum으로 변환하여 compile-time 필드로 보장

### Minor
- 없음

---

## 📌 특이사항 & 메모

### 설계 결정 사항

#### 1. 캐릭터 우선 온보딩 (2025-01-15)
**이유:** 게이미피케이션 특색, 캐릭터 유대감 형성
**영향:**
- CharacterProvider에 `selectedCharacter` vs `finalPersonality` 분리
- 성향 결과 화면에서 캐릭터 이름 제거 (성향 중심)
- 이름 설정 시 선택한 캐릭터 기본 이름 사용

#### 2. 성향 변경 정책
- 성향 변경 시 Day 1부터 재시작
- 기존 학습 기록은 `personality.history`에 보관
- 변경 시 확인 팝업 필수

#### 3. 포인트 시스템
- MVP: 획득만 (사용처 없음)
- v1.1: 꾸미기 아이템 상점
- v1.2: 캐릭터 진화 시스템

#### 4. 퀴즈 재개 없음
- 5문항으로 짧아서 처음부터 다시 풀기
- 개발 복잡도 감소

### 기술 결정 사항

#### 1. Provider vs Riverpod
- **선택:** Provider
- **이유:** 간단한 상태 관리, 충분한 기능, 낮은 러닝 커브

#### 2. Rive vs Lottie
- **선택:** Rive
- **이유:** 인터랙티브 애니메이션 지원, 상태 전환 용이

#### 3. SharedPreferences vs Hive
- **선택:** SharedPreferences (로그인 전) + Firestore (로그인 후)
- **이유:** 간단한 데이터 구조, Firebase 우선

#### 4. 스크롤 물리 효과
- **ClampingScrollPhysics** 전역 적용
- iOS 바운스 효과 제거 (디자인 일관성)

### 개발 중 주의사항

1. **구어체 톤앤매너**
   - 안내/설명: "~해요" 어미 사용
   - 예: "같이 시작해요!", "우리 딱 맞는 것 같아요!"

2. **캐릭터 대사**
   - 각 캐릭터마다 고유한 말투
   - `CharacterAnimationConfig`에 정의

3. **애니메이션 성능**
   - `RepaintBoundary` 사용
   - 60 FPS 유지

4. **Firebase Security Rules**
   - `/users/{userId}`: 본인만 읽기/쓰기
   - 콘텐츠: 모두 읽기, 관리자만 쓰기

---

## 🔗 관련 문서

- [README.md](../README.md) - 프로젝트 전체 개요
- [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - 상세 개발 로그
- [BACKOFFICE_DESIGN.md](./BACKOFFICE_DESIGN.md) - 백오피스 설계
- [docs/strategy.md](./strategy.md) - 전략 기획서
- [docs/app_spec.md](./app_spec.md) - 앱 상세 기획서

---

**작성일:** 2025-01-15
**마지막 업데이트:** 2025-01-15
**다음 업데이트:** Google 로그인 구현 완료 시
