# 머니펫 (MoneyPet) 📱

> 귀여운 친구와 함께, 매일 5분으로 금융 문맹 탈출

다마고치 스타일의 캐릭터와 함께 투자를 배우는 게이미피케이션 금융 교육 앱

![Version](https://img.shields.io/badge/version-1.0.0--MVP-purple)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)

---

## 📌 프로젝트 개요

### 한 줄 설명
다마고치 스타일의 캐릭터와 함께 투자를 배우는 모바일 앱

### 핵심 가치
- **접근성**: 10세~60세 누구나, 매일 5분
- **실용성**: 추상적 개념이 아닌 구체적 숫자와 실행 가이드
- **지속성**: 게임처럼 재미있게, 캐릭터와의 유대감
- **개인화**: 4가지 투자 성향별 맞춤 커리큘럼 (안전/밸런스/공격/도전)

### 주요 기능
- 🎯 캐릭터 선택 → 성향 진단 (5문항) → 캐릭터와 함께 학습
- 📚 1일 1학습 시스템 (Day 1-365)
  - 하루에 하나의 Day만 학습 가능
  - 학습 완료 후 내일까지 대기
  - 완료한 Day는 언제든 복습 가능 (포인트 미지급)
- 🎮 게이미피케이션 (포인트, 스트릭, 캐릭터 육성)
- 🎯 매일 5분 학습 (콘텐츠 3분 + 퀴즈 2분)
- 📱 SNS 공유 기능

---

## 🎯 최종 개발 방향성 (MVP v1.0)

### ✅ 확정 사항

#### 1. 온보딩 & 퀴즈
- ✅ **성향 진단**: 선택 즉시 자동 전환 (사용자가 선택 수정 불가)
- ✅ **퀴즈 재개 없음**: 중단 시 처음부터 다시 풀기 (5문항이라 짧음)
- ✅ **다크 모드 미지원**: MVP는 라이트 모드만, v1.1 이후 고려

#### 2. 진도 표시
**기본 화면** (학습 탭):
```
┌─────────────────────┐
│ 📊 학습 진도   [>]  │  ← 탭 가능
│                     │
│ Month 1             │
│ 7/30 (23%)          │  ← 월별 진도만 표시
│ ▰▰▰▰▰▱▱▱▱▱         │
│                     │
│ 다음 목표: 30일 완료🎯│
└─────────────────────┘
```

**상세 화면** (카드 탭 시):
- Month 진도 (상세)
- 전체 진도 (7/365일)
- 학습 통계 (평균 점수, 총 포인트, 최고 연속)

#### 3. 성향 변경 정책
**옵션 A 적용**:
- 성향 변경 → Day 1부터 새로운 커리큘럼 시작
- 기존 학습 기록은 보관 (이력 관리)
- 변경 시 확인 팝업 필수:
  ```
  ⚠️ 다른 성향으로 변경하면
  Day 1부터 새로운 커리큘럼으로 시작해요
  기존 학습 기록은 보관됩니다

  [취소] [변경하기]
  ```

#### 4. 포인트 시스템
**MVP**:
- ✅ 포인트 획득만 (학습 50P + 퀴즈 100P)
- ✅ 사용처 없음 (쌓이기만)
- ✅ 복습 시 포인트 미지급

**추후 구현 고려 (v1.1+)**:
1. **꾸미기 아이템**: 의상, 악세서리, 배경
2. **캐릭터 진화 시스템** ⭐:
   - 조건: 캐릭터 + 성향 + 포인트
   - 예: 헌터캣 + 안전형 + 1000P → "안전 헌터캣" 디자인
   - 총 16가지 바리에이션 (4 캐릭터 × 4 성향)

#### 5. Day 30 완료 화면
```
┌─────────────────────┐
│ 🎉 Month 1 완료!    │
│                     │
│ 안전형 커리큘럼의    │
│ 모든 학습을 완료!    │
│                     │
│ [다른 성향 체험하기] │  ← 성향 변경
│ [학습 복습하기]      │  ← Day 목록
└─────────────────────┘
```
- MVP는 Day 30까지만 제공
- 완료 후 다른 성향 체험 유도
- 콘텐츠는 주기적으로 Day 365까지 확장 예정

#### 6. SNS 공유 기능 (MVP 필수)
학습 완료 시 공유 이미지 생성:
```
┌──────────────────┐
│ [캐릭터 이미지]   │
│                  │
│ Day 7 완료! 🎉  │
│ 연속 7일 🔥     │
│                  │
│ 머니펫과 함께    │
│ 투자 공부 중     │
│                  │
│ #머니펫 #투자공부│
│                  │
│ [앱 다운로드 QR] │
└──────────────────┘
```
- 이미지 크기: 1080×1920 (인스타 스토리 최적)
- 공유처: 카카오톡, 인스타그램, 페이스북, 이미지 저장

#### 7. 학습 완료 후 플로우 ✅ 구현 완료
**오늘 학습 완료 시** (hasLearnedToday = true):
```
┌──────────────────────────────┐
│ 🎉 오늘의 학습 완료!         │
│                              │
│ Day 1을 완료했어요!          │
│                              │
│ 내일은 Day 2로 함께해요 🌟  │
│                              │
│ [Day 1 복습하기] 📚         │  ← 복습 모드 (포인트 없음)
│ [이전 학습 보기]            │  ← 학습 탭으로 이동
└──────────────────────────────┘
```

**복습 모드 (Review Mode)**:
- 이미 완료한 Day를 다시 학습 가능
- 학습 화면 헤더에 "복습" 배지 표시
- 캐릭터 메시지 변경 ("다시 복습해봐요! 📖")
- 퀴즈 결과: "Day X 복습 완료", "포인트 없음" 표시
- **포인트/스트릭 증가 없음** (1일 1학습 원칙 유지)
- 학습 기록은 별도 저장 (reviewCount, lastReviewedAt)

**설계 원칙**:
- 1일 1학습 원칙 유지 (하루에 하나의 Day만 정식 학습)
- 복습은 학습 강화 목적 (보상 없음)
- 완료한 Day는 언제든 복습 가능

#### 8. 제외 기능 (v1.1 이후)
- ❌ 꾸미기 (캐릭터 커스터마이징)
- ❌ 실천 인증
- ❌ 소셜 공유 (친구 초대, 진도 비교)
- ❌ 커뮤니티
- ❌ 다크 모드
- ❌ 오프라인 모드

---

## 🏗️ 기술 스택

### 선택된 스택
```
프론트엔드:
- Flutter 3.x (Dart)
- 상태관리: Provider / Riverpod
- 애니메이션: 프레임 기반 (PNG/WebP 시퀀스)
- 로컬 저장소: Hive / SharedPreferences

백엔드:
- Firebase
  - Firestore (데이터베이스)
  - Authentication (인증)
  - Storage (이미지 저장)
  - Analytics (분석)

주요 패키지:
- go_router (네비게이션)
- provider (상태 관리)
- firebase_core, cloud_firestore, firebase_auth
- share_plus (SNS 공유)
- image (이미지 생성)
- fl_chart (차트 - 진도 표시)

배포:
- iOS: TestFlight → App Store
- Android: Google Play 내부 테스트 → Play Store

CI/CD:
- GitHub Actions
- Codemagic (Flutter 전용) or Fastlane
```

### Flutter 선택 이유
✅ **애니메이션 강점**: 머니펫의 핵심인 캐릭터 애니메이션에 최적
✅ **60 FPS 보장**: 부드러운 UI/UX
✅ **Hot Reload**: 빠른 개발 속도
✅ **단일 코드베이스**: iOS/Android 동시 개발
✅ **프레임 애니메이션 지원**: PNG/WebP 시퀀스 재생 최적화

---

## 📋 MVP 기능 체크리스트

### 🔴 필수 기능 (출시 전)

#### 온보딩
- [x] Splash ✅
- [x] Welcome (3 슬라이드, 건너뛰기 가능) ✅
- [x] **캐릭터 선택** (성향보다 먼저) ⭐ ✅
- [x] 성향 진단 (5문항, 캐릭터와 함께) ✅
- [x] 진단 결과 (캐릭터 반응 포함) ✅
- [x] 캐릭터 이름 설정 ✅
- [x] 목표 설정 ✅
- [x] **로그인/회원가입 UI** ✅ (토글 방식, Firebase 연동)
- [x] **Firebase Auth 연동** ✅ (Google + 이메일 인증, Android 테스트 완료)
- [x] 첫 학습 안내 ✅

> **온보딩 상태**: 기본 플로우 완성. UX 개선 및 전체 테스트 필요

#### 메인 기능
- [x] 홈 화면 ✅ **학습 완료 UI 구현 완료** (2024-12-08)
  - [x] 캐릭터 표시 (Placeholder 아이콘, 프레임 애니메이션 대기)
  - [x] 오늘의 학습 카드 (일반/완료 상태 분기)
  - [x] 학습 완료 UI (완료 축하, 내일 예고, 복습/이전 학습 보기 버튼)
  - [x] 스트릭 카운터 (🔥7)
  - [x] 통계 영역 (학습일수, 포인트, 연속)
  - [x] SNS 공유 버튼 (기본 구조)
- [x] 학습 화면 ✅ **복습 모드 구현 완료** (2024-12-08)
  - [x] 콘텐츠 카드 (스와이프) - PageView
  - [x] 페이지 인디케이터 (●●○○○)
  - [x] 다음/이전 버튼
  - [x] 복습 모드 (isReview 플래그, 헤더 배지, 캐릭터 메시지 변경)
  - [x] 복습 시 포인트/스트릭 업데이트 스킵
- [x] 퀴즈 화면 ✅ **복습 모드 구현 완료** (2024-12-08)
  - [x] 5문항 객관식
  - [x] 정답/오답 피드백
  - [x] 해설 표시
  - [x] 재개 기능 없음 (처음부터만)
  - [x] 결과 화면 (점수, 포인트)
  - [x] 복습 모드 (포인트 없음 표시)
- [x] 학습 탭 🟡 **기본 구현 완료, 실제 콘텐츠/테스트 필요**
  - [x] 진도 카드 (Month 진도만)
  - [x] 진도 상세 (탭 시 전체 진도 표시)
  - [x] Day 목록
  - [x] 필터 (전체/완료/진행중/잠김)
- [x] 설정 화면 🟡 **기본 구현 완료, 세부 기능 개선 필요**
  - [x] 프로필 카드
  - [ ] 이름 변경 (UI만, 로직 미완)
  - [ ] 성향 변경 (UI만, Day 1 재시작 확인 팝업 미완)
  - [ ] 알림 설정 (미완)

> **메인 기능 상태**: 모든 화면 기본 구조 완성. 더미 데이터로 동작. 실제 콘텐츠, 예외 처리, 디자인 완성도, 전체 통합 테스트 필요

#### 신규 필수 기능
- [ ] **Day 30 완료 화면** (다른 성향 체험 유도) 🔴 미완
- [x] **SNS 공유 기능** 🟡 (텍스트 공유만, 이미지 생성 미완)
- [ ] **성향 변경 확인 팝업** (Day 1 재시작 고지) 🔴 미완

#### 게이미피케이션
- [x] 포인트 시스템 (획득만, 사용처 없음) 🟡 **로직 완료, UI/테스트 개선 필요**
- [x] 스트릭 카운터 (연속 학습일) 🟡 **로직 완료, UI/테스트 개선 필요**
- [x] 학습 완료 보상 화면 🟡 **기본 구현 완료, 디자인 개선 필요**

#### 캐릭터 애니메이션 (13-state 시스템, 통합 애니메이션 방식)
- [x] **기술 스택 변경** ✅ Rive → PNG/WebP 프레임 시퀀스 (Midjourney/Runway)
- [x] **개발 완료** ✅ (2025-12-24)
  - [x] 애니메이션 시스템 구현 (프레임 기반)
  - [x] JSON 설정 시스템 (코드 수정 없이 프레임 수 조정)
  - [x] 상태 체계 재설계 (5개 → 10개 → 13개 상태)
  - [x] 통합 애니메이션 방식 적용 (프레임 불일치 문제 해결)
  - [x] 자동 전환 로직 구현 (autoTransitionTo)
  - [x] 폴더 구조 재편 (52개 폴더: 4캐릭터 × 13상태)
  - [x] PNG/WebP 지원 및 버그 수정
  - [x] 온보딩 화면 개선 (크기 증가, 오버플로우 수정)
  - [x] pubspec.yaml 업데이트 (52개 asset 경로)
- [ ] **디자인팀 작업 대기** 🔴 애니메이션 제작 필요 (52개)

**상태 체계 (2025-12-24 완료 - 통합 애니메이션 방식):**
- **카테고리 1: 캐릭터 선택 화면 (2개)**
  - `characterGreetingLoop`: 손 흔들며 인사 (약 5초) - 헌터캣 재활용 가능 ✅
  - `characterSelected`: 선택 반응 (약 1-2초) - 재제작 필요 ⚠️
- **카테고리 2-A: 성향 퀴즈 (2개)**
  - `personalityIdle`: 성향 문제 대기 (약 3초, loop) 🆕
  - `personalitySelected`: 선택 반응 → auto idle (약 2초) 🆕
- **카테고리 2-B: 학습 퀴즈 (3개)**
  - `quizIdle`: 학습 문제 대기 (약 3초, loop) 🆕
  - `quizCorrectFlow`: **통합** thinking→happy→idle (약 4-6초) ⭐
  - `quizWrongFlow`: **통합** thinking→confused→idle (약 4-6초) ⭐
- **카테고리 3: 결과 화면 (1개)**
  - `resultCelebration`: 성향 결과 축하 (약 3초) 🆕
- **카테고리 4: 홈 화면 (5개)**
  - `homeIdle`: 기본 대기 - 복합 애니메이션 (약 5초)
  - `homeStudying`: 책 읽기 (약 3초)
  - `homeExcited`: 활기찬 모습 (약 2초)
  - `homeSleepy`: 졸린 모습 (약 3초)
  - `homeCelebration`: 목표 달성 → auto idle (약 2초)

> **핵심 변경: 통합 애니메이션 방식**
> - 개별 상태 조합 시 프레임 불일치로 전환이 끊기는 문제 해결
> - `quiz_correct_flow` = thinking → happy → idle 복귀를 **하나의 애니메이션**으로 제작
> - 부드러운 전환을 위해 일부 용량 증가 감수 (40MB → 192MB PNG / 96MB WebP)
>
> **애니메이션 현황**:
> - ✅ 프레임 시스템 구축 완료 (2025-12-23)
> - ✅ 13-state 코드 재설계 완료 (2025-12-24)
> - ✅ Task #1-7 개발 완료 (enum, 폴더, JSON, 화면, pubspec)
> - 🔴 디자인팀: 52개 애니메이션 제작 대기 (13상태 × 4캐릭터, 헌터캣 greeting 1개 재활용 가능)
> - 📋 제작 가이드: `docs/FRAME_ANIMATION_GUIDE.md`
> - 📋 작업 상세: `docs/TODO.md` (2025-12-24 섹션)

#### 예외 처리
- [ ] 네트워크 에러 (전체 화면 + 토스트) 🔴 미완
- [ ] 학습 중단/재개 (콘텐츠만, 퀴즈 제외) 🔴 미완
- [ ] Empty State 🔴 미완
- [x] 로딩 상태 (풀스크린 + 인라인) 🟡 일부 구현, 통일성 개선 필요

#### 콘텐츠 (성향별 4세트)
- [ ] Day 1-30 콘텐츠 작성 (120개: 30일 × 4성향) 🔴 외부 전문가 작업
- [ ] 퀴즈 문항 작성 (600개: 5문항 × 30일 × 4성향) 🔴 외부 전문가 작업

> **콘텐츠 상태**:
> - JSON 템플릿 준비 완료 (assets/data/)
> - 실제 콘텐츠는 외부 전문가가 작성 예정
> - **중요**: 콘텐츠는 Firestore에 저장, 백오피스에서 관리
> - 앱 배포 없이 콘텐츠 업데이트 가능하도록 설계

---

## 📊 데이터베이스 구조

### UserProfile
```typescript
{
  userId: string
  createdAt: datetime

  // 성향 (이력 관리)
  personality: {
    currentType: 'safe' | 'balanced' | 'aggressive' | 'challenger'
    history: [
      {
        type: string
        startedAt: datetime
        completedDays: number
        totalPoints: number
        switchedAt: datetime | null
      }
    ]
  }

  // 캐릭터
  character: {
    type: 'moneyBear' | 'coinCat' | 'savingDuck' | 'balanceBunny'
    name: string
    evolution: string | null  // v1.1+
  }

  goal: string

  // 진도 (현재 성향 기준)
  currentDay: number
  totalDaysCompleted: number

  // 스트릭
  currentStreak: number
  longestStreak: number
  lastStudyDate: datetime

  // 포인트 (전체 누적)
  totalPoints: number
  pointsHistory: [...]
}
```

### LearningRecord
```typescript
{
  recordId: string
  userId: string
  day: number
  personality: string  // 어떤 성향으로 학습했는지

  // 학습
  lessonCompleted: boolean
  lessonStartedAt: datetime
  lessonCompletedAt: datetime
  lessonDuration: number

  // 퀴즈
  quizCompleted: boolean
  quizScore: number  // 0-5
  quizAnswers: [...]

  // 보상
  pointsEarned: number

  // 복습 (포인트 미지급)
  reviewCount: number
  lastReviewedAt: datetime
  reviewScores: [number]

  // 공유
  sharedToSNS: boolean
  sharedAt: datetime | null
}
```

### Content (확장 가능 구조)
```typescript
{
  contentId: string
  day: number  // 1-365+
  personality: 'safe' | 'balanced' | 'aggressive' | 'challenger'
  month: number  // Math.ceil(day / 30)

  title: string
  subtitle: string
  estimatedMinutes: number

  cards: [
    {
      type: 'intro' | 'lesson' | 'example' | 'comparison' | 'guide'
      content: string  // HTML or Markdown
      image?: string
    }
  ]

  quiz: [
    {
      question: string
      options: [string, string, string, string]
      correctIndex: number
      explanation: string
    }
  ]

  createdAt: datetime
  updatedAt: datetime
  version: number
}
```

---

## 🚀 개발 로드맵

### Phase 1: 핵심 기능 (Week 1-4)
- 온보딩 플로우 (7개 화면)
- 메인 화면 (홈 + 학습 탭)
- 학습 화면 (콘텐츠 카드 스와이프)
- 퀴즈 화면 (재개 없음)
- 캐릭터 애니메이션 (13-state 시스템)

### Phase 2: 신규 기능 (Week 5-6)
- 월별 진도 표시 (기본 + 상세)
- 성향 변경 플로우 (Day 1 재시작 확인)
- Day 30 완료 화면
- SNS 공유 기능 (이미지 생성 + 공유)

### Phase 3: 부가 기능 (Week 7-8)
- 설정 화면
- 예외 처리 (에러, Empty State)
- 성능 최적화

### Phase 4: 콘텐츠 & QA (Week 9-12)
- Day 1-30 콘텐츠 작성 (성향별 4세트)
- 퀴즈 문항 작성 (600개)
- QA 및 버그 수정
- 베타 테스트

---

## 🎨 디자인 시스템

### 컬러 팔레트
- **Primary**: `#9F7AEA` (메인 보라)
- **Secondary**: `#718096` (메인 회색)
- **Background**: `#FAFBFC` (오프화이트)
- **Success**: `#48BB78` (초록)
- **Error**: `#F56565` (빨강)

### 성향별 컬러
- **안전형 (머니베어)**: `#718096` (따뜻한 회색)
- **밸런스형 (세이브쉽)**: `#B794F6` (파스텔 보라)
- **공격형 (헌터캣)**: `#9F7AEA` (메인 보라)
- **도전형 (체이서폭스)**: `#4A5568` (차분한 회색)

### 타이포그래피
- **H1**: 32px, Bold
- **H2**: 24px, Bold
- **H3**: 20px, Bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular

---

## 📂 프로젝트 구조 (Flutter)

```
your_money_pet/
├── docs/                           # 문서
│   ├── strategy.md                 # 전략 기획서
│   ├── app_spec.md                 # 앱 상세 기획서
│   └── dev_guide.md                # 개발 가이드
├── lib/                            # Flutter 소스
│   ├── main.dart                   # 앱 진입점
│   ├── app.dart                    # App Widget
│   ├── screens/                    # 화면
│   │   ├── onboarding/             # 온보딩 관련
│   │   ├── home/                   # 홈 화면
│   │   ├── learning/               # 학습 화면
│   │   ├── quiz/                   # 퀴즈 화면
│   │   └── settings/               # 설정 화면
│   ├── widgets/                    # 재사용 컴포넌트
│   │   ├── character_widget.dart   # 캐릭터 표시
│   │   ├── progress_card.dart      # 진도 카드
│   │   └── learning_card.dart      # 학습 카드
│   ├── models/                     # 데이터 모델
│   │   ├── user_profile.dart
│   │   ├── learning_record.dart
│   │   └── content.dart
│   ├── providers/                  # 상태 관리 (Provider/Riverpod)
│   │   ├── user_provider.dart
│   │   ├── learning_provider.dart
│   │   └── quiz_provider.dart
│   ├── services/                   # 비즈니스 로직
│   │   ├── firebase_service.dart   # Firebase 연동
│   │   ├── storage_service.dart    # 로컬 저장소
│   │   └── share_service.dart      # SNS 공유
│   ├── utils/                      # 유틸리티
│   │   ├── constants.dart          # 상수 (색상, 텍스트)
│   │   ├── theme.dart              # 테마 정의
│   │   └── helpers.dart            # 헬퍼 함수
│   └── routes/                     # 라우팅
│       └── app_router.dart         # go_router 설정
├── assets/                         # 리소스
│   ├── images/                     # 이미지
│   ├── animations/                 # 프레임 애니메이션 파일 (PNG/WebP)
│   └── fonts/                      # 폰트
├── test/                           # 테스트
├── android/                        # Android 설정
├── ios/                            # iOS 설정
├── pubspec.yaml                    # 패키지 의존성
└── README.md
```

---

## 📱 v1.1 이후 계획

### v1.1 (출시 후 3개월)
- 꾸미기 아이템 (포인트 사용처)
- 실천 인증 기능
- 소셜 기능 (친구 초대, 진도 비교)
- Day 31-60 콘텐츠 추가

### v1.2 (출시 후 6개월)
- **캐릭터 진화 시스템** ⭐
- AI 챗봇 (투자 Q&A)
- 커뮤니티
- 다크 모드

### v2.0 (출시 후 1년)
- Day 365 완성
- 포트폴리오 연동 (증권사 API)
- 글로벌 진출 (일본어, 영어)

---

## 🧪 Flutter 테스트 & 배포 가이드

### 1️⃣ 개발 환경 세팅

#### 필수 도구 설치
```bash
# Flutter SDK 설치 (https://flutter.dev/docs/get-started/install)
flutter --version

# Flutter doctor로 환경 확인
flutter doctor

# 필요한 도구 설치 확인:
# ✓ Flutter SDK
# ✓ Android Studio (Android 개발)
# ✓ Xcode (iOS 개발, Mac 필수)
# ✓ VS Code or Android Studio (IDE)
```

#### VS Code 확장 설치 (추천)
- Flutter
- Dart
- Prettier - Code formatter

---

### 2️⃣ 로컬 테스트 환경

#### A. 실기기 테스트 (가장 빠름) ⭐

**iOS (Mac 필요)**:
```bash
# iPhone 연결 (USB)
# 개발자 모드 활성화

# 실행
flutter run
# 또는 특기기 지정
flutter devices
flutter run -d <device-id>

장점:
✅ 실제 기기 성능 확인
✅ Hot Reload (r 키) / Hot Restart (R 키)
✅ 터치, 제스처 정확한 테스트
```

**Android**:
```bash
# Android 폰 연결 (USB)
# 개발자 옵션 → USB 디버깅 활성화

# 실행
flutter run

장점:
✅ Windows/Mac/Linux 모두 가능
✅ 실제 기기 테스트
✅ Hot Reload 지원
```

#### B. iOS Simulator (Mac 필수)
```bash
# Simulator 실행
open -a Simulator

# Flutter 실행
flutter run

장점:
✅ 실기기 없이 테스트
✅ 다양한 기기 시뮬레이션 (iPhone SE ~ Pro Max)

단점:
⚠️ Mac 필수
⚠️ 성능이 실기기와 다름
```

#### C. Android Emulator
```bash
# Android Studio → AVD Manager → 에뮬레이터 생성
# (권장: Pixel 6, API 33+)

# 에뮬레이터 실행
flutter emulators --launch <emulator-id>

# Flutter 실행
flutter run

장점:
✅ 모든 OS에서 가능
✅ 다양한 기기 테스트

단점:
⚠️ 메모리 많이 사용 (8GB+ 권장)
⚠️ 애니메이션 성능 실기기보다 느림
```

---

### 3️⃣ 빌드 방법

#### 개발 빌드 (Debug)
```bash
# Android APK
flutter build apk --debug

# iOS (Mac 필수)
flutter build ios --debug
```

#### 릴리즈 빌드
```bash
# Android App Bundle (Play Store 업로드용)
flutter build appbundle --release

# Android APK (직접 배포용)
flutter build apk --release

# iOS (Mac 필수)
flutter build ipa --release
```

---

### 4️⃣ 내부 테스트 (팀원)

#### A. Android - APK 직접 배포
```bash
# 1. 릴리즈 APK 빌드
flutter build apk --release

# 2. APK 위치
build/app/outputs/flutter-apk/app-release.apk

# 3. 팀원에게 전달
- Google Drive / Dropbox 등에 업로드
- 다운로드 링크 공유
- 팀원: "알 수 없는 출처" 허용 후 설치

장점:
✅ 즉시 배포 가능
✅ 심사 없음
✅ 무료

단점:
⚠️ 보안 경고 (알 수 없는 출처)
⚠️ 자동 업데이트 불가
```

#### B. iOS - TestFlight (추천)
```bash
# 1. Apple Developer Program 가입 ($99/년)

# 2. Xcode에서 빌드
flutter build ipa

# 3. Xcode Organizer로 업로드
- Xcode 열기 → Window → Organizer
- Archives 탭 → Distribute App
- TestFlight → Upload

# 4. App Store Connect에서 테스터 초대
- 이메일 또는 링크로 초대 (최대 100명)

장점:
✅ 앱스토어와 동일한 환경
✅ 자동 업데이트
✅ 크래시 리포트 자동 수집

과정:
Week 1: Apple Developer 가입
Week 2: 첫 빌드 업로드
Week 3-4: 내부 테스터 피드백
```

---

### 5️⃣ 베타 테스트 (외부 사용자)

#### Android - Google Play 내부 테스트

**초기 설정** (1회만):
```
1. Google Play Console 계정 생성 ($25 평생)
   https://play.google.com/console

2. 앱 만들기
   - 앱 이름: 머니펫
   - 기본 언어: 한국어

3. 스토어 등록정보 작성
   - 간단한 설명
   - 스크린샷 (필수)
   - 앱 아이콘
```

**빌드 업로드**:
```bash
# 1. App Bundle 빌드
flutter build appbundle --release

# 2. Play Console → 프로덕션 → 트랙 만들기
# → 내부 테스트

# 3. AAB 업로드
build/app/outputs/bundle/release/app-release.aab

# 4. 테스터 목록 생성
- 이메일 주소로 초대 (최대 100명)

# 5. 검토 → 출시
- 즉시 배포 (심사 없음)
```

**테스터 초대**:
```
1. Play Console → 내부 테스트 → 테스터
2. 이메일 목록 추가
3. 공유 링크 복사
4. 테스터에게 링크 전달
5. 테스터: 링크 접속 → 플레이스토어에서 설치
```

#### iOS - TestFlight (위와 동일)

---

### 6️⃣ 정식 출시

#### Android - Google Play Store
```
1. Play Console → 프로덕션 → 새 버전 만들기

2. App Bundle 업로드 (동일)

3. 출시 노트 작성
   예: "첫 출시: 투자 학습 앱 머니펫"

4. 검토를 위해 제출
   - 심사 기간: 평균 1-3일

5. 승인 후 전 세계 배포
```

#### iOS - App Store
```
1. App Store Connect → 앱 → 새 버전

2. 빌드 선택 (TestFlight에서 업로드한 빌드)

3. 스토어 정보 작성
   - 스크린샷 (필수)
   - 설명
   - 키워드

4. 심사를 위해 제출
   - 심사 기간: 평균 1-7일

5. 승인 후 App Store 배포
```

---

### 7️⃣ CI/CD 자동화 (선택, 나중에)

#### GitHub Actions (무료)
```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.x'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Build APK
      run: flutter build apk --release

    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release
        path: build/app/outputs/flutter-apk/app-release.apk
```

#### Codemagic (Flutter 전용, 유료)
- 더 강력한 기능 (iOS 빌드 포함)
- GUI 설정
- 자동 TestFlight/Play Store 업로드
- 무료 플랜: 월 500분

---

### 8️⃣ 추천 테스트 전략

```
┌─────────────────────────────────────────┐
│ Phase 1-3 (개발 중)                     │
│ → 실기기 Hot Reload 테스트 (매일)        │
│ → iOS Simulator + Android Emulator     │
│ → flutter run으로 즉시 확인             │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Phase 4 (QA)                            │
│ → 릴리즈 빌드 생성                       │
│ → APK 직접 배포 (팀원 5-10명)           │
│ → 버그 수정                             │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 베타 출시 (출시 2주 전)                  │
│ → TestFlight (iOS) 50명                 │
│ → Google Play 내부 테스트 (Android) 50명│
│ → 피드백 수집 → 수정                    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 정식 출시                                │
│ → App Store (심사 1-7일)                │
│ → Google Play Store (심사 1-3일)        │
└─────────────────────────────────────────┘
```

---

### 9️⃣ 테스트 기기 추천

#### 최소 구성
```
✅ iPhone 1대 (iOS 14+)
✅ Android 폰 1대 (API 23+)
or
✅ Mac + Simulator + Android 에뮬레이터
```

#### 이상적 구성
```
✅ iPhone 14/15 (최신)
✅ iPhone SE (구형, 작은 화면)
✅ Galaxy S23 (최신 Android)
✅ 중저가 Android (성능 테스트)
```

---

### 🔟 비용 정리

| 항목 | 비용 | 필수 여부 |
|------|------|-----------|
| Flutter SDK | **무료** | ✅ 필수 |
| Apple Developer | $99/년 | ✅ iOS 배포 필수 |
| Google Play | $25 (평생) | ✅ Android 배포 필수 |
| Firebase (Spark) | **무료** | ✅ 충분 |
| Codemagic | 무료 (월 500분) | ⚠️ 선택사항 |
| Mac | - | ⚠️ iOS 개발 권장* |

*Mac 없이도 Android만 개발 가능하지만, iOS는 Mac 필수

**MVP 총 비용: $124 (1년)**

---

### 1️⃣1️⃣ 실전 세팅 가이드 (10분)

```bash
# 1. Flutter 프로젝트 생성
flutter create money_pet
cd money_pet

# 2. 필요 패키지 추가 (pubspec.yaml)
# dependencies:
#   flutter:
#     sdk: flutter
#   provider: ^6.0.0
#   go_router: ^12.0.0
#   firebase_core: ^2.24.0
#   cloud_firestore: ^4.13.0
#   firebase_auth: ^4.15.0
#   rive: ^0.12.0
#   share_plus: ^7.0.0

# 3. 패키지 설치
flutter pub get

# 4. 개발 서버 시작
flutter run

# 5. 실기기에서 확인
# → Hot Reload로 즉시 테스트!
```

---

### 1️⃣2️⃣ Flutter 개발 팁

#### Hot Reload vs Hot Restart
```
Hot Reload (r 키):
- 코드 변경 즉시 반영 (1초 이내)
- 상태 유지
- UI 수정 시 사용

Hot Restart (R 키):
- 앱 재시작
- 상태 초기화
- 상태 관리 변경 시 사용
```

#### 디버깅
```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools

# 성능 프로파일링
flutter run --profile

# 레이아웃 디버그
# Widget Inspector 사용 (DevTools)
```

#### 애니메이션 최적화
```dart
// RepaintBoundary로 리페인트 영역 최소화
RepaintBoundary(
  child: CharacterWidget(),
);

// const 사용으로 리빌드 방지
const Text('머니펫');
```

---

## 📄 라이선스

TBD

---

## 👥 팀

TBD

---

**© 2025 MoneyPet. All rights reserved.**

---

## 🔄 최신 업데이트

### 2025-12-02 (2차): 통일된 다크 테마 + 헤더 압축 최적화 🌙

**완료된 작업:**
- ✅ **캐릭터 네이밍 최신화**
  - constants.dart 주석 업데이트 (세이브쉽, 헌터캣, 체이서폭스)

- ✅ **통일된 다크 퍼플 테마 적용**
  - 진한 다크 퍼플 배경: `Color(0xFF1A1625)` (검정에 가까운 세련된 느낌)
  - 파스텔 보라 액센트: `Color(0xFFB794F6)` (버튼, 진행바, 캐릭터 등)
  - 성향별 색상 제거 → 하나의 컬러로 통일
  - 화이트 카드가 잘 돋보이는 대비 효과

- ✅ **헤더 압축 최적화 (방안 C)**
  - AppBar 제거 → 미니멀 커스텀 헤더 (120px → 48px)
  - 진행바 + 카운트 통합 (8px → 28px, 퍼센트 표시 추가)
  - 캐릭터 영역 압축 (80px → 68px)
  - **총 절약: 84px** → 90% 디바이스에서 한 화면에 모든 내용 표시

- ✅ **퀴즈 피드백 영역 제거**
  - "정답입니다! 🎉" / "아쉬워요! 💪" UI 완전 제거
  - 캐릭터 말풍선에서만 피드백 표시
  - 해설 카드만 깔끔하게 표시
  - 공간 효율 극대화

**기술적 세부사항:**
```dart
// 통일된 컬러 시스템
backgroundColor: AppColors.learningBackground  // Color(0xFF1A1625)
accent: AppColors.learningAccent              // Color(0xFFB794F6)

// 미니멀 헤더 (48px)
Container(
  height: 48,
  child: Row([닫기] Day 7 • 복리의 기초)
)

// 진행바 + 카운트 통합 (28px)
Row(
  [▰▰▰▱▱ 진행바]  [60%]  [3/5]
)
```

**디자인 개선 효과:**
- **다크 모던**: 프리미엄한 느낌, 눈의 피로 감소
- **공간 효율**: 한 화면에 모든 내용 표시 가능
- **통일성**: 일관된 보라 계열 브랜드 컬러
- **가독성**: 화이트 카드와의 명확한 대비

**변경 파일:**
- `lib/utils/constants.dart` - 새로운 컬러 시스템 추가
- `lib/screens/learning/learning_screen.dart` - 헤더 압축 + 다크 테마
- `lib/screens/learning/quiz_screen.dart` - 헤더 압축 + 피드백 제거 + 다크 테마

---

### 2025-12-02 (1차): 학습/퀴즈 화면 디자인 대폭 개선 🎨

**완료된 작업:**
- ✅ **학습 화면 3단계 디자인 개선** (`lib/screens/learning/learning_screen.dart`)
  - **1단계: 컬러 시스템**
    - 배경에 성향별 컬러 그라데이션 적용 (personalityColor.withOpacity(0.05))
    - 카드에 성향별 그림자 효과 추가 (하얀 카드 + 컬러 그림자)
    - Tip 영역에 성향 컬러 테마 적용
  - **2단계: 캐릭터 상호작용**
    - 상단 고정 캐릭터 영역 추가 (56x56 원형 Placeholder)
    - 진행 상황에 따른 동적 말풍선 메시지
    - "함께 배워볼까요? 😊" → "잘하고 있어요! 👍" → "거의 다 왔어요! 💪"
  - **3단계: 타이포그래피**
    - 본문 폰트 크기 17→18px, line-height 1.8
    - 타이틀 titleSmall → titleMedium
    - 카드 padding 및 spacing 개선
  - **애니메이션 효과**
    - AnimatedSwitcher + FadeTransition (300ms)
    - 카드 전환 시 부드러운 fade in/out 효과
    - ValueKey를 통한 정확한 위젯 식별

- ✅ **퀴즈 화면 동일 개선 적용** (`lib/screens/learning/quiz_screen.dart`)
  - [x] 학습 화면과 동일한 3단계 개선 + 애니메이션
  - 정답/오답에 따른 캐릭터 반응 메시지
    - 답변 전: "신중하게 생각해봐요! 🤔"
    - 정답: "정답이에요! 👏"
    - 오답: "아쉬워요! 다시 도전해봐요 💪"
  - 질문 카드 디자인 개선 (headlineMedium, fontSize 22px)
  - 해설 카드 스타일링 강화 (정답/오답별 테두리 색상)

**기술적 세부사항:**
```dart
// 배경 그라데이션
backgroundColor: personalityColor.withOpacity(0.05)

// 카드 그림자
BoxShadow(
  color: personalityColor.withOpacity(0.1),
  blurRadius: 20,
  offset: const Offset(0, 8),
)

// 애니메이션 전환
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  child: Widget(key: ValueKey(index)), // 정확한 위젯 식별
)
```

**디자인 철학:**
- **시각적 계층**: 하얀 카드 + 컬러 배경으로 콘텐츠에 집중
- **성향별 정체성**: 사용자 성향 컬러를 은은하게 활용
- **캐릭터 동행**: 상단 고정으로 학습 내내 함께하는 느낌
- **부드러운 전환**: 300ms fade 효과로 전문적인 UX

**다음 단계:**
- 프레임 애니메이션 통합 시 Placeholder 교체
- 실제 콘텐츠 투입 후 가독성 테스트
- 사용자 피드백 수집 및 미세 조정

---

### 2025-11-29: 런타임 에러 수정 및 UI 개선 🔧

**완료된 작업:**
- ✅ **PersonalityType 런타임 에러 수정** (Critical Fix)
  - Extension 기반 → Enhanced Enum으로 변환
  - `color`, `lightColor`, `displayName` 등을 compile-time 필드로 변경
  - "Class 'PersonalityType' has no instance getter 'color'" 에러 해결
  - 프로덕션 안정성 확보 (런타임 로딩 이슈 제거)
- ✅ **홈화면 UI 정리**
  - 성향별 캐릭터 이름 표시 제거
  - 프레임 애니메이션 준비를 위한 UI 간소화

**기술적 변경사항:**
```dart
// Before: Extension 방식
enum PersonalityType { safe, balanced, aggressive, challenger }
extension PersonalityTypeExtension on PersonalityType {
  Color get color { /* switch */ }
}

// After: Enhanced Enum (Dart 2.17+)
enum PersonalityType {
  safe(
    color: AppColors.safeType,
    displayName: '안전형',
    // ...
  );

  final Color color;
  final String displayName;
  // ...
}
```

**왜 변경했나요?**
- Extension 메서드는 특정 Flutter 환경에서 런타임 로딩 이슈 발생
- Enhanced Enum은 컴파일 타임에 필드가 보장되어 안정적
- 프로덕션 사용자가 동일 에러를 경험하지 않도록 예방

---

### 2025-11-27: Firebase Authentication 구현 완료 🔐

**완료된 작업:**
- ✅ Firebase 패키지 업그레이드 (GoogleUtilities 8.x 호환성 확보)
  - firebase_core: 3.6.0, firebase_auth: 5.3.1
  - cloud_firestore: 5.4.4, firebase_storage: 12.3.4
  - firebase_analytics: 11.3.3
- ✅ AuthService 구현 (`lib/services/auth_service.dart`)
  - Google Sign-In 연동
  - 이메일/비밀번호 회원가입/로그인
  - 한국어 에러 메시지 (14종)
- ✅ LoginScreen에 Firebase Auth 통합
- ✅ Android SHA-1 지문 추가 (Firebase Console)
- ✅ **Android에서 Google Sign-In 테스트 완료** 🎉

**코드 변경사항:**
```dart
// lib/services/auth_service.dart
- Google Sign-In 플로우 구현
- Firebase Auth credential 생성
- 이메일/비밀번호 인증
- 한국어 에러 메시지 매핑

// lib/screens/auth/login_screen.dart
- AuthService 통합
- Google 로그인 버튼 활성화
- 로딩 상태 및 에러 핸들링
```

**다음 단계:**
- UserProvider와 Firebase UID 연동
- Firestore에 사용자 프로필 동기화
- AuthStateChanges 리스너 추가

---

### 2025-11-28: 핵심 화면 구현 완료 확인 🎉

**확인된 구현 완료 항목:**
- ✅ **MainScreen**: 하단 탭 네비게이션 (홈/학습/설정)
- ✅ **HomeScreen**: 캐릭터, 오늘의 학습 카드, 스트릭, 통계, 공유
- ✅ **LearningTabScreen**: 진행 상황 카드, Day 목록, Month별 분류
- ✅ **LearningScreen**: 콘텐츠 카드 스와이프, 페이지 인디케이터, 네비게이션
- ✅ **QuizScreen**: 5문항 객관식, 정답/오답 피드백, 진행 바
- ✅ **QuizResultScreen**: 점수 결과, 포인트 획득
- ✅ **SettingsScreen**: 프로필 카드, 설정 옵션

**진행률 업데이트 (2025-11-29 현실적 재평가):**
```
온보딩:        80% (기본 완료, UX 개선 필요)
핵심 화면:     60% (구조 완료, 완성도/테스트 부족)
게이미피케이션: 60% (로직 완료, UI 개선 필요)
콘텐츠:         0% (더미 데이터, 템플릿만 준비됨)
애니메이션:    20% (Placeholder만)
Firebase:      60% (Auth 완료, Firestore 대기)
예외처리:      30% (일부만, 통합 테스트 필요)
──────────────────────────────────────
전체:          44% (구조 완성, 완성도 미달)
```

> **중요**: 모든 화면이 **기본 구조는 완성**되었으나, 프로덕션 수준의 완성도/테스트/디자인은 부족

**남은 주요 작업 (역할별):**

### 🔧 개발팀 작업 (코드/디자인)
1. **완성도 개선** (P0): 디자인 통일, UX 개선, 예외 처리, 로딩/에러 상태
2. **통합 테스트** (P0): 전체 플로우 테스트, 엣지 케이스 처리
3. **Firestore 콘텐츠 시스템** (P0):
   - Firestore 기반 콘텐츠 CRUD 구현
   - 백오피스에서 수정/추가/삭제 용이한 DB 구조 설계
   - **학습 콘텐츠는 반드시 DB에서 관리** (하드코딩 금지)
4. **백오피스 웹 개발** (P1): 콘텐츠 관리 시스템 (WYSIWYG 에디터)
5. **SNS 공유 이미지** (P1): 이미지 생성 기능 (현재 텍스트만)

### 📝 외부 전문가 작업 (콘텐츠/디자인)
1. **학습 콘텐츠 작성** (P0): Day 1-30 학습 콘텐츠 (120개: 30일 × 4성향)
2. **퀴즈 문항 작성** (P0): 600개 문항 (5문항 × 30일 × 4성향)
3. **프레임 애니메이션 제작** (P0): 52개 애니메이션 (13상태 × 4캐릭터)

> **⚠️ 중요 아키텍처 원칙**:
> - 학습 콘텐츠는 **Firestore에 저장**, 앱에서는 실시간으로 불러옴
> - 백오피스에서 콘텐츠 편집 시 즉시 앱에 반영
> - 앱 재배포 없이 콘텐츠 업데이트 가능해야 함

---

### 2025-11-26: Firebase 기본 설정 완료 🔥

**완료된 작업:**
- ✅ FlutterFire CLI로 firebase_options.dart 생성
- ✅ Android: google-services.json + build.gradle 설정
- ✅ iOS: GoogleService-Info.plist + CocoaPods 설정
- ✅ main.dart: Firebase.initializeApp() 호출
- ✅ iOS CocoaPods 의존성 충돌 해결 (GoogleUtilities 7.x → 8.x)

---

### 2025-01-15: 캐릭터 우선 온보딩 플로우 도입

**변경 사항:**
- 캐릭터를 먼저 선택하고, 그 캐릭터와 함께 성향을 찾아가는 방식으로 변경
- 캐릭터가 성향 퀴즈에 동행하며 대사 표시
- 성향 결과에서 캐릭터가 일치/불일치 여부에 따라 다른 반응

**새로운 플로우:**
```
스플래시 → 앱 소개 → 캐릭터 선택 ⭐ → 성향 퀴즈 → 성향 결과 → 이름 설정 → 목표 설정 → 로그인/회원가입 🔴 → 홈
```

**로그인 정책:**
- 온보딩 완료 후 로그인/회원가입 필수
- Google OAuth + 직접 회원가입 지원
- 로그인 없이는 퀴즈/학습 진행 불가
- 온보딩 데이터는 로컬 저장 → 로그인 시 Firestore 동기화

### 🎨 새로운 컴포넌트

#### CharacterProvider
캐릭터 선택 상태 관리
- `selectedCharacter`: 처음 선택한 캐릭터
- `finalPersonality`: 퀴즈 결과 성향
- `isCharacterMatchingPersonality`: 일치 여부

#### AnimatedCharacter 위젯
캐릭터 애니메이션 (현재 Placeholder)
- 프레임 기반 애니메이션 시스템
- 13-state 지원 및 자동 전환
- 말풍선 통합
- 🔜 실제 프레임 파일 추가 예정

#### SpeechBubble 위젯
말풍선 UI
- 슬라이드 업 애니메이션
- 커스텀 페인터로 꼬리 그리기

### 🐛 버그 수정
- ✅ 스크롤 바운스 효과 제거 (전역 ScrollBehavior 추가)
- ✅ 온보딩 완료 후 홈 화면 로딩 이슈 해결
- ✅ 이름 설정 UX 개선 (Placeholder + 항상 활성화된 다음 버튼)

### 📚 문서화
- [`docs/DEVELOPMENT_LOG.md`](./docs/DEVELOPMENT_LOG.md) - 상세 개발 로그 및 TODO
- [`docs/BACKOFFICE_DESIGN.md`](./docs/BACKOFFICE_DESIGN.md) - 백오피스 데이터 구조 설계

### 🔜 다음 단계
1. **🟡 Google OAuth 설정** (P0) - Firebase Console에서 클라이언트 ID 설정
2. **🔴 Firebase Auth 연동** (P0) - auth_service.dart 생성, 로그인/회원가입 기능
3. **SharedPreferences 영구 저장** - 로컬 데이터 저장 구현
4. **홈 화면 구현** - 학습 시작 진입점
5. **학습/퀴즈 화면 구현** - 핵심 기능 완성
6. **프레임 애니메이션 통합** - 캐릭터 애니메이션 제작 및 적용 (52개)
7. **실제 콘텐츠 작성** - Day 1-10 학습 콘텐츠 및 퀴즈 (샘플)
8. **Firestore 연동** - 사용자 데이터 영구 저장
9. **백오피스 개발** - 콘텐츠 관리 시스템 (v1.1 이후)

자세한 내용은 [`docs/TODO.md`](./docs/TODO.md) 및 [`docs/DEVELOPMENT_LOG.md`](./docs/DEVELOPMENT_LOG.md) 참고

