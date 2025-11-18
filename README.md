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
- 🎯 성향 진단 (5문항) → 4가지 캐릭터 매칭
- 📚 1일 1학습 시스템 (Day 1-365)
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
   - 예: 코인캣 + 안전형 + 1000P → "안전 코인캣" 디자인
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

#### 7. 제외 기능 (v1.1 이후)
- ❌ 꾸미기 (캐릭터 커스터마이징)
- ❌ 실천 인증
- ❌ 소셜 공유 (친구 초대, 진도 비교)
- ❌ 커뮤니티
- ❌ 다크 모드
- ❌ 오프라인 모드

---

## 🏗️ 기술 스택

### 추천 스택 (TBD)
```
프론트엔드:
- React Native (Expo) or Flutter
- 상태관리: Redux Toolkit / Zustand (RN) or Provider (Flutter)
- 애니메이션: Lottie / Rive

백엔드:
- Firebase (Firestore + Authentication + Storage)
- or Supabase (PostgreSQL + Auth + Storage)

배포:
- iOS: TestFlight → App Store
- Android: Google Play 내부 테스트 → Play Store

CI/CD:
- GitHub Actions
- EAS Build (Expo) or Fastlane
```

---

## 📋 MVP 기능 체크리스트

### 🔴 필수 기능 (출시 전)

#### 온보딩
- [ ] Splash
- [ ] Welcome (3 슬라이드, 건너뛰기 가능)
- [ ] 성향 진단 (5문항, 자동 전환)
- [ ] 진단 결과
- [ ] 캐릭터 이름 설정
- [ ] 목표 설정
- [ ] 첫 학습 안내

#### 메인 기능
- [ ] 홈 화면
  - [ ] 캐릭터 표시 (성향별)
  - [ ] 오늘의 학습 카드
  - [ ] 스트릭 카운터 (🔥7)
- [ ] 학습 화면
  - [ ] 콘텐츠 카드 (스와이프)
  - [ ] 페이지 인디케이터 (●●○○○)
- [ ] 퀴즈 화면
  - [ ] 5문항 객관식
  - [ ] 정답/오답 피드백
  - [ ] 해설 표시
  - [ ] 재개 기능 없음 (처음부터만)
- [ ] 학습 탭
  - [ ] 진도 카드 (Month 진도만)
  - [ ] 진도 상세 (탭 시 전체 진도 표시)
  - [ ] Day 목록
  - [ ] 필터 (전체/완료/진행중/잠김)
- [ ] 설정 화면
  - [ ] 프로필 카드
  - [ ] 이름 변경
  - [ ] 성향 변경 (Day 1 재시작 확인 팝업)
  - [ ] 알림 설정

#### 신규 필수 기능
- [ ] **Day 30 완료 화면** (다른 성향 체험 유도)
- [ ] **SNS 공유 기능** (이미지 생성 + 시스템 공유)
- [ ] **성향 변경 확인 팝업** (Day 1 재시작 고지)

#### 게이미피케이션
- [ ] 포인트 시스템 (획득만, 사용처 없음)
- [ ] 스트릭 카운터 (연속 학습일)
- [ ] 학습 완료 보상 화면

#### 캐릭터 애니메이션 (5종 필수)
- [ ] Idle (호흡, 2초 loop)
- [ ] Welcome (환영, 손 흔들기)
- [ ] Reading (학습, 책 읽기)
- [ ] Happy (완료, 점프 + 별)
- [ ] Sad (미접속, 시무룩)

#### 예외 처리
- [ ] 네트워크 에러 (전체 화면 + 토스트)
- [ ] 학습 중단/재개 (콘텐츠만, 퀴즈 제외)
- [ ] Empty State
- [ ] 로딩 상태 (풀스크린 + 인라인)

#### 콘텐츠 (성향별 4세트)
- [ ] Day 1-30 콘텐츠 작성 (120개: 30일 × 4성향)
- [ ] 퀴즈 문항 작성 (600개: 5문항 × 30일 × 4성향)

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
- 캐릭터 애니메이션 (5종)

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
- **밸런스형 (밸런스토끼)**: `#B794F6` (파스텔 보라)
- **공격형 (코인캣)**: `#9F7AEA` (메인 보라)
- **도전형 (세이빙덕)**: `#4A5568` (차분한 회색)

### 타이포그래피
- **H1**: 32px, Bold
- **H2**: 24px, Bold
- **H3**: 20px, Bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular

---

## 📂 프로젝트 구조

```
your_money_pet/
├── docs/                    # 문서
│   ├── strategy.md          # 전략 기획서
│   ├── app_spec.md          # 앱 상세 기획서
│   └── api.md               # API 명세서 (TBD)
├── src/
│   ├── screens/             # 화면
│   ├── components/          # 공통 컴포넌트
│   ├── navigation/          # 네비게이션
│   ├── services/            # API, DB
│   ├── utils/               # 유틸리티
│   └── assets/              # 이미지, 폰트
├── README.md
└── package.json
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

## 📄 라이선스

TBD

---

## 👥 팀

TBD

---

**© 2025 MoneyPet. All rights reserved.**
