# MoneyPet 개발 로그

## 📅 2026-01-01 세션: Firestore 백오피스 통합 구현

### 🎯 목표
백오피스 팀이 설계한 Firestore 스키마에 맞춰 학습 콘텐츠 및 퀴즈 데이터 통합

### 📋 완료된 작업

#### 1. Firestore 모델 생성 ✅
**커밋:** 8800ae0
**파일:** `lib/models/learning_content_model.dart`, `lib/models/quiz_model.dart`
**날짜:** 2026-01-01

**변경 사항:**
- ✅ **LearningContent 모델** (`learning_content_model.dart`)
  - Firestore `learning_contents` 컬렉션 매핑
  - 필드: `day`, `personality`, `title`, `estimatedMinutes`, `points`, `cards[]`, `createdAt`, `updatedAt`
  - 중요: `personality` 필드 사용 (personalityType 아님)
  - Firestore Timestamp → DateTime 자동 변환
  - cards 배열 자동 정렬 (order 필드 기준)

- ✅ **LearningCard 모델**
  - 필드: `order`, `type` ("text", "image", "quiz_link"), `content`, `imageUrl`, `tip`
  - type 기반 카드 렌더링 지원
  - quiz_link는 향후 구현 예정 (현재는 필터링)

- ✅ **Quiz 모델** (`quiz_model.dart`)
  - Firestore `quiz_contents` 컬렉션 매핑
  - 필드: `day`, `personality`, `questions[]`, `totalPoints`, `passingScore`, `createdAt`, `updatedAt`
  - questions 배열 자동 정렬 (order 필드 기준)

- ✅ **QuizQuestion 모델**
  - 필드: `order`, `question`, `options[]`, `points`
  - options는 배열 순서 보장 (별도 order 필드 없음)

- ✅ **QuizOption 모델**
  - 필드: `text`, `isCorrect`, `explanation`
  - 각 선택지마다 개별 해설 제공

**코드 예시:**
```dart
// LearningContent.fromJson() - Firestore 데이터 변환
factory LearningContent.fromJson(Map<String, dynamic> json) {
  final cardsList = (json['cards'] as List)
      .map((c) => LearningCard.fromJson(c))
      .toList();
  cardsList.sort((a, b) => a.order.compareTo(b.order));

  return LearningContent(
    day: json['day'] as int,
    personality: json['personality'] as String,
    title: json['title'] as String,
    estimatedMinutes: json['estimatedMinutes'] as int,
    points: json['points'] as int,
    cards: cardsList,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );
}
```

---

#### 2. Firestore 서비스 생성 ✅
**커밋:** 8800ae0
**파일:** `lib/services/learning_content_service.dart`
**날짜:** 2026-01-01

**변경 사항:**
- ✅ **LearningContentService 클래스 구현**
  - `getLearningContent(day, personality)`: 학습 콘텐츠 조회
  - `getQuiz(day, personality)`: 퀴즈 조회
  - `getLearningContentWithQuiz(day, personality)`: 병렬 로딩으로 성능 최적화
  - `getQuizById(quizId)`: quiz_link 카드용 (향후 사용)

- ✅ **Firestore 쿼리 구조**
  - Composite Index 필요: (personality, day)
  - learning_contents: 백오피스 팀이 이미 생성 완료
  - quiz_contents: 첫 실행 시 Firebase 자동 생성 안내

- ✅ **병렬 로딩 구현** (백오피스 팀 권장)
  - Future.wait()로 학습 콘텐츠 + 퀴즈 동시 조회
  - 순차 대비 ~50% 시간 단축

---

#### 3. LearningProvider Firestore 통합 ✅
**커밋:** 8800ae0
**파일:** `lib/providers/learning_provider.dart`
**날짜:** 2026-01-01

**변경 사항:**
- ✅ **loadLearningDay() 메서드 업데이트**
  - 기존: 하드코딩된 임시 데이터 사용
  - 변경: Firestore에서 실시간 조회 (`personality` 파라미터 추가)

- ✅ **어댑터 패턴 구현**
  - Firestore 모델 → 기존 LearningDayModel 변환
  - 기존 UI 화면 로직 유지 (최소한의 변경)
  - quiz_link 카드 필터링 (향후 구현 예정)

---

#### 4. LearningScreen 업데이트 ✅
**커밋:** 8800ae0
**파일:** `lib/screens/learning/learning_screen.dart`
**날짜:** 2026-01-01

**변경 사항:**
- ✅ **personality 자동 전달**
  - UserProvider에서 personalityType.name 추출

- ✅ **콘텐츠 없음 에러 처리** (백오피스 가이드 적용)
  - "준비 중인 학습입니다" 메시지 표시

- ✅ **이미지 로딩 인디케이터 추가**
  - loadingBuilder로 진행률 표시

- ✅ **이미지 로드 실패 처리 개선**
  - errorBuilder로 명확한 에러 메시지

---

#### 5. BACKOFFICE_DESIGN.md 문서 업데이트 ✅
**파일:** `docs/BACKOFFICE_DESIGN.md`
**날짜:** 2026-01-01

**변경 사항:**
- ✅ **필드명 일관성 수정**: `personalityType` → `personality`
- ✅ **제거된 필드 삭제**: `isPublished`, `version`, `createdBy`, `tags`
- ✅ **Timestamp 필드 수정**: 문자열 → Firestore Timestamp
- ✅ **미구현 섹션 표시**: Character Config, App Config 경고 추가

---

### 🎯 구현 완료 요약

#### 핵심 기능
1. ✅ Firestore 스키마에 맞춘 모델 생성 (LearningContent, Quiz)
2. ✅ Firestore 조회 서비스 구현 (병렬 로딩 최적화)
3. ✅ 기존 화면과 호환되는 어댑터 패턴 적용
4. ✅ personality 기반 콘텐츠 필터링
5. ✅ 종합적인 에러 처리 (콘텐츠 없음, 이미지 로드 실패)

#### 기술적 결정
- **어댑터 패턴**: 기존 UI 로직 유지, 점진적 마이그레이션 가능
- **병렬 로딩**: Future.wait()로 성능 최적화
- **quiz_link 필터링**: 현재 앱 구조에서는 학습→퀴즈 순차 진행

#### 향후 작업
- quiz_link 카드 타입 구현 (학습 중간 퀴즈 삽입)
- estimatedMinutes UI 표시
- SharedPreferences 학습 진행 상태 영구 저장
- Firebase Crashlytics 에러 로깅

---

## 📅 2025-12-26 세션: 홈 화면 랜덤 애니메이션 로직 추가

### 🎯 목표
홈 화면 진입 시 5개 home state 중 랜덤하게 하나를 선택하여 다양한 캐릭터 모습 표시

### 📋 완료된 작업

#### 1. 홈 화면 랜덤 state 선택 로직 구현 ✅
**커밋:** 068f974
**파일:** `lib/screens/home/home_screen.dart`
**날짜:** 2025-12-26

**변경 사항:**
- ✅ `_selectRandomHomeState()` 메서드 추가
  - 5개 home state 배열 선언 (`homeIdle`, `homeStudying`, `homeExcited`, `homeSleepy`, `homeCelebration`)
  - `Random().nextInt()` 사용하여 랜덤 선택
  - 매번 `initState()`에서 호출하여 화면 진입 시마다 다른 애니메이션 표시
- ✅ `_currentHomeState` 필드 추가
  - `late CharacterAnimationState _currentHomeState` 선언
  - 랜덤 선택된 state 저장
- ✅ 추후 확장 가능한 구조 설계
  - 주석으로 추후 유저 상태 기반 로직 확장 방향 명시
  - 예: 학습 완료 시 `homeStudying`, 연속 7일 시 `homeExcited` 등

**코드:**
```dart
/// 홈 화면 진입 시 랜덤하게 home state 선택
///
/// 현재: 5개 home state 중 랜덤
/// 추후: 유저 상태에 따라 분기 (예: 학습 완료 시 homeStudying, 연속 7일 시 homeExcited 등)
CharacterAnimationState _selectRandomHomeState() {
  final homeStates = [
    CharacterAnimationState.homeIdle,
    CharacterAnimationState.homeStudying,
    CharacterAnimationState.homeExcited,
    CharacterAnimationState.homeSleepy,
    CharacterAnimationState.homeCelebration,
  ];
  return homeStates[Random().nextInt(homeStates.length)];
}
```

---

#### 2. Icon 위젯 → AnimatedCharacter 위젯 교체 ✅
**커밋:** 068f974
**파일:** `lib/screens/home/home_screen.dart`
**날짜:** 2025-12-26

**변경 사항:**
- ❌ 삭제: `Icon(Icons.pets)` placeholder (단순 아이콘 표시)
- ✅ 추가: `AnimatedCharacter` 위젯 사용
  - `characterType`: 유저의 `personalityType` 사용
  - `state`: 랜덤 선택된 `_currentHomeState` 전달
  - `size`: 140 (기존과 동일)
- ✅ 프레임 애니메이션 준비 완료
  - 디자인팀에서 애니메이션 제작 시 즉시 적용 가능
  - 현재는 프레임 파일 없어서 placeholder 표시

**Before:**
```dart
child: Icon(
  Icons.pets,
  size: 70,
  color: personalityType.color,
),
```

**After:**
```dart
// 캐릭터 애니메이션
AnimatedCharacter(
  characterType: personalityType,
  state: _currentHomeState,
  size: 140,
),
```

---

#### 3. 성향 진단 화면 AnimatedCharacter 사용 확인 ✅
**파일:**
  - `lib/screens/onboarding/personality_test_screen.dart`
  - `lib/screens/onboarding/personality_result_screen.dart`
**날짜:** 2025-12-26

**확인 결과:**
- ✅ **성향 진단 퀴즈 화면**: `AnimatedCharacter` 정상 사용 중
  - State: `CharacterAnimationState.personalityIdle`
  - 코드 구조 정상, 프레임 파일만 없음
- ✅ **성향 진단 완료 화면**: `AnimatedCharacter` 정상 사용 중
  - State: `CharacterAnimationState.resultCelebration`
  - 코드 구조 정상, 프레임 파일만 없음
- ⚠️ **Placeholder 원인**: 단순히 프레임 파일 부재 (코드 문제 아님)
  - `assets/animations/characters/*/personality_idle/frame_01.png` 없음
  - `assets/animations/characters/*/result_celebration/frame_01.png` 없음

---

### 📊 요약

**홈 화면 개선:**
- 기존: 단순 아이콘 표시
- 변경: 5개 home state 중 랜덤 애니메이션 표시
- 효과: 다양성 확보, 프레임 애니메이션 준비 완료

**확인된 문제:**
- 모든 AnimatedCharacter 위젯이 정상적으로 사용되고 있음
- Placeholder가 나오는 유일한 이유는 프레임 파일 부재
- 디자인팀에서 52개 애니메이션 제작 시 즉시 적용 가능

**다음 단계:**
- [ ] 디자인팀: 52개 애니메이션 프레임 제작
- [ ] v1.1+: 유저 상태 기반 애니메이션 선택 로직 추가
  - 학습 완료 시: `homeStudying`
  - 연속 7일 이상: `homeExcited`
  - 심야 시간대: `homeSleepy`
  - 목표 달성: `homeCelebration`
  - 기본: `homeIdle`

---

## 📅 2025-12-24 세션: 통합 애니메이션 방식 재설계 (13-State)

### 🎯 목표
애니메이션 상태 시스템 재설계 (10개 → 13개 상태, 통합 애니메이션 방식 채택)

### 📋 배경

**문제 발견:**
개별 상태 조합 방식의 근본적인 UX 문제 발견
- `idle` 애니메이션 마지막 프레임 (포즈A) → `thinking` 첫 프레임 (포즈B) 전환 시 뚝 끊김
- Midjourney/Runway는 정확한 프레임 일치를 보장할 수 없음
- 사용자 경험에 치명적 영향

**해결 방안:**
- **Option A (채택):** 화면별 통합 애니메이션
  - 예: `quiz_correct_flow` = thinking → happy → idle 복귀를 **하나의 애니메이션**으로 제작
  - 장점: 완벽한 전환, 의도된 UX 플로우
  - 단점: 용량 증가 (40MB → 192MB), 유연성 감소
- **Option B (기각):** Neutral Pose 통일 - Midjourney로 정확한 포즈 재현 어려움
- **Option C (기각):** 부분 통합 - 여전히 일부 전환 끊김

**의사결정:** UX 우선순위로 Option A 채택

---

## ✅ 완료된 작업 (2025-12-24)

### 1. CharacterAnimationState enum 재설계 ✅
**커밋:** 1695ecc
**파일:** `lib/models/character_animation_config.dart:1-25`
**날짜:** 2025-12-24

**변경 사항:**
- ❌ 삭제: `thinking`, `happy`, `confused`, `reactionPositive`, `reactionNegative`, `reactionNeutral` (6개)
- ✅ 추가: `personalityIdle`, `personalitySelected`, `quizIdle`, `quizCorrectFlow`, `quizWrongFlow`, `resultCelebration` (6개)
- 🔄 이름 변경:
  - `greeting` → `characterGreetingLoop`
  - `selected` → `characterSelected`
  - `idle` → `homeIdle`

**결과:** 14개 → 13개 상태 (통합 애니메이션 방식 적용)

---

### 2. Enum → 폴더명 변환 로직 구현 ✅
**커밋:** 5e2f0b3
**파일:** `lib/models/character_frame_animation.dart:22-224`
**날짜:** 2025-12-24

**변경 사항:**
- ✅ `_stateToFolderName()` 헬퍼 함수 추가
  - camelCase enum → snake_case 폴더명 변환
  - 예: `CharacterAnimationState.characterGreetingLoop` → `'character_greeting_loop'`
  - 13개 모든 상태 매핑 완료
- ✅ `getFramePath()` 메서드 업데이트
  - `state.name` → `_stateToFolderName(state)` 사용
  - 올바른 snake_case 폴더 경로 생성 보장
- ✅ `forState()` fallback 메서드 완전 재작성
  - 구식 상태 제거 (greeting, selected, idle, thinking, happy, confused 등)
  - 13개 신규 상태로 교체 (기본 프레임 수 포함)
  - 유연한 타이밍 정책 반영 ("약 X초")

---

### 3. 자동 전환 로직 구현 ✅
**커밋:** a6c6108
**파일:**
  - `lib/models/character_frame_animation.dart:7-27`
  - `lib/services/animation_config_loader.dart:65-72`
  - `lib/widgets/animated_character.dart:40-236`
**날짜:** 2025-12-24

**변경 사항:**
- ✅ **CharacterFrameAnimation 모델 업데이트**
  - `autoTransitionTo` 필드 추가 (String?, 선택적)
  - 애니메이션 완료 후 자동 전환할 상태 지정 가능
  - 예: `personalitySelected` → `personalityIdle`

- ✅ **AnimationConfigLoader 서비스 업데이트**
  - `createAnimation()` 메서드에서 JSON `autoTransitionTo` 읽기 지원
  - JSON 형식: `"autoTransitionTo": "personalityIdle"`

- ✅ **AnimatedCharacter 위젯 업데이트**
  - `_currentState` 내부 상태 추가 (자동 전환 관리)
  - `_activeState` getter 추가 (현재 활성 상태 반환)
  - `_handleAutoTransition()` 메서드 추가 (자동 전환 처리)
  - `_stringToState()` 헬퍼 추가 (문자열 → enum 변환)
  - `addStatusListener`에서 애니메이션 완료 시 자동 전환 실행
  - `didUpdateWidget`에서 외부 상태 변경 동기화
  - `build()`와 `_buildPlaceholder()`에서 `_activeState` 사용

**결과:**
- `personalitySelected` 완료 → 자동으로 `personalityIdle`로 전환
- `quizCorrectFlow` 완료 → 자동으로 `quizIdle`로 전환
- `quizWrongFlow` 완료 → 자동으로 `quizIdle`로 전환
- `homeCelebration` 완료 → 자동으로 `homeIdle`로 전환

---

### 4. 폴더 구조 재편 ✅
**커밋:** 088b510
**파일:** `assets/animations/characters/*/`
**날짜:** 2025-12-24

**변경 사항:**
- ✅ **폴더 이름 변경 (각 캐릭터별 3개)**
  - `greeting/` → `character_greeting_loop/`
  - `selected/` → `character_selected/`
  - `idle/` → 삭제 후 `home_idle/` 신규 생성 (빈 폴더)

- ✅ **폴더 삭제 (각 캐릭터별 3개)**
  - `thinking/` (통합 애니메이션에 포함)
  - `happy/` (quiz_correct_flow에 포함)
  - `confused/` (quiz_wrong_flow에 포함)

- ✅ **폴더 신규 생성 (각 캐릭터별 7개)**
  - `personality_idle/` (성향 퀴즈 대기)
  - `personality_selected/` (성향 선택 반응)
  - `quiz_idle/` (학습 퀴즈 대기)
  - `quiz_correct_flow/` (정답 통합 애니메이션)
  - `quiz_wrong_flow/` (오답 통합 애니메이션)
  - `result_celebration/` (결과 축하)
  - `home_idle/` (홈 기본 대기)

- ✅ **기존 폴더 유지 (각 캐릭터별 5개)**
  - `home_studying/`, `home_excited/`, `home_sleepy/`, `home_celebration/`
  - `character_greeting_loop/`, `character_selected/` (이름 변경됨)

**최종 결과:**
- 각 캐릭터당 13개 상태 폴더
- 총 52개 폴더 (4캐릭터 × 13상태)
- hunter_cat: 13 folders ✓
- money_bear: 13 folders ✓
- save_sheep: 13 folders ✓
- chaser_fox: 13 folders ✓

---

### 5. animation_config.json 재작성 ✅
**커밋:** e5ab1c6
**파일:** `assets/animations/characters/*/animation_config.json` (4개 파일)
**날짜:** 2025-12-24

**변경 사항:**
- ✅ **기존 10-state 키 → 13-state 키 변경**
  - `greeting` → `characterGreetingLoop`
  - `selected` → `characterSelected`
  - `idle` → `homeIdle`
  - `homeStudying`, `homeExcited`, `homeSleepy`, `homeCelebration` 유지 (camelCase 그대로)

- ❌ **삭제된 state (3개)**
  - `thinking` (quiz_correct_flow/quiz_wrong_flow에 통합)
  - `happy` (quiz_correct_flow에 통합)
  - `confused` (quiz_wrong_flow에 통합)

- ✅ **신규 state 추가 (6개)**
  - `personalityIdle` (약 3초, loop)
  - `personalitySelected` (약 2초, one-shot, auto→personalityIdle)
  - `quizIdle` (약 3초, loop)
  - `quizCorrectFlow` (약 5초, one-shot, auto→quizIdle) ⭐ 통합 애니메이션
  - `quizWrongFlow` (약 5초, one-shot, auto→quizIdle) ⭐ 통합 애니메이션
  - `resultCelebration` (약 3초, one-shot)

- ✅ **autoTransitionTo 필드 추가 (4개 state)**
  - `personalitySelected` → "personalityIdle"
  - `quizCorrectFlow` → "quizIdle"
  - `quizWrongFlow` → "quizIdle"
  - `homeCelebration` → "homeIdle"

**유연한 타이밍 정책 적용:**
- 기존: "정확히 XX프레임" → 제작 부담
- 변경: "약 X초" → 실제 프레임 수는 제작 후 JSON에 기록
- 예: `characterGreetingLoop` = 약 5초 (실제 프레임 수는 제작팀이 결정)

**JSON 구조 예시:**
```json
{
  "characterGreetingLoop": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사 (약 5초)"
  },
  "personalitySelected": {
    "frameCount": 48,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "personalityIdle",
    "description": "성향 선택 반응 (약 2초, auto→personalityIdle)"
  },
  "quizCorrectFlow": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",
    "description": "정답 플로우: thinking→happy→idle (약 5초, auto→quizIdle)"
  }
}
```

**최종 결과:**
- 4개 캐릭터 JSON 파일 모두 13-state 시스템으로 업데이트
- 모든 one-shot 애니메이션에 autoTransitionTo 설정 완료
- 유연한 타이밍 정책 반영 ("약 X초")
- Commit: e5ab1c6

---

### 6. 화면별 State 사용 업데이트 ✅
**커밋:** bb8d045
**파일:**
  - `lib/screens/onboarding/character_preview_screen.dart:195-197`
  - `lib/screens/onboarding/personality_test_screen.dart:296`
  - `lib/screens/onboarding/personality_result_screen.dart:257`
  - `lib/services/character_animation_preloader.dart:25,39-42`
**날짜:** 2025-12-24

**변경 사항:**
- ✅ **캐릭터 선택 화면** (`character_preview_screen.dart`)
  - `CharacterAnimationState.greeting` → `CharacterAnimationState.characterGreetingLoop`
  - `CharacterAnimationState.selected` → `CharacterAnimationState.characterSelected`

- ✅ **성향 퀴즈 화면** (`personality_test_screen.dart`)
  - `CharacterAnimationState.thinking` → `CharacterAnimationState.personalityIdle`

- ✅ **성향 결과 화면** (`personality_result_screen.dart`)
  - `CharacterAnimationState.selected` → `CharacterAnimationState.resultCelebration`

- ✅ **애니메이션 프리로더** (`character_animation_preloader.dart`)
  - `greeting` → `characterGreetingLoop`
  - `selected`, `happy`, `thinking`, `confused` → `characterSelected`, `personalityIdle`, `personalitySelected`, `resultCelebration`
  - 프리로드 대상을 온보딩 4개 상태로 제한 (최적화)

**최종 결과:**
- 모든 화면에서 13-state 시스템 사용
- 더 이상 old state 참조 없음
- 프리로더 최적화 완료

---

### 7. pubspec.yaml 업데이트 ✅
**커밋:** 5950ff5
**파일:** `pubspec.yaml:64-123`
**날짜:** 2025-12-24

**변경 사항:**
- ✅ **10-state 경로 삭제**
  - `greeting/`, `selected/`, `idle/`, `thinking/`, `happy/`, `confused/`

- ✅ **13-state 경로 등록** (각 캐릭터당 13개)
  - `character_greeting_loop/`, `character_selected/`
  - `personality_idle/`, `personality_selected/`
  - `quiz_idle/`, `quiz_correct_flow/`, `quiz_wrong_flow/`
  - `result_celebration/`
  - `home_idle/`, `home_studying/`, `home_excited/`, `home_sleepy/`, `home_celebration/`

**최종 결과:**
- 4개 캐릭터 × 13개 상태 = 52개 폴더 경로 등록 완료
- 프레임 파일 추가 시 자동 인식

---

## 🚨 개발팀 작업 필요 (2025-12-24)

### ⚠️ 주의: Task #1-7 완료, 나머지 작업 진행 예정

### ~~1. CharacterAnimationState enum 재설계 (필수)~~ ✅ 완료
**파일:** `lib/models/character_animation_config.dart`

**변경:** 14개 → 13개 상태

**삭제되는 상태 (통합 애니메이션에 포함됨):**
- `thinking` → `quiz_correct_flow`와 `quiz_wrong_flow`에 포함
- `happy` → `quiz_correct_flow`에 포함
- `confused` → `quiz_wrong_flow`에 포함

**새로 추가되는 상태:**
```dart
enum CharacterAnimationState {
  // 카테고리 1: 캐릭터 선택 화면 (2개)
  characterGreetingLoop,  // 기존 greeting
  characterSelected,      // 기존 selected

  // 카테고리 2-A: 성향 퀴즈 전용 (2개)
  personalityIdle,        // 성향 문제 대기
  personalitySelected,    // 성향 선택 반응 (자동 전환)

  // 카테고리 2-B: 학습 퀴즈 전용 (3개)
  quizIdle,               // 학습 문제 대기
  quizCorrectFlow,        // 통합: thinking → happy → idle
  quizWrongFlow,          // 통합: thinking → confused → idle

  // 카테고리 3: 결과 화면 (1개)
  resultCelebration,      // 성향 결과 축하

  // 카테고리 4: 홈 화면 (5개)
  homeIdle,               // 기존 idle
  homeStudying,           // 기존 homeStudying
  homeExcited,            // 기존 homeExcited
  homeSleepy,             // 기존 homeSleepy
  homeCelebration,        // 기존 homeCelebration
}
```

---

### ~~2. Enum → 폴더명 변환 로직 구현 (필수)~~ ✅ 완료

**구현 완료:**
```dart
String _stateToFolderName(CharacterAnimationState state) {
  // camelCase → snake_case 변환
  switch (state) {
    case CharacterAnimationState.characterGreetingLoop:
      return 'character_greeting_loop';
    case CharacterAnimationState.characterSelected:
      return 'character_selected';
    case CharacterAnimationState.personalityIdle:
      return 'personality_idle';
    case CharacterAnimationState.personalitySelected:
      return 'personality_selected';
    case CharacterAnimationState.quizIdle:
      return 'quiz_idle';
    case CharacterAnimationState.quizCorrectFlow:
      return 'quiz_correct_flow';
    case CharacterAnimationState.quizWrongFlow:
      return 'quiz_wrong_flow';
    case CharacterAnimationState.resultCelebration:
      return 'result_celebration';
    case CharacterAnimationState.homeIdle:
      return 'home_idle';
    case CharacterAnimationState.homeStudying:
      return 'home_studying';
    case CharacterAnimationState.homeExcited:
      return 'home_excited';
    case CharacterAnimationState.homeSleepy:
      return 'home_sleepy';
    case CharacterAnimationState.homeCelebration:
      return 'home_celebration';
  }
}
```

---

### ~~3. 자동 전환 로직 구현 (필수)~~ ✅ 완료

**구현 완료:**
```dart
// animation_config.json에 autoTransitionTo 필드 추가
{
  "personalitySelected": {
    "frameCount": 48,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "personalityIdle"  // ← 신규
  }
}

// AnimatedCharacter 위젯에서 처리
void _onAnimationComplete() {
  final config = _currentConfig;
  if (config.containsKey('autoTransitionTo')) {
    final nextState = _stringToState(config['autoTransitionTo']);
    setState(() {
      _currentState = nextState;
    });
  }
}
```

---

### ~~4. 폴더 구조 재편 (필수)~~ ✅ 완료

**실행된 명령어:**
```bash
# 각 캐릭터마다 실행 (hunter_cat, money_bear, save_sheep, chaser_fox)
cd assets/animations/characters/hunter_cat

# 이름 변경
git mv greeting/ character_greeting_loop/
git mv selected/ character_selected/
git mv idle/ home_idle/

# 삭제 (통합 애니메이션에 포함됨)
git rm -r thinking/
git rm -r happy/
git rm -r confused/

# 신규 폴더 생성
mkdir personality_idle personality_selected
mkdir quiz_idle quiz_correct_flow quiz_wrong_flow
mkdir result_celebration
```

**최종 폴더 구조:**
```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json
│   ├── character_greeting_loop/
│   ├── character_selected/
│   ├── personality_idle/
│   ├── personality_selected/
│   ├── quiz_idle/
│   ├── quiz_correct_flow/
│   ├── quiz_wrong_flow/
│   ├── result_celebration/
│   ├── home_idle/
│   ├── home_studying/
│   ├── home_excited/
│   ├── home_sleepy/
│   └── home_celebration/
├── money_bear/ (동일)
├── save_sheep/ (동일)
└── chaser_fox/ (동일)
```

---

### 5. animation_config.json 재작성 (필수)
**파일:** `assets/animations/characters/*/animation_config.json`

**중요:** "정확히 XX프레임" → "약 X초" (유연한 타이밍 정책)

**예시:**
```json
{
  "characterGreetingLoop": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사 (약 5초)"
  },
  "personalitySelected": {
    "frameCount": 48,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "personalityIdle",
    "description": "성향 선택 반응 (약 2초)"
  },
  "quizCorrectFlow": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",
    "description": "정답 플로우 (약 4-6초): thinking → happy → idle"
  },
  "quizWrongFlow": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",
    "description": "오답 플로우 (약 4-6초): thinking → confused → idle"
  }
}
```

---

### 6. 화면별 State 사용 업데이트 (필수)

**파일 1:** `lib/screens/onboarding/character_preview_screen.dart`
```dart
// 변경 전
state: CharacterAnimationState.greeting

// 변경 후
state: CharacterAnimationState.characterGreetingLoop
```

**파일 2:** `lib/screens/onboarding/personality_test_screen.dart`
```dart
// 변경 전
state: CharacterAnimationState.thinking

// 변경 후 (대기 상태)
state: CharacterAnimationState.personalityIdle

// 선택 시
state: CharacterAnimationState.personalitySelected
// → 2초 후 자동으로 personalityIdle로 전환
```

**파일 3:** 학습 퀴즈 화면 (미구현, 추후 구현 시)
```dart
// 대기
state: CharacterAnimationState.quizIdle

// 정답 선택
state: CharacterAnimationState.quizCorrectFlow
// → 4-6초 후 자동으로 quizIdle로 전환

// 오답 선택
state: CharacterAnimationState.quizWrongFlow
// → 4-6초 후 자동으로 quizIdle로 전환
```

**파일 4:** `lib/services/character_animation_preloader.dart`
```dart
// 변경 전
CharacterAnimationState.greeting

// 변경 후
CharacterAnimationState.characterGreetingLoop
```

---

### 7. pubspec.yaml 업데이트 (필수)
**파일:** `pubspec.yaml`

**변경:** 40개 경로 → 52개 경로 (4캐릭터 × 13상태)

```yaml
flutter:
  assets:
    # hunter_cat (13개 상태)
    - assets/animations/characters/hunter_cat/character_greeting_loop/
    - assets/animations/characters/hunter_cat/character_selected/
    - assets/animations/characters/hunter_cat/personality_idle/
    - assets/animations/characters/hunter_cat/personality_selected/
    - assets/animations/characters/hunter_cat/quiz_idle/
    - assets/animations/characters/hunter_cat/quiz_correct_flow/
    - assets/animations/characters/hunter_cat/quiz_wrong_flow/
    - assets/animations/characters/hunter_cat/result_celebration/
    - assets/animations/characters/hunter_cat/home_idle/
    - assets/animations/characters/hunter_cat/home_studying/
    - assets/animations/characters/hunter_cat/home_excited/
    - assets/animations/characters/hunter_cat/home_sleepy/
    - assets/animations/characters/hunter_cat/home_celebration/
    # money_bear, save_sheep, chaser_fox도 동일하게 13개씩
```

---

### 8. 문서 업데이트 (필수)

**파일 목록:**
- [x] `docs/TODO.md` - 2025-12-24 작업 항목 추가 ✅
- [x] `docs/DEVELOPMENT_LOG.md` - 2025-12-24 섹션 추가 ✅
- [ ] `docs/FRAME_ANIMATION_GUIDE.md` - 13-state, 통합 애니메이션, 유연한 타이밍
- [ ] `docs/ANIMATION_UPDATE_2025-12-13.md` - 최종 스펙 업데이트
- [ ] `README.md` - 애니메이션 섹션 업데이트
- [ ] `assets/animations/characters/README.md` - 폴더 구조 업데이트

---

## 📊 13-State 시스템 상세

### State 체계 (카테고리별)

| 카테고리 | State | 설명 | 시간 | 프레임 | Loop | 자동전환 |
|---------|-------|------|------|--------|------|----------|
| **1. 캐릭터 선택** | `characterGreetingLoop` | 손 흔들며 인사 | 약 5초 | ~120 | ✅ | - |
| | `characterSelected` | 선택 반응 | 약 1-2초 | ~24-48 | ❌ | - |
| **2-A. 성향 퀴즈** | `personalityIdle` | 성향 문제 대기 | 약 3초 | ~72 | ✅ | - |
| | `personalitySelected` | 성향 선택 반응 | 약 2초 | ~48 | ❌ | `personalityIdle` |
| **2-B. 학습 퀴즈** | `quizIdle` | 학습 문제 대기 | 약 3초 | ~72 | ✅ | - |
| | `quizCorrectFlow` | 통합: thinking→happy→idle | 약 4-6초 | ~96-144 | ❌ | `quizIdle` |
| | `quizWrongFlow` | 통합: thinking→confused→idle | 약 4-6초 | ~96-144 | ❌ | `quizIdle` |
| **3. 결과 화면** | `resultCelebration` | 성향 결과 축하 | 약 3초 | ~72 | ❌ | - |
| **4. 홈 화면** | `homeIdle` | 기본 대기 | 약 5초 | ~120 | ✅ | - |
| | `homeStudying` | 책 읽기 | 약 3초 | ~72 | ✅ | - |
| | `homeExcited` | 활기찬 모습 | 약 2초 | ~48 | ✅ | - |
| | `homeSleepy` | 졸린 모습 | 약 3초 | ~72 | ✅ | - |
| | `homeCelebration` | 목표 달성 축하 | 약 2초 | ~48 | ❌ | `homeIdle` |

**합계:** 13개 상태

---

### 유연한 타이밍 정책

**Before (경직적):**
```
❌ quiz_correct_flow: 정확히 96프레임
   thinking(24프레임) + happy(48프레임) + idle복귀(24프레임)
```

**After (유연):**
```
✅ quiz_correct_flow: 약 4-6초
   구성: thinking → happy → idle 복귀
   실제 프레임 수: 제작 후 확정 (96~144 예상)
   JSON 설정: frameCount: [실제 프레임 수]
```

**이유:**
- Midjourney/Runway는 정확한 프레임 수 통제 불가
- "4초 목표"로 제작 → 실제 110프레임 나옴 → JSON에 110 기록 → 완벽 작동

---

### 화면별 State 매핑

**1️⃣ 캐릭터 선택 화면**
```
[🐻] [🐑] [🐱] [🦊]
  ↓    ↓    ↓    ↓
characterGreetingLoop (5초 무한 루프)

터치 →
characterSelected (1초 원샷) →
다음 화면
```

**2️⃣ 성향 퀴즈 화면**
```
┌─→ personalityIdle (3초 루프)
│
│   Q. 투자할 때 중요한 건?
│   ○ 안정성 ← 선택!
│
│   ↓
│   personalitySelected (2초)
│   ↓ 자동 전환
└───┘
```

**3️⃣ 학습/퀴즈 화면**
```
┌─→ quizIdle (3초 루프)
│
│   Q. 복리의 마법이란?
│   ○ 정답 ← 선택!
│
│   ↓
│   quizCorrectFlow (4-6초)
│   [thinking → happy → idle]
│   ↓ 자동 전환
└───┘
```

**4️⃣ 홈 화면**
```
┌─→ homeIdle (기본)
│
├─→ homeStudying (학습 시)
├─→ homeExcited (활기)
├─→ homeSleepy (휴식)
│
└─→ homeCelebration (달성)
    ↓ 자동 전환
    homeIdle
```

---

### 제작 물량

**총 52개 애니메이션:**
- Phase 1 (온보딩): 16개 (4상태 × 4캐릭터)
- Phase 2 (학습): 16개 (4상태 × 4캐릭터)
- Phase 3 (홈): 20개 (5상태 × 4캐릭터)

**총 용량:**
- PNG: ~192MB (캐릭터당 48MB)
- WebP: ~96MB (50% 절감)

---

## 📝 문서 작성 완료

- [x] TODO.md 업데이트 (작업 항목 명시)
- [x] DEVELOPMENT_LOG.md 업데이트 (2025-12-24 섹션)
- [ ] 다른 문서들 (다음 단계)

---

## 📅 2025-12-23 세션: 애니메이션 상태 체계 재설계

### 🎯 목표
애니메이션 상태 시스템 전면 개편 (5개 → 10개 상태)

---

## ✅ 완료된 작업

### 1. 기존 문제 발견
**문제점:**
- 기존 "idle"이 실제로는 "손 흔드는 greeting" 애니메이션
- 진짜 idle (조용한 대기) 상태가 없음
- 홈 화면용 다양한 상태 부족

### 2. CharacterAnimationState enum 확장
**파일:** `lib/models/character_animation_config.dart`

**변경:** 8개 → 14개 상태 (실제 사용 10개)

```dart
enum CharacterAnimationState {
  // 카테고리 1: 캐릭터 선택 화면 전용 (2개)
  greeting,  // 손 흔들며 인사 (구 idle, 125 frames)
  selected,  // 선택됨 반응

  // 카테고리 2: 범용 상태 (4개)
  idle,      // 진짜 조용한 대기 (120 frames, 5초 복합)
  thinking,  // 퀴즈 문제 표시
  happy,     // 정답/긍정 피드백
  confused,  // 오답/부정 피드백

  // 카테고리 3: 홈 화면 전용 (4개)
  homeStudying,     // 책 읽기 (60 frames)
  homeExcited,      // 활기찬 모습 (48 frames)
  homeSleepy,       // 졸린 모습 (72 frames)
  homeCelebration,  // 목표 달성 (36 frames)

  // 퀴즈 반응 (기존 호환성 유지)
  reactionPositive,
  reactionNegative,
  reactionNeutral,
}
```

**커밋:** `94c0a91` - "Redesign animation state system: 5 → 10 states"

---

### 3. 폴더 구조 변경
**작업:**
- ✅ `idle/` → `greeting/` 이름 변경 (4개 캐릭터 전체)
- ✅ 새로운 폴더 생성:
  - `idle/` (새로운 개념)
  - `home_studying/`
  - `home_excited/`
  - `home_sleepy/`
  - `home_celebration/`

**결과:**
```
assets/animations/characters/
├── hunter_cat/
│   ├── greeting/              (125 frames, 구 idle)
│   ├── selected/              (20 frames)
│   ├── idle/                  (120 frames, 신규)
│   ├── thinking/              (24 frames)
│   ├── happy/                 (30 frames)
│   ├── confused/              (20 frames)
│   ├── home_studying/         (60 frames, 신규)
│   ├── home_excited/          (48 frames, 신규)
│   ├── home_sleepy/           (72 frames, 신규)
│   └── home_celebration/      (36 frames, 신규)
```

---

### 4. Idle 애니메이션 개념 재정의
**기존:** 단순 숨쉬기 애니메이션
**신규:** 5초 복합 애니메이션 - 캐릭터 성향 표현

**헌터캣 예시 (5초 구성):**
- 0-2초: 조용한 숨쉬기 (날카로운 눈빛)
- 2-3초: 윙크 (사냥꾼 본능)
- 3-4초: 귀 쫑긋 (집중력)
- 4-5초: 편안한 복귀

**캐릭터별 차별화:**
- 🐱 헌터캣: 날카로움, 기민함 → 윙크, 귀 쫑긋
- 🐻 머니베어: 든든함, 신뢰 → 팔짱, 고개 끄덕임
- 🐑 세이브쉽: 부드러움, 조화 → 고개 기울임, 미소
- 🦊 체이서폭스: 영리함, 호기심 → 꼬리 흔들기, 장난기

**핵심:** 같은 "idle"이지만 각 캐릭터의 성향이 명확히 표현됨

---

### 5. character_frame_animation.dart 업데이트
**파일:** `lib/models/character_frame_animation.dart:67-171`

**추가된 상태 프리셋:**
```dart
// 카테고리 1: 캐릭터 선택 화면
case CharacterAnimationState.greeting:
  return CharacterFrameAnimation(
    frameCount: 125,  // 5.2초
    loop: true,
  );

// 카테고리 2: 범용 상태
case CharacterAnimationState.idle:
  return CharacterFrameAnimation(
    frameCount: 120,  // 5초 복합 애니메이션
    loop: true,
  );

// 카테고리 3: 홈 화면 전용
case CharacterAnimationState.homeStudying:
  return CharacterFrameAnimation(
    frameCount: 60,  // 2.5초
    loop: true,
  );
// ... (나머지 3개 상태)
```

---

### 6. 코드 사용처 업데이트
**수정된 파일:**
- `lib/screens/onboarding/character_preview_screen.dart:197`
  - `CharacterAnimationState.idle` → `CharacterAnimationState.greeting`

- `lib/screens/onboarding/personality_test_screen.dart:296`
  - `CharacterAnimationState.idle` → `CharacterAnimationState.thinking`
  - (더 적절한 상태로 변경)

- `lib/services/character_animation_preloader.dart:13-27`
  - `loadAllIdleStates()` → `CharacterAnimationState.greeting` 로드
  - 주석 업데이트: "Greeting 상태 로드 (캐릭터 선택 화면용)"

---

### 7. animation_config.json 업데이트
**파일:** 4개 캐릭터 모두 업데이트

**변경 사항:**
```json
{
  "greeting": {  // idle → greeting으로 이름 변경
    "frameCount": 125,
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사 (5.2초)"
  },
  "idle": {  // 새로운 idle 추가
    "frameCount": 120,
    "frameDuration": 42,
    "loop": true,
    "description": "조용한 대기 - 복합 애니메이션 (5초)"
  },
  "homeStudying": {  // 신규
    "frameCount": 60,
    "frameDuration": 42,
    "loop": true,
    "description": "책 읽기 (2.5초)"
  },
  // ... 나머지 홈 화면 상태 3개
}
```

---

### 8. pubspec.yaml 업데이트
**파일:** `pubspec.yaml:66-111`

**추가된 폴더 경로:**
```yaml
# 각 캐릭터마다 10개 폴더 추가
- assets/animations/characters/hunter_cat/greeting/
- assets/animations/characters/hunter_cat/idle/
- assets/animations/characters/hunter_cat/home_studying/
- assets/animations/characters/hunter_cat/home_excited/
- assets/animations/characters/hunter_cat/home_sleepy/
- assets/animations/characters/hunter_cat/home_celebration/
# ... (나머지 3개 캐릭터도 동일)
```

---

### 9. 문서 업데이트

#### FRAME_ANIMATION_GUIDE.md
**추가/수정 섹션:**
- ✅ 최종 스펙: 5개 → 10개 상태, 용량 12MB → 40MB
- ✅ "애니메이션 상태 체계 (2025-12-23 재설계)" 섹션 추가
  - 카테고리 1, 2, 3 상세 설명
  - Idle 애니메이션 개념 (5초 복합 구성)
  - 캐릭터별 차별화 전략
- ✅ Motion 지시 업데이트: 10개 상태 전체
- ✅ 폴더 구조 업데이트
- ✅ animation_config.json 예시 업데이트

#### assets/animations/characters/README.md
**추가/수정 섹션:**
- ✅ 폴더 구조: 10개 상태 표시
- ✅ "상태 체계 (2025-12-23 재설계)" 섹션 추가
- ✅ ffmpeg 명령어: greeting, idle 예시로 변경
- ✅ animation_config.json 예시 업데이트

---

## 📊 변경 요약

| 항목 | 이전 | 현재 |
|------|------|------|
| **상태 수** | 5개 | 10개 |
| **enum 크기** | 8개 | 14개 (퀴즈 반응 포함) |
| **총 애니메이션** | 20개 (4×5) | 40개 (4×10) |
| **총 프레임 수** | ~500개 | ~2,000개 |
| **총 용량 (PNG)** | ~12MB | ~40MB |

---

## 🎬 애니메이션 제작 현황

| 상태 | 헌터캣 | 머니베어 | 세이브쉽 | 체이서폭스 |
|------|--------|---------|---------|-----------|
| greeting | ✅ | ❌ | ❌ | ❌ |
| selected | ✅ | ❌ | ❌ | ❌ |
| **idle (신규)** | ❌ | ❌ | ❌ | ❌ |
| thinking | ❌ | ❌ | ❌ | ❌ |
| happy | ❌ | ❌ | ❌ | ❌ |
| confused | ❌ | ❌ | ❌ | ❌ |
| home_studying | ❌ | ❌ | ❌ | ❌ |
| home_excited | ❌ | ❌ | ❌ | ❌ |
| home_sleepy | ❌ | ❌ | ❌ | ❌ |
| home_celebration | ❌ | ❌ | ❌ | ❌ |

**총 제작 필요:** 39개 (헌터캣 greeting 1개만 완료)

---

## 🔧 기술적 결정

### Idle 개념 전환
**선택:** 단순 숨쉬기 → 5초 복합 애니메이션
**이유:**
- ✅ 캐릭터 성향 표현 강화
- ✅ 사용자 경험 향상 (지루함 방지)
- ✅ 브랜드 아이덴티티 강화

### 홈 화면 상태 4개 추가
**선택:** home_studying, home_excited, home_sleepy, home_celebration
**이유:**
- ✅ 홈 화면 다양성 확보
- ✅ 사용자 행동에 따른 피드백 가능
- ✅ 게이미피케이션 요소 강화

---

## 📝 수정된 파일 목록

### Models (2개)
- `lib/models/character_animation_config.dart` (enum 확장)
- `lib/models/character_frame_animation.dart` (상태 프리셋 추가)

### Screens (2개)
- `lib/screens/onboarding/character_preview_screen.dart` (idle → greeting)
- `lib/screens/onboarding/personality_test_screen.dart` (idle → thinking)

### Services (1개)
- `lib/services/character_animation_preloader.dart` (주석 업데이트)

### Assets (5개)
- `assets/animations/characters/hunter_cat/animation_config.json`
- `assets/animations/characters/money_bear/animation_config.json`
- `assets/animations/characters/save_sheep/animation_config.json`
- `assets/animations/characters/chaser_fox/animation_config.json`
- `pubspec.yaml` (폴더 경로 추가)

### Documentation (2개)
- `docs/FRAME_ANIMATION_GUIDE.md` (전면 개편)
- `assets/animations/characters/README.md` (전면 개편)

### Folders (20개)
- 4개 캐릭터 × 5개 신규 폴더 = 20개 폴더 생성/이름 변경

---

## 🔗 관련 커밋
- `94c0a91`: Redesign animation state system: 5 → 10 states

---

**작성일:** 2025-12-23
**다음 작업:** 디자인팀의 신규 애니메이션 제작 (39개)

---

## 📅 2025-12-19 세션: 프레임 애니메이션 버그 수정 및 PNG 지원

### 🎯 목표
실제 프레임 파일 테스트를 통한 버그 수정 및 안정화

---

## ✅ 완료된 작업

### 1. PNG 포맷 지원
**파일:** `lib/models/character_frame_animation.dart:28`

**문제:**
- 코드는 `.webp` 확장자로 하드코딩
- 실제 프레임 파일은 `.png` 형식
- 프레임 로드 실패로 placeholder만 표시됨

**수정:**
```dart
// Before
return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.webp';

// After
return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.png';
```

**커밋:** `6e30cfa` - "Support PNG format for animation frames"

---

### 2. 상태 전환 시 에러 방지
**파일:** `lib/widgets/animated_character.dart:117`

**문제:**
- idle → selected 상태 전환 시 `_hasFrames` 플래그가 리셋되지 않음
- selected 프레임 없으면 에러 발생

**수정:**
```dart
setState(() {
  _isLoading = true;
  _hasFrames = true; // 새로운 상태에서 다시 체크
});
```

**커밋:** `25238a0` - "Fix: Prevent errors during character state transitions"

---

### 3. Placeholder fallback 개선
**파일:** `lib/widgets/animated_character.dart:178`

**문제:**
- 프레임 없을 때도 계속 로드 시도
- 불필요한 에러 로그 발생

**수정:**
```dart
if (mounted && _hasFrames) {
  setState(() {
    _hasFrames = false;
  });
  _controller?.stop(); // 애니메이션 정지
}
```

**커밋:** `12e7fa4` - "Improve placeholder fallback for characters without frames"

---

### 4. AnimationController 크래시 수정 (치명적 버그)
**파일:** `lib/widgets/animated_character.dart:40-111`

**문제:**
```
SingleTickerProviderStateMixin can only be used as a TickerProvider once.
```
- `SingleTickerProviderStateMixin` 사용 시 상태 전환마다 새 Controller 생성 시도
- idle → selected 전환 시 앱 크래시

**수정:**
```dart
// 1. SingleTickerProviderStateMixin → TickerProviderStateMixin (40번 라인)
class _AnimatedCharacterState extends State<AnimatedCharacter>
    with TickerProviderStateMixin {

// 2. Controller 재사용 로직 추가 (70-103번 라인)
if (_controller == null) {
  _controller = AnimationController(...); // 최초 1회만 생성
} else {
  // Controller 재사용
  _controller!.stop();
  _controller!.duration = _animation!.totalDuration;
  _controller!.reset();
}

// 3. 애니메이션 시작
if (_animation!.loop) {
  _controller!.repeat(); // idle: 루프
} else {
  _controller!.forward(); // selected: one-shot
}
```

**커밋:** `66cd6dc` - "Fix animation state transitions with proper controller reuse"

---

### 5. Placeholder 깜빡임 제거
**파일:** `lib/widgets/animated_character.dart:147`

**문제:**
- 상태 전환 시(idle → selected) placeholder가 잠깐 보임
- `_isLoading` 체크로 인해 로딩 중 placeholder 표시됨

**수정:**
```dart
// Before
if (_isLoading)
  _buildPlaceholder() // 로딩 중 placeholder 표시
else if (_hasFrames)
  _buildFrameAnimation()

// After
if (_hasFrames && _animation != null)
  _buildFrameAnimation() // 로딩 중에도 계속 표시
else
  _buildPlaceholder()
```

**커밋:** `f931c17` - "Remove placeholder flickering during state transitions"

---

### 6. 온보딩 화면 캐릭터 크기 증가
**파일:**
- `lib/screens/onboarding/character_preview_screen.dart:199`
- `lib/screens/onboarding/personality_result_screen.dart:259`

**목적:**
- 온보딩 화면에서 캐릭터를 더 크게 표시 (1.8배)
- 애니메이션 시각적 임팩트 향상

**변경 사항:**
```dart
// 캐릭터 선택 화면
AnimatedCharacter(
  size: 180, // 100 → 180 (1.8배)
)

// 성향 결과 화면
AnimatedCharacter(
  size: 270, // 150 → 270 (1.8배)
)
```

**효과:**
- 캐릭터 선택 화면: 80% 크기 증가
- 성향 결과 화면: 80% 크기 증가
- 애니메이션 디테일 가시성 향상

**커밋:** `c874ef2` - "Increase character size in onboarding screens (1.8x)"

---

### 7. 캐릭터 선택 화면 오버플로우 수정
**파일:** `lib/screens/onboarding/character_preview_screen.dart`

**문제:**
- 캐릭터 크기 증가(180px)로 인한 레이아웃 오버플로우
- 헌터캣, 체이서폭스에서 "right overflowed by 29 pixels" 에러

**원인:**
```
캐릭터 크기: 180px × 2 = 360px
좌우 패딩: 40px × 2 = 80px
총 필요 너비: 440px (일반 모바일 화면 360~400px 초과)
```

**수정:**
```dart
// 패딩 및 간격 조정
padding: const EdgeInsets.symmetric(horizontal: 16), // 40 → 16
const SizedBox(height: 60), // 80 → 60 (상단)
const SizedBox(height: 24), // 40 → 24 (캐릭터 사이)
```

**효과:**
- 캐릭터 크기 180px 유지
- 오버플로우 에러 해결
- 48px 좌우 여백 절약

**커밋:** `eb14c64` - "Fix overflow issue in character selection screen"

---

### 8. 성향 테스트 화면 캐릭터 크기 증가
**파일:** `lib/screens/onboarding/personality_test_screen.dart:298`

**목적:**
- 성향 테스트 중 표시되는 캐릭터를 더 크게 표시
- 다른 온보딩 화면과 일관성 유지

**변경:**
```dart
AnimatedCharacter(
  size: 160, // 80 → 160 (2배)
)
```

**효과:**
- 성향 테스트 중 캐릭터 가시성 향상
- 온보딩 전체 캐릭터 크기 통일감

**커밋:** `8119b82` - "Increase character size in personality test screen"

---

### 9. 성향 테스트 화면 레이아웃 위치 조정
**파일:** `lib/screens/onboarding/personality_test_screen.dart`

**목적:**
- 캐릭터와 질문을 화면 상단으로 이동
- 전체 레이아웃 가시성 향상

**변경:**
```dart
const SizedBox(height: 40), // 120 → 40 (상단 여백)
const SizedBox(height: 32), // 60 → 32 (캐릭터-질문 간격)
const SizedBox(height: 24), // 32 → 24 (질문-선택지 간격)
```

**효과:**
- 총 116px 위로 이동
- 캐릭터와 질문이 더 잘 보임
- 선택지까지 한 화면에 노출

**커밋:** `322b5cf` - "Reduce top spacing in personality test screen"

---

## 🎬 테스트 결과

### 동작 확인
1. ✅ **Hunter cat idle** (125 프레임)
   - PNG 프레임 정상 로드
   - 24fps 루프 애니메이션 재생

2. ✅ **Hunter cat selected** (20 프레임)
   - 클릭 시 one-shot 애니메이션 재생
   - 완료 후 말풍선 표시

3. ✅ **다른 캐릭터들**
   - 프레임 없어도 placeholder 안전하게 표시
   - 에러 없이 클릭/선택 가능

### 수정된 파일
- `lib/models/character_frame_animation.dart` (PNG 지원)
- `lib/widgets/animated_character.dart` (Controller 재사용, 에러 방지)

---

## 📝 기술적 결정

### PNG vs WebP
**선택:** PNG 우선 지원
**이유:**
- ffmpeg PNG 추출이 더 간단
- 투명 배경 보장
- 추후 WebP 변환 가능 (스크립트 제공)

### Controller 재사용 패턴
**선택:** 하나의 Controller를 상태 간 재사용
**이유:**
- SingleTickerProvider 제약 회피
- 메모리 효율적
- 상태 전환 시 안정적

---

## 📅 2025-12-16 세션: JSON 기반 애니메이션 설정 시스템 구축

### 🎯 목표
프레임 수를 코드 수정 없이 JSON 파일로 관리할 수 있는 설정 시스템 구축

---

## ✅ 완료된 작업

### 1. 문제 인식
**상황:** 5초 영상(125프레임)을 루프하려면 코드 수정이 필요했음
```dart
// 하드코딩 방식
frameCount: 24,  // → 125로 변경하려면 코드 수정 필요
```

**해결책:** JSON 설정 파일 시스템 도입

---

### 2. AnimationConfigLoader 서비스 구현
**파일:** `lib/services/animation_config_loader.dart`

**핵심 기능:**
- JSON 파일 로드 및 캐싱
- 자동 fallback (JSON 없으면 하드코딩 값 사용)
- 여러 상태 동시 로딩 지원

```dart
class AnimationConfigLoader {
  static final Map<String, Map<String, dynamic>> _configCache = {};

  // JSON 로드
  static Future<Map<String, dynamic>> loadConfig(String characterId) async {
    final jsonString = await rootBundle.loadString(
      'assets/animations/characters/$characterId/animation_config.json',
    );
    return json.decode(jsonString);
  }

  // CharacterFrameAnimation 생성
  static Future<CharacterFrameAnimation> createAnimation(
    String characterId,
    CharacterAnimationState state,
  ) async {
    final config = await loadConfig(characterId);
    final stateConfig = config[state.name];

    return CharacterFrameAnimation(
      characterId: characterId,
      state: state,
      frameCount: stateConfig['frameCount'],
      frameDuration: Duration(milliseconds: stateConfig['frameDuration']),
      loop: stateConfig['loop'],
    );
  }
}
```

---

### 3. JSON 설정 파일 생성 (4개)
**파일 위치:**
- `assets/animations/characters/hunter_cat/animation_config.json`
- `assets/animations/characters/money_bear/animation_config.json`
- `assets/animations/characters/save_sheep/animation_config.json`
- `assets/animations/characters/chaser_fox/animation_config.json`

**JSON 구조:**
```json
{
  "idle": {
    "frameCount": 125,
    "frameDuration": 42,
    "loop": true,
    "description": "숨쉬기 루프 (5.2초)"
  },
  "selected": {
    "frameCount": 20,
    "frameDuration": 42,
    "loop": false,
    "description": "선택 반응 (0.8초)"
  }
}
```

**헌터캣만 특별 설정:**
- `idle`: 125프레임 (5.2초) - 5초 영상 대응
- 나머지 캐릭터: 24프레임 (기본값)

---

### 4. CharacterFrameAnimation 업데이트
**파일:** `lib/models/character_frame_animation.dart`

**추가된 메서드:**
```dart
/// JSON 기반 로딩 (권장)
static Future<CharacterFrameAnimation> forStateAsync(
  String characterId,
  CharacterAnimationState state,
) async {
  try {
    return await AnimationConfigLoader.createAnimation(characterId, state);
  } catch (e) {
    return forState(characterId, state);  // fallback
  }
}
```

---

### 5. AnimatedCharacter 위젯 업데이트
**파일:** `lib/widgets/animated_character.dart`

**변경 사항:**
- `_setupAnimation()` → `Future<void> _setupAnimation()` (async로 변경)
- `_isLoading` 상태 추가
- 로딩 중 Placeholder 표시
- JSON 로딩 실패 시 자동 fallback

```dart
Future<void> _setupAnimation() async {
  // JSON 기반 로딩 시도
  _animation = await CharacterFrameAnimation.forStateAsync(
    characterId,
    widget.state,
  );

  setState(() {
    _isLoading = false;
  });

  _controller = AnimationController(...);
  // ...
}
```

---

### 6. pubspec.yaml 업데이트
**추가된 asset:**
```yaml
assets:
  # JSON 설정 파일
  - assets/animations/characters/hunter_cat/animation_config.json
  - assets/animations/characters/money_bear/animation_config.json
  - assets/animations/characters/save_sheep/animation_config.json
  - assets/animations/characters/chaser_fox/animation_config.json
```

---

### 7. 문서 업데이트
**업데이트된 파일:**
- `docs/FRAME_ANIMATION_GUIDE.md` - Step 5 추가 (JSON 설정)
- `docs/ANIMATION_UPDATE_2025-12-13.md` - JSON 시스템 설명 추가
- `assets/animations/characters/README.md` - JSON 사용법 추가

---

## 🎯 사용 방법

### **디자이너용: 프레임 수 변경**

```bash
# 1. JSON 파일 열기
vim assets/animations/characters/hunter_cat/animation_config.json

# 2. frameCount 수정
{
  "idle": {
    "frameCount": 125,  # 24 → 125로 변경
    ...
  }
}

# 3. 앱 재실행 → 자동 적용 ✅
```

### **개발자용: 새 캐릭터 추가**

```bash
# 1. animation_config.json 생성
cp assets/animations/characters/hunter_cat/animation_config.json \
   assets/animations/characters/new_character/

# 2. pubspec.yaml에 등록
assets:
  - assets/animations/characters/new_character/animation_config.json

# 3. 끝! 자동 로딩됨
```

---

## 📊 장점

| 항목 | 이전 (하드코딩) | 현재 (JSON) |
|------|---------------|------------|
| **프레임 수 변경** | 코드 수정 + 재빌드 | JSON 수정만 |
| **캐릭터별 설정** | 모두 같은 값 | 독립적 설정 |
| **디자이너 작업** | 개발자 필요 | 직접 수정 가능 |
| **영상 길이 대응** | 코드 수정 필요 | 유연하게 대응 |

---

## 🔧 기술 결정 사항

### JSON vs 런타임 감지
**선택:** JSON 설정 파일
**이유:**
- ✅ 성능: 빌드 타임에 결정 (런타임 오버헤드 없음)
- ✅ 명확성: 설정이 파일로 명시됨
- ✅ 확장성: 나중에 다른 설정도 추가 가능
- ❌ 런타임 감지: Flutter에서 asset 파일 시스템 접근 불가

### 캐싱 전략
- 캐릭터별 설정을 메모리에 캐싱
- 앱 실행 중 JSON 파일 한 번만 로드
- 개발 중 `AnimationConfigLoader.clearCache()` 호출 가능

---

## 📦 신규 파일 목록

### Services
- `lib/services/animation_config_loader.dart` (JSON 로더)

### Assets
- `assets/animations/characters/hunter_cat/animation_config.json`
- `assets/animations/characters/money_bear/animation_config.json`
- `assets/animations/characters/save_sheep/animation_config.json`
- `assets/animations/characters/chaser_fox/animation_config.json`

---

## 🧪 테스트 방법

```bash
# 1. hunter_cat idle을 125프레임으로 설정 확인
cat assets/animations/characters/hunter_cat/animation_config.json | grep frameCount

# 2. 앱 실행
flutter run

# 3. 헌터캣 선택 → idle 애니메이션 확인
# → 5.2초 루프 재생됨 ✅
```

---

## 🔗 관련 커밋
- `4e2c67e`: Implement JSON-based animation configuration system

---

**작성일:** 2025-12-16
**다음 작업:** 디자인팀의 애니메이션 제작

---

## 📅 2025-12-13 세션: 프레임 기반 캐릭터 애니메이션 시스템 구현

### 🎯 목표
Rive 대신 Midjourney로 생성한 GIF에서 추출한 PNG 프레임 시퀀스를 사용하는 애니메이션 시스템 구축

---

## ✅ 완료된 작업

### 1. 애니메이션 전략 변경 결정
**목표:** Rive 애니메이션 대신 프레임 기반 애니메이션 적용

#### 변경 이유
- **빠른 프로토타이핑:** Midjourney로 애니메이션 샘플 즉시 생성 가능
- **디자인 유연성:** GIF/비디오 형태로 결과 확인 후 프레임 추출
- **제작 비용:** Rive 전문가 대기 없이 내부적으로 제작 가능
- **실험 용이성:** 다양한 fps (12/18/24) 쉽게 테스트 가능

#### 기술 스택
- **제작:** Midjourney Video
- **추출:** ffmpeg (GIF → PNG 프레임)
- **재생:** Flutter AnimationController + Image.asset
- **사양:** 300x300px, PNG, 12fps 기준

---

### 2. 캐릭터 이름 최신화
**파일:** `README.md`, `lib/screens/onboarding/welcome_screen.dart`

**변경 사항:**
```
세이빙덕 (Saving Duck) 🦆 → 체이서폭스 (Chaser Fox) 🦊
밸런스토끼 (Balance Bunny) 🐰 → 세이브쉽 (Save Sheep) 🐑
코인캣 (Coin Cat) 🐱 → 헌터캣 (Hunter Cat) 🐱
```

---

### 3. CharacterFrameAnimation 모델 구현
**파일:** `lib/models/character_frame_animation.dart`

**핵심 기능:**
```dart
class CharacterFrameAnimation {
  final String characterId;
  final CharacterAnimationState state;
  final int frameCount;
  final Duration frameDuration;
  final bool loop;

  // 프레임 경로 자동 생성
  String getFramePath(int frameIndex) {
    final stateFolder = state.name;
    final frameNumber = (frameIndex + 1).toString().padLeft(2, '0');
    return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.png';
  }

  // 프리셋 설정
  static CharacterFrameAnimation forState(
    String characterId,
    CharacterAnimationState state, {
    int? frameCountOverride,
  }) {
    switch (state) {
      case CharacterAnimationState.idle:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 12,
          frameDuration: const Duration(milliseconds: 83), // 12fps
          loop: true,
        );
      // ... 다른 상태들
    }
  }
}
```

**프리셋 설정:**
- `idle`: 12프레임, 83ms, 반복
- `selected`: 10프레임, 60ms, 1회
- `happy`: 15프레임, 66ms, 1회
- `thinking`: 10프레임, 100ms, 반복
- `confused`: 10프레임, 80ms, 1회

---

### 4. AnimatedCharacter 위젯 완전 재작성
**파일:** `lib/widgets/animated_character.dart`

**주요 구현:**
1. **AnimationController 기반 프레임 시퀀싱**
   ```dart
   _controller = AnimationController(
     duration: _animation.totalDuration,
     vsync: this,
   );

   _controller.addListener(() {
     final progress = _controller.value;
     final frameIndex = (progress * _animation.frameCount).floor();
     if (frameIndex != _currentFrame) {
       setState(() {
         _currentFrame = frameIndex.clamp(0, _animation.frameCount - 1);
       });
     }
   });
   ```

2. **자동 Fallback**
   ```dart
   Image.asset(
     _animation.getFramePath(_currentFrame),
     gaplessPlayback: true,
     errorBuilder: (context, error, stackTrace) {
       setState(() => _hasFrames = false);
       return _buildPlaceholder();
     },
   );
   ```

3. **상태 변경 처리**
   - `widget.state` 변경 시 자동으로 새 애니메이션 로드
   - 기존 controller dispose 후 새로 생성

4. **애니메이션 완료 콜백**
   ```dart
   if (_animation.loop) {
     _controller.repeat();
   } else {
     _controller.forward().then((_) {
       widget.onAnimationComplete?.call();
     });
   }
   ```

---

### 5. CharacterAnimationPreloader 서비스 구현
**파일:** `lib/services/character_animation_preloader.dart`

**Progressive Loading 전략:**
```dart
// 1단계: 모든 캐릭터 Idle 상태 (앱 시작 시)
static Future<void> loadAllIdleStates(BuildContext context) async {
  // 4 캐릭터 × 12프레임 = 48장 (~2MB)
  // 로딩 시간: 2-3초
}

// 2단계: 선택된 캐릭터의 나머지 상태 (캐릭터 선택 시)
static Future<void> loadCharacterAllStates(
  BuildContext context,
  String characterId,
) async {
  // selected, happy, thinking, confused = 45프레임 (~1.6MB)
}

// 3단계: 나머지 캐릭터들 (백그라운드)
static Future<void> loadRemainingCharacters(
  BuildContext context,
  String selectedCharacterId,
) async {
  // 나머지 3 캐릭터 × 4 상태 × 평균 11프레임 = ~4.5MB
}
```

**최적화 효과:**
- 초기 로딩: 2-3초 (Idle만)
- 선택 후: 1-2초 (해당 캐릭터 상태들)
- 전체 로딩: 백그라운드 진행

---

### 6. CharacterAnimationState enum 확장
**파일:** `lib/models/character_animation_config.dart`

**Before:**
```dart
enum CharacterAnimationState {
  idle,
  selected,
}
```

**After:**
```dart
enum CharacterAnimationState {
  idle,      // 숨쉬기 (대기)
  selected,  // 선택 반응
  happy,     // 기쁨 (학습 완료)
  thinking,  // 생각하는 모습 (퀴즈)
  confused,  // 혼란 (오답)
}
```

---

### 7. 폴더 구조 및 Asset 등록
**폴더 구조 생성:**
```
assets/animations/characters/
├── hunter_cat/
│   ├── idle/.gitkeep
│   ├── selected/.gitkeep
│   ├── happy/.gitkeep
│   ├── thinking/.gitkeep
│   └── confused/.gitkeep
├── money_bear/
├── save_sheep/
└── chaser_fox/
```

**pubspec.yaml 업데이트:**
```yaml
assets:
  - assets/animations/characters/hunter_cat/idle/
  - assets/animations/characters/hunter_cat/selected/
  - assets/animations/characters/hunter_cat/happy/
  - assets/animations/characters/hunter_cat/thinking/
  - assets/animations/characters/hunter_cat/confused/
  # ... (총 20개 경로 - 4 캐릭터 × 5 상태)
```

---

### 8. 종합 문서 작성

**1. `docs/FRAME_ANIMATION_GUIDE.md`**
- 전체 워크플로우 가이드
- Midjourney 프롬프트 예시
- ffmpeg 추출 명령어
- 파일 배치 방법
- 테스트 가이드
- FAQ

**2. `docs/ANIMATION_UPDATE_2025-12-13.md`**
- 전략 변경 요약
- 결정 배경
- 기술 사양
- 완료된 작업
- 다음 단계 (디자인팀)

**3. `assets/animations/characters/README.md`**
- 디자이너를 위한 빠른 참조 가이드
- 파일 명명 규칙
- ffmpeg 명령어

---

### 9. 버그 수정 및 개선

**1. AnimatedCharacter 파라미터 일관성**
- 기존: `character` 파라미터 사용
- 수정: `characterType`으로 통일
- 영향받은 파일:
  - `lib/screens/onboarding/character_preview_screen.dart`
  - `lib/screens/onboarding/personality_result_screen.dart`
  - `lib/screens/onboarding/personality_test_screen.dart`

---

## 📊 업데이트된 문서
- ✅ `docs/FRAME_ANIMATION_GUIDE.md` (신규)
- ✅ `docs/ANIMATION_UPDATE_2025-12-13.md` (신규)
- ✅ `assets/animations/characters/README.md` (신규)
- ✅ `docs/TODO.md` (Rive → 프레임 기반 애니메이션 섹션 교체)
- ✅ `README.md` (캐릭터 이름 업데이트)

---

## 🎯 다음 우선순위 (디자인팀)

### 애니메이션 제작 작업
1. **Midjourney로 애니메이션 생성**
   - 각 캐릭터별 5가지 상태 비디오/GIF 생성
   - 참고: `docs/FRAME_ANIMATION_GUIDE.md`의 프롬프트

2. **ffmpeg로 프레임 추출**
   ```bash
   ffmpeg -i input.gif -vf "fps=12,scale=300:300" frame_%02d.png
   ```

3. **파일 배치**
   - `assets/animations/characters/[캐릭터ID]/[상태]/frame_01.png` 형식
   - 예: `assets/animations/characters/money_bear/idle/frame_01.png`

4. **테스트**
   - `flutter pub get` 실행
   - 앱에서 해당 캐릭터/상태 확인
   - 부드러움 확인 후 fps 조정 (12 → 18 → 24 테스트)

---

## 📦 신규 파일 목록

### Models
- `lib/models/character_frame_animation.dart`

### Services
- `lib/services/character_animation_preloader.dart`

### Widgets
- `lib/widgets/animated_character.dart` (완전 재작성)

### Documentation
- `docs/FRAME_ANIMATION_GUIDE.md`
- `docs/ANIMATION_UPDATE_2025-12-13.md`
- `assets/animations/characters/README.md`

### Assets
- 폴더 구조 생성 (20개 폴더 with .gitkeep)

---

## 🔧 기술 결정 사항

### 프레임 레이트
- **기본:** 12fps (1초당 12프레임)
- **이유:** 부드러움과 용량의 균형
- **유연성:** 동일한 GIF에서 다른 fps로 추출 가능

### 파일 포맷
- **PNG:** 투명 배경 지원, 무손실
- **해상도:** 300x300px (Flutter에서 크기 조정)

### Loading 전략
- **Progressive:** 필요한 것부터 순차 로딩
- **Preloading:** `precacheImage`로 미리 로드
- **Fallback:** 프레임 없을 시 Placeholder

---

## 🧪 테스트 가이드

### 디자이너용 테스트 방법
1. 프레임 파일을 해당 폴더에 배치
2. 터미널에서 `flutter pub get` 실행
3. 앱 실행 (Hot Reload 가능)
4. 온보딩 화면에서 해당 캐릭터 선택
5. 애니메이션 확인:
   - 부드러움
   - 반복 여부
   - 전환 자연스러움

### 프레임 없을 때
- 자동으로 Placeholder (이모지 원형) 표시
- 에러 없이 정상 동작

---

## 📊 성능 지표

### 파일 용량
- 프레임당: ~40KB (PNG, 300x300px)
- Idle (12프레임): ~480KB × 4캐릭터 = ~2MB
- 전체 (57프레임 × 4): ~8MB

### 로딩 시간
- 1단계 (Idle): 2-3초
- 2단계 (선택 캐릭터): 1-2초
- 3단계 (나머지): 백그라운드

### 메모리
- 로드된 프레임: 메모리에 캐시
- Flutter Image cache 사용

---

## 🔗 관련 문서
- [FRAME_ANIMATION_GUIDE.md](./FRAME_ANIMATION_GUIDE.md) - 완전한 워크플로우 가이드
- [ANIMATION_UPDATE_2025-12-13.md](./ANIMATION_UPDATE_2025-12-13.md) - 전략 변경 요약
- [TODO.md](./TODO.md) - 업데이트된 작업 목록

---

**작성일:** 2025-12-13
**다음 작업:** 디자인팀의 Midjourney 애니메이션 제작

---

## 📅 2024-12-08 세션: 학습 완료 UI 및 복습 모드 구현

### 🎯 목표
학습 완료 후 사용자 경험 개선 및 복습 기능 구현

---

## ✅ 완료된 작업

### 1. 학습 완료 UI 구현 (방안 1 + 3 혼합)
**목표:** 오늘 학습 완료 시 명확한 피드백과 복습 유도

#### 구현 내용
**HomeScreen (`lib/screens/home/home_screen.dart`)**
- `hasLearnedToday = true` 상태에 따른 UI 분기 추가
- 학습 완료 시 새로운 카드 UI:
  - 🎉 완료 축하 메시지
  - 내일 학습 예고 (Day X로 함께해요)
  - [복습하기] 버튼 (Primary, 초록색)
  - [이전 학습 보기] 버튼 (Secondary, 학습 탭으로 이동)

#### 설계 원칙
- **1일 1학습 원칙 유지**: 하루에 하나의 Day만 정식 학습
- **복습 유도**: 학습 강화 목적의 복습 기능 제공
- **명확한 피드백**: 완료 상태를 시각적으로 명확하게 전달

---

### 2. 복습 모드 (Review Mode) 구현
**목표:** 완료한 Day를 복습할 수 있는 기능, 포인트 없이 학습 강화 목적

#### 구현된 파일
1. **LearningScreen** (`lib/screens/learning/learning_screen.dart`)
   - `isReview` 플래그 추가 (기본값: false)
   - 복습 모드 시 헤더에 "복습" 배지 표시 (주황색)
   - 캐릭터 메시지 변경 ("다시 복습해봐요! 📖")
   - 복습 모드일 때 `completeLearning` 스킵

2. **QuizScreen** (`lib/screens/learning/quiz_screen.dart`)
   - `isReview` 플래그 추가 및 전달
   - 복습 모드일 때 포인트 획득 스킵
   - QuizResultScreen에 `isReview` 플래그 전달

3. **QuizResultScreen** (`lib/screens/learning/quiz_result_screen.dart`)
   - `isReview` 플래그 추가
   - 복습 모드 시 "Day X 복습 완료" 배지 (주황색)
   - "획득 포인트" 대신 "복습 모드 - 포인트 없음" 카드 표시

#### 복습 모드 특징
- ✅ 이미 완료한 Day를 언제든 복습 가능
- ✅ 포인트/스트릭 증가 없음 (1일 1학습 원칙 유지)
- ✅ 시각적 구분 (주황색 배지, 다른 메시지)
- ✅ 학습 강화 목적 (README 기획서 "복습 시 포인트 미지급" 반영)

---

### 3. 버그 수정 및 네비게이션 개선
**수정된 버그:**
1. ✅ 성향 확인 완료 페이지 X 버튼 제거 (검은 화면 문제)
2. ✅ 퀴즈 결과 '홈으로' 버튼 → MainScreen 이동 (placeholder 제거)
3. ✅ MainNavigationScreen (placeholder) 삭제
4. ✅ MainScreen 백버튼 비활성화 (PopScope)
5. ✅ HomeScreen AppBar 백버튼 제거 (automaticallyImplyLeading: false)

---

## 📊 업데이트된 문서
- ✅ README.md: 주요 기능에 복습 설명 추가
- ✅ README.md: "7. 학습 완료 후 플로우" 섹션 추가
- ✅ README.md: 메인 기능 체크리스트 업데이트 (복습 모드 완료 표시)

---

## 🎯 다음 우선순위
1. **Firestore 콘텐츠 시스템 구현** (P0)
2. **UserProvider ↔ Firebase UID 연동** (P0)
3. **실제 학습 콘텐츠 작성** (Day 1-30, 외부 전문가)
4. **Rive 애니메이션 제작 및 통합** (외부 전문가)

---

## 📅 2025-11-27 세션: Firebase Authentication 구현

### 🎯 목표
Google Sign-In 및 이메일/비밀번호 인증 구현, Android 테스트 완료

---

## ✅ 완료된 작업

### 1. Firebase 패키지 업그레이드 (GoogleUtilities 충돌 해결)
**목표:** iOS CocoaPods GoogleUtilities 8.x 버전 충돌 해결

#### 문제 상황
```
CocoaPods could not find compatible versions for pod "GoogleUtilities/Logger":
- FirebaseCore (~> 2.x) requires GoogleUtilities (~> 7.12)
- GoogleSignIn (8.0) requires GoogleUtilities (= 8.0.0)
```

#### 해결 방법
Firebase 패키지를 최신 버전으로 업그레이드하여 GoogleUtilities 8.x 지원

**업그레이드된 패키지:**
```yaml
# Before
firebase_core: ^2.27.0
cloud_firestore: ^4.15.8
firebase_auth: ^4.17.8
firebase_storage: ^11.6.9
firebase_analytics: ^10.8.9

# After
firebase_core: ^3.6.0
cloud_firestore: ^5.4.4
firebase_auth: ^5.3.1
firebase_storage: ^12.3.4
firebase_analytics: ^11.3.3
google_sign_in: ^6.2.1
```

#### 결과
- ✅ iOS CocoaPods 설치 성공 (40개 pod 설치)
- ✅ GoogleUtilities 8.0.0으로 통일
- ✅ 빌드 에러 해결

---

### 2. AuthService 구현
**파일:** `lib/services/auth_service.dart`

**기능:**
- Google Sign-In 연동
- 이메일/비밀번호 회원가입/로그인
- 로그아웃
- 한국어 에러 메시지

**주요 메서드:**
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 사용자
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일 회원가입
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async { ... }

  // 이메일 로그인
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async { ... }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
```

**한국어 에러 메시지 (14종):**
- `weak-password`: "비밀번호가 너무 약해요. 6자 이상 입력해주세요."
- `email-already-in-use`: "이미 사용 중인 이메일이에요."
- `user-not-found`: "존재하지 않는 계정이에요."
- `wrong-password`: "비밀번호가 틀렸어요."
- `invalid-email`: "올바른 이메일 형식이 아니에요."
- `user-disabled`: "비활성화된 계정이에요."
- `too-many-requests`: "너무 많은 시도를 했어요. 잠시 후 다시 시도해주세요."
- `operation-not-allowed`: "이 로그인 방법은 현재 사용할 수 없어요."
- `account-exists-with-different-credential`: "다른 로그인 방법으로 이미 가입된 이메일이에요."
- `invalid-credential`: "인증 정보가 올바르지 않아요."
- `network-request-failed`: "네트워크 연결을 확인해주세요."
- 기타: "로그인 중 오류가 발생했어요. 다시 시도해주세요."

---

### 3. LoginScreen에 AuthService 통합
**파일:** `lib/screens/auth/login_screen.dart`

**변경 사항:**
- Google Sign-In 버튼 활성화
- AuthService 연동
- 에러 처리 및 로딩 상태 UI

**Before:**
```dart
void _handleGoogleSignIn() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Google 로그인은 Firebase 설정 후 사용 가능해요')),
  );
}
```

**After:**
```dart
Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  try {
    final authService = AuthService();
    final credential = await authService.signInWithGoogle();

    if (credential == null) {
      // 사용자가 취소함
      setState(() => _isLoading = false);
      return;
    }

    // 로그인 성공 → 홈 화면 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Color(0xFFF56565),
      ),
    );
    setState(() => _isLoading = false);
  }
}
```

**이메일 로그인/회원가입도 동일하게 구현:**
```dart
Future<void> _handleEmailAuth() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final authService = AuthService();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLoginMode) {
      await authService.signInWithEmail(
        email: email,
        password: password,
      );
    } else {
      final credential = await authService.signUpWithEmail(
        email: email,
        password: password,
      );

      // TODO: Firestore에 사용자 프로필 생성
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Color(0xFFF56565),
      ),
    );
    setState(() => _isLoading = false);
  }
}
```

---

### 4. Android SHA-1 지문 추가
**문제:** Google Sign-In이 Android에서 작동하지 않음

**해결:**
1. Java 설치 (OpenJDK 17, Homebrew)
2. SHA-1 지문 생성:
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Firebase Console → Project Settings → Android app → SHA certificate fingerprints에 추가

**결과:**
- ✅ Android에서 Google Sign-In 정상 작동 확인

---

### 5. iOS 설정
**자동 완료:** FlutterFire CLI로 이미 설정됨
- `ios/Runner/GoogleService-Info.plist` 존재
- URL Schemes 자동 설정
- 추가 작업 불필요

---

## 📅 2025-01-15 세션: 온보딩 플로우 리팩토링

### 🎯 목표
캐릭터 중심 온보딩 플로우로 변경 및 게이미피케이션 강화

---

## ✅ 완료된 작업

### 1. 온보딩 플로우 재설계
**목표:** 캐릭터를 먼저 선택하고, 그 캐릭터와 함께 성향을 찾아가는 여정

#### Before (이전 플로우)
```
스플래시 → 앱 소개 → 성향 퀴즈 → 성향 결과 → 캐릭터 선택 → 이름 설정 → 목표 설정 → 완료
```

#### After (새로운 플로우)
```
스플래시 → 앱 소개 → 캐릭터 선택 → 성향 퀴즈 → 성향 결과 → 이름 설정 → 목표 설정 → 완료
```

**변경 이유:**
- 처음부터 캐릭터와 유대감 형성
- 캐릭터가 성향 찾기의 동반자 역할
- 게이미피케이션 요소 강화

#### 구현 파일
- `lib/screens/onboarding/character_preview_screen.dart` - 캐릭터 선택 우선
- `lib/screens/onboarding/personality_test_screen.dart` - 선택한 캐릭터 표시
- `lib/screens/onboarding/personality_result_screen.dart` - 캐릭터 대사 추가

---

### 2. CharacterProvider 생성
**파일:** `lib/providers/character_provider.dart`

**기능:**
- `selectedCharacter`: 사용자가 처음 선택한 캐릭터
- `finalPersonality`: 성향 퀴즈 결과
- `isCharacterMatchingPersonality`: 캐릭터와 성향 일치 여부

**사용 예시:**
```dart
// 캐릭터 선택 (character_preview_screen.dart)
context.read<CharacterProvider>().selectCharacter(PersonalityType.safe);

// 성향 결과 저장 (personality_result_screen.dart)
context.read<CharacterProvider>().setPersonalityResult(PersonalityType.safe);

// 일치 여부 확인
final isMatch = context.read<CharacterProvider>().isCharacterMatchingPersonality;
```

---

### 3. AnimatedCharacter 위젯 (Placeholder)
**파일:** `lib/widgets/animated_character.dart`

**현재 구현:**
- 숨쉬기 애니메이션 (scale pulse)
- 선택 효과 (확대 + 그림자)
- 이모지 표시 (🐻🐑🐱🦊)
- SpeechBubble 통합

**Rive 대비 구조:**
```dart
Widget _buildCharacterPlaceholder(bool isSelected) {
  // TODO: 추후 Rive 애니메이션으로 교체
  // return RiveAnimation.asset(
  //   'assets/animations/characters/${widget.character.name}_complete.riv',
  //   stateMachines: ['StateMachine'],
  // );

  return AnimatedBuilder(...);  // 현재 Placeholder
}
```

---

### 4. SpeechBubble 위젯
**파일:** `lib/widgets/speech_bubble.dart`

**기능:**
- 슬라이드 업 애니메이션
- CustomPainter로 말풍선 꼬리 그리기
- 그림자 효과

---

### 5. 캐릭터별 대사 시스템
**파일:** `lib/models/character_animation_config.dart`, `lib/utils/constants.dart`

**대사 종류:**
```dart
CharacterAnimationConfig {
  introDialogue: "안전하게 함께 시작해요! 🐻",          // 프리뷰 화면
  quizGreeting: "함께 성향을 알아볼까요?",             // 퀴즈 화면
  quizReactions: {                                    // 답변별 반응 (미사용)
    'positive': "좋은 선택이에요!",
    'negative': "음... 그렇군요!",
    'neutral': "흥미로운 답변이네요!",
  },
  resultDialogueMatch: "우리 딱 맞는 것 같아요!",      // 결과 일치
  resultDialogueDifferent: "이런 성향도 좋아요!",      // 결과 불일치
}
```

---

### 6. 성향 중심 UI 개선
**변경 사항:**
- ❌ 캐릭터 이름 제거 (예: "Money Bear 머니베어")
- ✅ 성향 이름 강조 (예: "안전형")
- ✅ 캐릭터는 시각적 요소로만 활용

**수정 파일:**
- `personality_result_screen.dart` - 캐릭터 이름 제거
- 다른 성향 살펴보기 - 성향 중심으로 변경
- 성향 변경 확인 다이얼로그 - 성향 이름으로 변경

---

### 7. 이름 설정 UX 개선
**파일:** `lib/screens/onboarding/name_setting_screen.dart`

**변경 사항:**
- ✅ 선택한 캐릭터 기준 디폴트 이름
- ✅ Placeholder로 디폴트 이름 표시 (반투명)
- ✅ 다음 버튼 항상 활성화
- ✅ 입력 안 하면 디폴트 이름 자동 사용

**Before:**
```dart
TextField(
  controller: _nameController..text = "머니베어",  // 직접 입력
);
ElevatedButton(
  onPressed: _isNameValid ? _onNext : null,  // 조건부 활성화
);
```

**After:**
```dart
TextField(
  controller: _nameController,  // 비어있음
  decoration: InputDecoration(
    hintText: "머니베어",  // Placeholder
  ),
);
ElevatedButton(
  onPressed: _onNext,  // 항상 활성화
);
```

---

### 8. 스크롤 바운스 효과 제거
**파일:** `lib/app.dart`

**문제:** 개별 화면에 ClampingScrollPhysics를 적용했지만 여전히 바운스 발생

**해결:** MaterialApp에 전역 ScrollBehavior 추가
```dart
MaterialApp(
  scrollBehavior: const _NoOverscrollBehavior(),
  ...
)

class _NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(...) {
    return child;  // glow effect 제거
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();  // 바운스 제거
  }
}
```

---

### 9. 사용자 데이터 영속성 수정
**파일:** `lib/providers/user_provider.dart`

**문제:** 온보딩 완료 후 홈 화면에서 로딩 인디케이터만 표시

**원인:**
```dart
// Before
Future<void> loadUser() async {
  _user = null;  // 😱 온보딩에서 저장한 데이터 날아감!
}
```

**해결:**
```dart
// After
Future<void> loadUser() async {
  if (_user != null) {
    return;  // 이미 메모리에 있으면 유지
  }
  // TODO: SharedPreferences에서 로드
}
```

---

## 📝 TODO 항목

### 우선순위 높음

#### 1. Rive 애니메이션 통합 🎨
**위치:** `lib/widgets/animated_character.dart`

**작업 내용:**
- [ ] 캐릭터별 .riv 파일 제작
- [ ] State Machine 구성
  - idle: 숨쉬기 루프
  - selected: 하이라이트 + 확대
  - reaction_positive/negative/neutral: 반응 애니메이션
- [ ] RiveAnimation.asset() 통합
- [ ] Fallback 로직 유지 (애니메이션 없을 때 placeholder)

**참고 문서:** `/docs/ANIMATION_GUIDE.md` (작성 필요)

#### 2. 성향 퀴즈 캐릭터 반응 ✨
**위치:** `lib/screens/onboarding/personality_test_screen.dart`

**작업 내용:**
- [ ] 답변 선택 시 캐릭터 반응 애니메이션 재생
- [ ] quizReactions 대사 표시
- [ ] 2초 대기 후 다음 질문

```dart
void _onAnswerSelected(AnswerOption answer) {
  // 1. 캐릭터 반응 애니메이션
  _showCharacterReaction(answer.type);

  // 2. 2초 대기
  Future.delayed(Duration(seconds: 2), () {
    setState(() => _currentQuestionIndex++);
  });
}
```

#### 3. 캐릭터 프리뷰 인트로 시퀀스 🎬
**위치:** `lib/screens/onboarding/character_preview_screen.dart`

**작업 내용:**
- [ ] 잔디밭 배경 페이드인 (1초)
- [ ] 구름 등장 + 4개 그림자 떨어짐 (2초)
- [ ] 그림자 → 캐릭터 변신 효과 (1초)
- [ ] Idle 상태 전환

---

### 우선순위 중간

#### 4. 학습 콘텐츠 데이터 📚
**현재 상태:** 더미 데이터

**작업 내용:**
- [ ] Day 1-10 학습 콘텐츠 작성 (성향별)
- [ ] 퀴즈 문제 은행 작성
- [ ] JSON 또는 Firebase에 저장
- [ ] 콘텐츠 로딩 로직 구현

**데이터 구조:**
```dart
{
  "day": 1,
  "personalityType": "safe",
  "title": "예적금의 기본",
  "cards": [
    {
      "order": 1,
      "type": "text",
      "content": "예금과 적금의 차이는..."
    }
  ],
  "estimatedMinutes": 3
}
```

#### 5. SharedPreferences 구현 💾
**파일:**
- `lib/providers/user_provider.dart`
- `lib/providers/learning_provider.dart`

**작업 내용:**
- [ ] SharedPreferences 패키지 추가
- [ ] User 모델 toJson/fromJson
- [ ] _saveToStorage() 구현
- [ ] loadUser() 구현
- [ ] 앱 재시작 시 자동 로그인

```dart
Future<void> _saveToStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', jsonEncode(_user!.toJson()));
}

Future<void> loadUser() async {
  if (_user != null) return;

  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  if (userJson != null) {
    _user = UserModel.fromJson(jsonDecode(userJson));
    notifyListeners();
  }
}
```

---

### 우선순위 낮음

#### 6. Firebase 연동 🔥
**작업 내용:**
- [ ] Firebase 프로젝트 생성
- [ ] FlutterFire 패키지 추가
- [ ] Firebase Auth 설정
- [ ] Firestore 컬렉션 설계
- [ ] User CRUD 구현
- [ ] Content 로딩 구현

**참고 문서:** `/docs/BACKOFFICE_DESIGN.md`

#### 7. 백오피스 웹 개발 🖥️
**기술 스택:** React/Vue/Svelte + Firebase Admin SDK

**작업 내용:**
- [ ] 관리자 인증
- [ ] 사용자 관리 페이지
- [ ] 콘텐츠 관리 페이지 (WYSIWYG 에디터)
- [ ] 퀴즈 관리 페이지
- [ ] 통계 대시보드

**참고 문서:** `/docs/BACKOFFICE_DESIGN.md`

#### 8. 캐릭터 변경 시스템 🔄
**방법 1:** 계정 재가입
- [ ] 로그아웃 시 캐릭터 재선택 가능

**방법 2:** 아이템 사용
- [ ] 캐릭터 변경 아이템 구매
- [ ] 포인트 또는 결제

**방법 3:** 다중 캐릭터 육성
- [ ] 여러 캐릭터 수집
- [ ] 캐릭터별 성장 시스템

📝 **추후 기획 필요**

#### 9. 앱 라우터 구현 🧭
**파일:** `lib/routes/app_router.dart`

**작업 내용:**
- [ ] go_router 패키지 추가
- [ ] 라우트 정의
- [ ] 딥링크 설정
- [ ] 권한 가드 (온보딩 완료 여부)

#### 10. 푸시 알림 📱
**작업 내용:**
- [ ] Firebase Cloud Messaging 설정
- [ ] 학습 리마인더
- [ ] 연속 학습 격려
- [ ] 새로운 콘텐츠 알림

---

## 🐛 알려진 이슈

### 해결됨 ✅
- ~~스크롤 바운스 애니메이션 남아있음~~ → 전역 ScrollBehavior로 해결
- ~~홈 화면 로딩 인디케이터만 표시~~ → UserProvider.loadUser() 수정

### 미해결 ⚠️
- 없음

---

## 📦 프로젝트 구조

```
lib/
├── main.dart
├── app.dart                              ✅ 전역 ScrollBehavior 추가
├── models/
│   ├── user_model.dart
│   ├── learning_day.dart
│   └── character_animation_config.dart   ✅ 신규
├── providers/
│   ├── user_provider.dart                ✅ loadUser() 수정
│   ├── learning_provider.dart
│   └── character_provider.dart           ✅ 신규
├── screens/
│   ├── onboarding/
│   │   ├── splash_screen.dart
│   │   ├── app_intro_screen.dart
│   │   ├── character_preview_screen.dart ✅ 리팩토링
│   │   ├── personality_test_screen.dart  ✅ 캐릭터 통합
│   │   ├── personality_result_screen.dart✅ 성향 중심
│   │   ├── name_setting_screen.dart      ✅ UX 개선
│   │   ├── goal_setting_screen.dart
│   │   └── first_learning_intro_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── learning/
│   │   ├── learning_tab_screen.dart
│   │   ├── learning_screen.dart
│   │   ├── quiz_screen.dart
│   │   └── quiz_result_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   └── main/
│       └── main_screen.dart
├── widgets/
│   ├── animated_character.dart           ✅ 신규 (Placeholder)
│   └── speech_bubble.dart                ✅ 신규
└── utils/
    ├── constants.dart                    ✅ animationConfig 추가
    └── theme.dart

docs/
├── BACKOFFICE_DESIGN.md                  ✅ 신규
└── DEVELOPMENT_LOG.md                    ✅ 신규 (이 파일)
```

---

## 🎨 디자인 가이드

### 색상 팔레트
```dart
// 메인 컬러
primary: #9F7AEA (보라)
primaryLight: #D6BCFA
primaryPale: #F3E8FF

// 성향별 컬러
safe: #718096 (회색) 🐻
balanced: #B794F6 (보라) 🐑
aggressive: #9F7AEA (보라) 🐱
challenger: #4A5568 (진한 회색) 🦊
```

### 타이포그래피
- Display Large: 32sp, Bold
- Headline Medium: 24sp, Bold
- Body Large: 16sp, Regular
- Body Small: 14sp, Regular

### 구어체 가이드
**나쁜 예:**
- "이름이 변경되었습니다"
- "로그아웃 하시겠습니까?"

**좋은 예:**
- "이름이 변경되었어요"
- "정말 로그아웃하시겠어요?"

---

## 🔧 개발 환경

### Flutter 버전
```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
```

### 주요 패키지
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  # TODO: 추가 필요
  # shared_preferences: ^2.2.2
  # firebase_core: ^2.24.0
  # firebase_auth: ^4.15.0
  # cloud_firestore: ^4.13.0
  # rive: ^0.12.0
```

---

## 🧪 테스트 체크리스트

### 온보딩 플로우
- [ ] 스플래시 → 앱 소개 전환
- [ ] 캐릭터 선택 시 하이라이트 + 말풍선
- [ ] "같이 시작하기" 버튼 슬라이드 업
- [ ] 성향 퀴즈에서 선택한 캐릭터 표시
- [ ] 성향 결과에서 캐릭터 대사 표시
- [ ] 이름 설정 Placeholder 동작
- [ ] 이름 입력 안 하고 다음 → 디폴트 이름 사용
- [ ] 목표 설정 완료 → 홈 화면 이동

### 메인 기능
- [ ] 홈 화면에 사용자 정보 표시
- [ ] 학습 탭에서 Day 목록 표시
- [ ] 설정에서 이름/성향/목표 변경

### 스크롤
- [ ] 모든 화면에서 스크롤 바운스 없음
- [ ] 오버스크롤 glow 효과 없음

---

## 📊 통계

### 코드 라인
- 총 파일: ~22개
- 총 코드: ~4,500줄
- 신규 추가: ~800줄

### Git 커밋
```
c6da779 - Remove scroll bounce/overscroll effects globally
96b366e - Refactor onboarding to focus on personality over character names
a3e822d - Update personality test and result screens with character dialogue
f0efa57 - Add character selection flow to onboarding
4d0c07c - Add character animation config model for new onboarding flow
```

---

## 🚀 배포 준비사항

### iOS
- [ ] Bundle Identifier 설정
- [ ] App Icon 제작
- [ ] Launch Screen 제작
- [ ] Apple Developer 등록

### Android
- [ ] Package Name 설정
- [ ] App Icon 제작
- [ ] Splash Screen 제작
- [ ] Signing Key 생성

### 앱스토어 등록
- [ ] 스크린샷 제작 (6.5", 5.5")
- [ ] 앱 설명 작성
- [ ] 개인정보 처리방침
- [ ] 서비스 이용약관

---

## 📞 문의사항

프로젝트 관련 문의: [GitHub Issues](https://github.com/your-repo/your_money_pet/issues)

---

## 🏢 백오피스 개발 (2025-12-29)

### 개요
관리자가 학습 콘텐츠와 퀴즈를 관리할 수 있는 백오피스 시스템 개발 시작

### Phase 1: Firebase 인프라 구축 ✅ 완료

#### 1. Firebase 프로젝트 설정
**프로젝트 정보:**
- 프로젝트 ID: `moneypet-74066`
- Storage Bucket: `moneypet-74066.firebasestorage.app`
- 플랫폼: Android, iOS 설정 완료

**설정 파일:**
- `lib/firebase_options.dart` - Flutter Firebase 설정
- `android/app/google-services.json` - Android 설정
- `ios/Runner/GoogleService-Info.plist` - iOS 설정

#### 2. Firestore Database 생성
**설정:**
- 위치: `asia-northeast3 (Seoul)` - 한국 사용자 최적화
- 모드: Production mode - 보안 우선

**컬렉션 구조:**
```
firestore/
├── users/                     # 사용자 데이터
│   └── {userId}/
│       ├── learning_progress/ # 학습 진행 기록
│       └── quiz_results/      # 퀴즈 결과
├── learning_contents/         # 학습 콘텐츠 (관리자 관리)
├── quiz_contents/             # 퀴즈 콘텐츠 (관리자 관리)
├── character_configs/         # 캐릭터 설정 (관리자 관리)
└── app_config/                # 앱 설정 (관리자 관리)
```

#### 3. Security Rules 설정
**파일 위치:** Firebase Console > Firestore Database > Rules

**핵심 규칙:**
- 사용자 데이터: 본인만 읽기/쓰기
- 콘텐츠/설정: 모두 읽기, 관리자만 쓰기
- 관리자 판별: `request.auth.token.admin == true`

**주요 함수:**
```javascript
function isAdmin() {
  return request.auth != null && request.auth.token.admin == true;
}

function isOwner(userId) {
  return request.auth != null && request.auth.uid == userId;
}
```

#### 4. 관리자 계정 설정
**스크립트:** `scripts/set-admin.js`

**기능:**
- Firebase Admin SDK를 사용해 특정 사용자에게 admin custom claim 부여
- 관리자는 Firestore에서 콘텐츠 쓰기 권한 획득

**사용법:**
```bash
cd scripts
npm install
node set-admin.js <USER_UID>
```

**보안:**
- Service Account Key는 `.gitignore`에 추가 (절대 커밋 금지)
- `scripts/service-account-key.json` 파일 필요

#### 5. 초기 데이터 생성
**스크립트:** `scripts/init-firestore.js`

**생성된 데이터:**

1. **App Config** (1개)
```javascript
{
  minAppVersion: "1.0.0",
  forceUpdateVersion: "1.0.0",
  maintenanceMode: false,
  features: {
    characterSelection: true,
    dailyReminder: true,
    sharing: true
  },
  constants: {
    totalDays: 365,
    learningPoints: 50,
    quizPointsPerQuestion: 20
  }
}
```

2. **Character Configs** (4개)
- 머니베어 (money_bear) - 안전형 🐻
- 세이브쉽 (save_sheep) - 균형형 🐑
- 헌터캣 (hunter_cat) - 공격형 🐱
- 체이서폭스 (chaser_fox) - 도전형 🦊

3. **샘플 Learning Content** (1개)
- Day 1 안전형: "예적금의 기본"
- 3개의 학습 카드
- 예상 소요시간: 3분
- 포인트: 50점

4. **샘플 Quiz Content** (1개)
- Day 1 안전형 퀴즈
- 2개의 문제 (각 50점)
- 합격 점수: 60점

**사용법:**
```bash
cd scripts
node init-firestore.js
```

### Phase 3: 백오피스 웹 개발 ✅ 완료 (2025-12-30)

#### 1. Next.js 프로젝트 생성
**프로젝트 위치:** `backoffice/`

**기술 스택:**
- Next.js 15.1.6 (App Router)
- React 19.0.0
- TypeScript 5
- Tailwind CSS 3.4.1
- Firebase 11.1.0 (Client SDK)

**생성 명령:**
```bash
npx create-next-app@latest backoffice
# ✅ TypeScript: Yes
# ✅ ESLint: Yes
# ✅ Tailwind CSS: Yes
# ✅ src/ directory: No
# ✅ App Router: Yes
# ✅ Import alias: @/*
```

#### 2. Firebase Client SDK 연동
**설정 파일:** `backoffice/lib/firebase.ts`

**Firebase 웹 앱 추가:**
- Firebase Console > Project Settings > 앱 추가 > Web
- 앱 닉네임: "MoneyPet Backoffice"

**환경 변수:** `backoffice/.env.local`
```bash
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyAGQtxbbHxGMENh9XSsma-b9Lqoiewk-OY
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=moneypet-74066.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=moneypet-74066
# ... (기타 Firebase 설정)
```

**주요 코드:**
```typescript
import { initializeApp, getApps } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
export const auth = getAuth(app);
export const db = getFirestore(app);
```

#### 3. shadcn/ui 설치 및 설정
**설치 명령:**
```bash
npx shadcn@latest init
# ✅ Style: New York
# ✅ Base color: Zinc
# ✅ CSS variables: Yes
```

**추가한 컴포넌트:**
```bash
npx shadcn@latest add button
npx shadcn@latest add input
npx shadcn@latest add card
```

**커스텀 색상 추가:** `tailwind.config.ts`
```typescript
colors: {
  safe: "hsl(210, 20%, 55%)",      // 머니베어 - 회색
  balanced: "hsl(142, 76%, 36%)",  // 세이브쉽 - 초록
  aggressive: "hsl(4, 90%, 58%)",  // 헌터캣 - 빨강
  challenger: "hsl(27, 96%, 61%)"  // 체이서폭스 - 주황
}
```

#### 4. React 19 호환성 수정
**문제:**
- lucide-react 0.344.0이 React 19를 지원하지 않음
- @radix-ui/react-slot 1.0.2가 React 19를 지원하지 않음

**해결:**
```json
{
  "lucide-react": "^0.460.0",       // 0.344.0 → 0.460.0
  "@radix-ui/react-slot": "^1.1.0"  // 1.0.2 → 1.1.0
}
```

#### 5. 관리자 로그인 페이지 구현
**파일:** `backoffice/app/login/page.tsx`

**기능:**
- Firebase Auth 이메일/비밀번호 로그인
- Admin custom claim 검증
- 에러 처리 (invalid-credential, too-many-requests 등)
- shadcn/ui Card, Input, Button 컴포넌트 사용

**핵심 로직:**
```typescript
const handleLogin = async (e: React.FormEvent) => {
  e.preventDefault();
  const userCredential = await signInWithEmailAndPassword(auth, email, password);
  const user = userCredential.user;
  const idTokenResult = await user.getIdTokenResult();

  if (!idTokenResult.claims.admin) {
    setError("관리자 권한이 필요합니다.");
    await auth.signOut();
    return;
  }

  router.push("/dashboard");
};
```

#### 6. 대시보드 페이지 구현
**파일:** `backoffice/app/dashboard/page.tsx`

**기능:**
- 관리자 전용 보호된 라우트
- 로그아웃 기능
- 학습 콘텐츠/퀴즈 관리 카드 (준비 중)
- 로그인 성공 상태 카드

**인증 검증:**
```typescript
useEffect(() => {
  const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
    if (!currentUser) {
      router.push("/login");
      return;
    }

    const idTokenResult = await currentUser.getIdTokenResult();
    if (!idTokenResult.claims.admin) {
      await signOut(auth);
      router.push("/login");
      return;
    }

    setUser(currentUser);
    setLoading(false);
  });

  return () => unsubscribe();
}, [router]);
```

#### 7. 자동 리다이렉트 로직
**파일:** `backoffice/app/page.tsx`

**기능:**
- 루트 경로(`/`) 접근 시 자동 판별
- 로그인 + Admin → `/dashboard`
- 로그인 + Non-Admin → `/login` (강제 로그아웃)
- 미로그인 → `/login`

#### 8. 관리자 계정 생성
**계정 정보:**
- 이메일: `admin@moneypet.com`
- 비밀번호: `admin123!`
- UID: `H1krNK1xjZextFIdzPCVY1haQHb2`
- Admin Claim: `true`

**설정 방법:**
```bash
cd scripts
node set-admin.js H1krNK1xjZextFIdzPCVY1haQHb2
```

### 프로젝트 구조 업데이트

```
your_money_pet/
├── lib/                          # Flutter 앱
│   ├── firebase_options.dart     ✅ Firebase 설정
│   └── ...
├── backoffice/                   ✅ 신규 (2025-12-30)
│   ├── app/
│   │   ├── page.tsx              # 자동 리다이렉트
│   │   ├── login/
│   │   │   └── page.tsx          # 로그인 페이지
│   │   ├── dashboard/
│   │   │   └── page.tsx          # 대시보드
│   │   ├── globals.css
│   │   └── layout.tsx
│   ├── components/
│   │   └── ui/                   # shadcn/ui 컴포넌트
│   │       ├── button.tsx
│   │       ├── input.tsx
│   │       └── card.tsx
│   ├── lib/
│   │   ├── firebase.ts           # Firebase 초기화
│   │   └── utils.ts              # cn 유틸리티
│   ├── .env.local                # Firebase 설정 (gitignore)
│   ├── package.json
│   ├── tailwind.config.ts
│   ├── tsconfig.json
│   └── next.config.ts
├── scripts/                      ✅ (2025-12-29)
│   ├── package.json
│   ├── set-admin.js              # 관리자 권한 부여
│   ├── init-firestore.js         # Firestore 초기화
│   ├── service-account-key.json  # (gitignore)
│   └── node_modules/             # (gitignore)
├── docs/
│   ├── BACKOFFICE_DESIGN.md      ✅ 업데이트
│   └── DEVELOPMENT_LOG.md        ✅ 업데이트
└── .gitignore                    ✅ 업데이트
```

### Phase 3 계속: 학습 콘텐츠 관리 구현 ✅ 완료 (2025-12-31)

#### 9. 성향별 페이지 구현
**파일:** `backoffice/app/dashboard/[personality]/page.tsx`

**기능:**
- 동적 라우팅으로 4개 성향 지원 (safe/balanced/aggressive/challenger)
- Tabs 컴포넌트로 학습 콘텐츠/퀴즈 구분
- 성향별 정보 표시 (이름, 한글명, 이모지, 색상)
- 대시보드로 돌아가기 버튼

**성향 정보:**
```typescript
const personalities = {
  safe: { name: "머니베어", nameKo: "안전형", emoji: "🐻", color: "text-safe" },
  balanced: { name: "세이브쉽", nameKo: "균형형", emoji: "🐑", color: "text-balanced" },
  aggressive: { name: "헌터캡", nameKo: "공격형", emoji: "🐱", color: "text-aggressive" },
  challenger: { name: "체이서폭스", nameKo: "도전형", emoji: "🦊", color: "text-challenger" },
};
```

#### 10. 학습 콘텐츠 목록 페이지
**컴포넌트:** `components/learning/LearningContentList.tsx`

**기능:**
- Firestore 쿼리: `where("personality", "==", personality), orderBy("day", "asc")`
- Day 필터 드롭다운 (전체/Day 1-365)
- 정렬: Day 오름차순/내림차순
- 테이블 컬럼: Day, 제목, 카드 개수, 작성일, 수정일, 액션
- 수정/삭제 버튼 (수정 → `/dashboard/[personality]/learning/[id]`)
- 삭제 확인 모달 (⚠️ 되돌릴 수 없음 경고)
- "새 학습 콘텐츠 추가" 버튼

**데이터 관리:**
```typescript
// Firestore 조회
const q = query(
  collection(db, "learning_contents"),
  where("personality", "==", personality),
  orderBy("day", "asc")
);

// 삭제
await deleteDoc(doc(db, "learning_contents", id));
```

#### 11. 학습 콘텐츠 작성/수정 폼
**컴포넌트:** `components/learning/LearningContentForm.tsx`

**기본 정보 필드:**
- Day (1-365, number input)
- 제목 (text input, 필수)
- 예상 소요 시간 (분, number input, 기본값: 3)
- 포인트 (number input, 기본값: 50)

**동적 카드 관리:**
- 카드 추가/삭제 (최소 1개 유지)
- 카드 순서 자동 관리 (order: 1, 2, 3...)
- 카드 타입 선택: text, image, tip, quiz_link

**카드 타입별 입력:**
1. **text**: textarea (학습 내용)
2. **image**:
   - File input (accept="image/*")
   - Firebase Storage 업로드 (`learning/{personality}/{timestamp}_{filename}`)
   - 이미지 미리보기
   - 선택적 설명 (content)
3. **tip**: textarea (💡 팁 내용)
4. **quiz_link**: textarea (퀴즈 ID/링크)

**Firebase Storage 업로드:**
```typescript
const storageRef = ref(storage, `learning/${personality}/${timestamp}_${file.name}`);
await uploadBytes(storageRef, file);
const downloadURL = await getDownloadURL(storageRef);
```

**폼 검증:**
- 제목 필수
- Day 범위 (1-365)
- 카드 최소 1개
- 각 카드 내용 필수 (image 타입은 imageUrl 필수)

**저장/수정:**
```typescript
// 신규 저장
await addDoc(collection(db, "learning_contents"), {
  ...formData,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
});

// 수정
await updateDoc(doc(db, "learning_contents", contentId), {
  ...formData,
  updatedAt: serverTimestamp(),
});
```

#### 12. 신규 작성 페이지
**파일:** `backoffice/app/dashboard/[personality]/learning/new/page.tsx`

**기능:**
- 성향별 보호된 라우트
- Admin 인증 확인
- LearningContentForm 컴포넌트 사용 (contentId 없음)
- 저장 후 성향 페이지로 리다이렉트

#### 13. 수정 페이지
**파일:** `backoffice/app/dashboard/[personality]/learning/[id]/page.tsx`

**기능:**
- 성향별 보호된 라우트
- Admin 인증 확인
- LearningContentForm 컴포넌트 사용 (contentId 전달)
- 기존 데이터 자동 로드
- 수정 후 성향 페이지로 리다이렉트

#### 14. UI 컴포넌트 추가
**파일:** `components/ui/tabs.tsx`

**설치:**
```bash
npm install @radix-ui/react-tabs
```

**컴포넌트:**
- Tabs (root)
- TabsList (탭 버튼 컨테이너)
- TabsTrigger (개별 탭 버튼)
- TabsContent (탭 내용)

### 프로젝트 구조 업데이트 (2025-12-31)

```
backoffice/
├── app/
│   ├── dashboard/
│   │   ├── page.tsx                           # 성향 선택 대시보드
│   │   └── [personality]/
│   │       ├── page.tsx                       # 성향별 메인 (탭)
│   │       └── learning/
│   │           ├── new/
│   │           │   └── page.tsx               # 신규 작성 ✅ 신규
│   │           └── [id]/
│   │               └── page.tsx               # 수정 ✅ 신규
│   ├── login/
│   │   └── page.tsx
│   └── page.tsx
├── components/
│   ├── learning/
│   │   ├── LearningContentList.tsx            # 목록 ✅ 신규
│   │   └── LearningContentForm.tsx            # 작성/수정 폼 ✅ 신규
│   └── ui/
│       ├── button.tsx
│       ├── card.tsx
│       ├── input.tsx
│       └── tabs.tsx                           # ✅ 신규
└── lib/
    ├── firebase.ts
    └── utils.ts
```

### 다음 단계 (Phase 3 계속)

#### 예정 작업:
1. **퀴즈 관리 페이지** (`/dashboard/quiz`)
   - 목록 조회
   - 신규 작성
   - 수정/삭제

2. **유저 관리 페이지** (향후)
   - 사용자 활성화/비활성화
   - 탈퇴 처리

### Git 커밋 히스토리
```bash
c4e8b3f - Feat: Implement learning content create and edit pages (2025-12-31)
1f8e030 - Feat: Implement learning content list page with personality selection (2025-12-31)
080d765 - Docs: Update backoffice development progress (Phase 3) (2025-12-30)
6410834 - Fix: Update lucide-react and @radix-ui/react-slot to support React 19 (2025-12-30)
592e6a2 - Implement admin login and dashboard pages (2025-12-30)
dd73792 - Add shadcn/ui setup and components (2025-12-30)
2b2ca0f - Add Firebase client SDK integration to backoffice (2025-12-30)
27ec664 - Add Next.js backoffice project (2025-12-30)
390dbae - Add Firestore initialization script (2025-12-29)
7f2f4d3 - Add Firebase Admin scripts for setting admin custom claims (2025-12-29)
```

---

**Last Updated:** 2025-12-31
**Contributors:** Claude AI

---

## 2025-12-31: Tip 구조 변경 및 Flutter 팀 협의 완료

### 배경
Flutter 팀과 백오피스 데이터 구조 정합성 검토 진행

### Flutter 팀 질문 사항
1. **Tip 필드 처리 방식**
   - 방안 A: tip을 별도 카드 타입으로 처리
   - 방안 B: tip을 카드 속성으로 처리 (선택적 필드)

2. **기존 데이터 마이그레이션**
   - 현재 백오피스에 저장된 테스트 데이터 처리 방법

3. **성향(personality) 매칭**
   - UserProvider에 사용자 성향 정보(personalityType) 존재 여부

### 의사결정 결과

#### 1. Tip 구조: 방안 B 선택 (카드 속성)
**이유:**
- 모든 카드에 선택적으로 팁 추가 가능
- 데이터 구조가 더 유연함
- Flutter 모델과 일치

**백오피스 수정 사항:**
```typescript
interface LearningCard {
  order: number;
  type: "text" | "image" | "quiz_link";  // "tip" 제거됨
  content: string;
  imageUrl?: string;
  tip?: string;  // 선택적 팁 필드 추가
}
```

**UI 변경:**
- 카드 타입 드롭다운에서 "팁" 옵션 제거
- 모든 카드에 접을 수 있는 "💡 팁 추가하기" 섹션 추가

#### 2. 데이터 마이그레이션: 깔끔하게 새로 시작
**방법:**
- Firebase Console 또는 삭제 스크립트로 테스트 데이터 삭제
- 새로운 데이터 구조로 콘텐츠 재입력

**삭제 스크립트:**
```javascript
// scripts/delete-test-data.js
const admin = require("firebase-admin");
const serviceAccount = require("./service-account-key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCollection(collectionName) {
  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();
  snapshot.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  console.log(`✅ ${collectionName} 삭제 완료`);
}

async function main() {
  await deleteCollection("learning_contents");
  await deleteCollection("quiz_contents");
  console.log("✅ 모든 테스트 데이터 삭제 완료");
}

main();
```

#### 3. UserProvider 확인: personalityType 존재 ✅
**Flutter 팀 답변:**
- UserModel에 `personalityType` 필드 존재 (Line 7)
- UserProvider에서 `user.personalityType`로 접근 가능
- Enum: `PersonalityType.safe`, `balanced`, `aggressive`, `challenger`
- JSON 변환: `personalityType.name` → `"safe"`, `"balanced"` 등
- **완벽하게 백오피스 Firestore 구조와 매칭 가능**

### 구현 완료

#### 파일 수정: `backoffice/components/learning/LearningContentForm.tsx`

**변경 사항:**
1. LearningCard 인터페이스 업데이트
2. 카드 타입에서 "tip" 제거
3. tip 필드 추가 (선택적)
4. updateCardTip 핸들러 추가
5. 접을 수 있는 팁 입력 섹션 UI 추가

**구현 코드:**
```typescript
// 인터페이스
interface LearningCard {
  order: number;
  type: "text" | "image" | "quiz_link";
  content: string;
  imageUrl?: string;
  tip?: string;
}

// 핸들러
const updateCardTip = (index: number, tip: string) => {
  const newCards = [...formData.cards];
  newCards[index] = { ...newCards[index], tip };
  setFormData({ ...formData, cards: newCards });
};

// UI
<details className="mt-3">
  <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900">
    💡 팁 추가하기 (선택사항)
  </summary>
  <div className="mt-2">
    <textarea
      value={card.tip || ""}
      onChange={(e) => updateCardTip(index, e.target.value)}
      className="w-full border rounded-md px-3 py-2 min-h-[80px]"
      placeholder="이 카드와 관련된 팁이나 추가 정보를 입력하세요"
    />
  </div>
</details>
```

### Flutter 팀 전달 사항

#### 최종 데이터 구조
```typescript
// Firestore: learning_contents
{
  day: 1,
  personality: "safe",
  title: "예적금의 기본",
  estimatedMinutes: 3,
  points: 50,
  cards: [
    {
      order: 1,
      type: "text",
      content: "예금과 적금의 차이는...",
      tip: "💡 금리가 높을수록 이자를 더 많이 받아요!"  // 선택적
    }
  ],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Flutter 모델 구조 (권장)
```dart
class LearningCard {
  final int order;
  final String type;  // "text", "image", "quiz_link"
  final String content;
  final String? imageUrl;
  final String? tip;  // 선택적 필드

  bool get hasTip => tip != null && tip!.isNotEmpty;
}
```

#### Firestore 조회
```dart
// 사용자 성향에 맞는 콘텐츠 조회
final user = context.read<UserProvider>().user;
final personality = user.personalityType.name;  // "safe", "balanced", etc.

final contents = await FirebaseFirestore.instance
  .collection('learning_contents')
  .where('personality', isEqualTo: personality)
  .orderBy('day')
  .get();
```

### Git 커밋
```bash
7cc08f4 - Refactor: Change tip from card type to optional property (2025-12-31)
ac9de6f - Fix: Resolve image upload state update issue in LearningContentForm (2025-12-31)
```

### 다음 단계
1. Flutter 팀: LearningCard 모델 업데이트 (tip 필드 추가)
2. Flutter 팀: Firestore 연동 구현
3. 백오피스: 새 데이터 구조로 콘텐츠 1개 생성하여 테스트
4. Flutter 앱에서 정상 표시 확인
5. 확인 완료 후 본격적인 콘텐츠 입력 시작

---

**Last Updated:** 2025-12-31
**Contributors:** Claude AI

---

## 2026-01-01: 퀴즈 관리 기능 구현 완료

### 배경
Flutter 팀의 Quiz 모델 구현 완료 후 백오피스에서 퀴즈 관리 기능 구현

### 구현 내용

#### 1. QuizContentList 컴포넌트
**파일:** `backoffice/components/quiz/QuizContentList.tsx`

**기능:**
- Firestore quiz_contents 컬렉션 조회 (personality + day 필터)
- Day 필터 (1-365 입력)
- 정렬 토글 (오름차순/내림차순)
- 테이블 뷰
  - Day, 문제 개수, 총점, 통과점수
  - 작성일, 수정일
  - 수정/삭제 액션
- 삭제 확인 모달

**Firestore 쿼리:**
```typescript
const q = query(
  collection(db, "quiz_contents"),
  where("personality", "==", personality),
  orderBy("day", sortOrder)
);
```

#### 2. QuizContentForm 컴포넌트
**파일:** `backoffice/components/quiz/QuizContentForm.tsx`

**기능:**
- 기본 정보 입력
  - Day (1-365)
  - 성향 (자동 설정)
  - 총점
  - 통과점수
  
- 동적 질문 관리
  - 질문 추가/삭제
  - order 자동 관리 (1, 2, 3...)
  - 질문 텍스트 입력
  - 배점 설정
  
- 질문별 선택지 관리
  - 선택지 추가/삭제 (최소 2개)
  - 선택지 텍스트 입력
  - 정답 선택 (라디오 버튼)
  - 해설 입력 (정답/오답 모두)
  
- 폼 검증
  - Day 범위 (1-365)
  - 최소 1문제
  - 질문 텍스트 필수
  - 최소 2선택지
  - 정답 1개 필수
  - 선택지 텍스트 필수
  - 해설 필수
  - 배점 > 0
  - 총점 > 0
  - 통과점수 ≤ 총점

**데이터 구조:**
```typescript
interface QuizContentData {
  day: number;
  personality: string;
  questions: QuizQuestion[];
  totalPoints: number;
  passingScore: number;
}

interface QuizQuestion {
  order: number;  // 질문 순서
  question: string;
  options: QuizOption[];  // 배열 순서 보장
  points: number;
}

interface QuizOption {
  text: string;
  isCorrect: boolean;
  explanation: string;
  // order 필드 없음 - 배열 순서 사용
}
```

#### 3. 퀴즈 라우트 페이지

**신규 작성:** `backoffice/app/dashboard/[personality]/quiz/new/page.tsx`
- Admin 권한 확인
- QuizContentForm 사용 (quizId 없음)
- 저장 후 성향 페이지로 리다이렉트

**수정:** `backoffice/app/dashboard/[personality]/quiz/[id]/page.tsx`
- Admin 권한 확인
- QuizContentForm 사용 (quizId 전달)
- 기존 데이터 자동 로드
- 수정 후 성향 페이지로 리다이렉트

**Next.js 15 호환:**
```typescript
// params가 Promise로 변경됨
export default function EditQuizPage({ 
  params 
}: { 
  params: Promise<{ personality: string; id: string }> 
}) {
  const [personality, setPersonality] = useState<PersonalityType | null>(null);
  const [quizId, setQuizId] = useState<string | null>(null);
  
  useEffect(() => {
    params.then(p => {
      setPersonality(p.personality as PersonalityType);
      setQuizId(p.id);
    });
  }, [params]);
}
```

#### 4. 성향별 페이지 통합
**파일:** `backoffice/app/dashboard/[personality]/page.tsx`

**변경사항:**
```typescript
import QuizContentList from "@/components/quiz/QuizContentList";

// 퀴즈 탭
<TabsContent value="quiz" className="space-y-4">
  <QuizContentList personality={personality} />
</TabsContent>
```

### 프로젝트 구조 업데이트

```
backoffice/
├── app/
│   └── dashboard/
│       └── [personality]/
│           ├── page.tsx               # 학습/퀴즈 탭 (업데이트)
│           ├── learning/
│           │   ├── new/page.tsx
│           │   └── [id]/page.tsx
│           └── quiz/                  # ✅ 신규
│               ├── new/page.tsx       # ✅ 신규
│               └── [id]/page.tsx      # ✅ 신규
└── components/
    ├── learning/
    │   ├── LearningContentList.tsx
    │   └── LearningContentForm.tsx
    └── quiz/                          # ✅ 신규
        ├── QuizContentList.tsx        # ✅ 신규
        └── QuizContentForm.tsx        # ✅ 신규
```

### Flutter 팀 협의 사항 반영

#### 선택지 순서 보장
**결정:** 옵션 A 선택 - 배열 순서 보장

**Firestore 동작:**
- 배열은 저장된 순서를 유지
- 백오피스에서 순서대로 저장하면 그대로 조회됨

**Flutter 처리:**
```dart
// 배열 순서 그대로 사용 (정렬 불필요)
final options = (json['options'] as List)
  .map((o) => QuizOption.fromJson(o))
  .toList();
```

**백오피스 처리:**
- 선택지 추가 시 배열 끝에 추가
- 선택지 삭제 시 filter로 제거
- Firestore 저장 시 배열 순서 유지

#### Firebase Composite Index
**필요 인덱스:**
- Collection: `quiz_contents`
- Fields: `personality` (Ascending) + `day` (Ascending)

**생성 방법:**
- 첫 쿼리 실행 시 Firebase가 자동으로 생성 링크 제공
- 링크 클릭하면 자동 생성 (1-2분 소요)

### 빌드 검증

**빌드 결과:**
```
✓ Compiled successfully in 10.6s
✓ Generating static pages (6/6)

Route (app)
├ ƒ /dashboard/[personality]/quiz/new
└ ƒ /dashboard/[personality]/quiz/[id]
```

**ESLint 경고:**
```
QuizContentList.tsx:50:6
Warning: React Hook useEffect has a missing dependency: 'loadQuizzes'
```
- 비중요 경고 (useEffect 의존성 최적화)
- 기능에 영향 없음

### Git 커밋
```bash
c1d7ac7 - Feat: Implement quiz management feature (complete CRUD)
7cc08f4 - Refactor: Change tip from card type to optional property
```

### 다음 단계

#### 즉시 가능
1. **테스트 데이터 입력**
   - Day 1~10 퀴즈 생성 (4개 성향 × 10일 = 40개)
   - Flutter 앱에서 퀴즈 풀기 테스트
   - quiz_link 카드 동작 확인

2. **Firebase Composite Index 생성**
   - 퀴즈 목록 조회 시 인덱스 생성 링크 클릭
   - 생성 완료 대기 (1-2분)

#### 향후 개선
1. **UI/UX 개선**
   - 선택지 드래그 앤 드롭 순서 변경
   - 질문 미리보기 모드
   - 통과점수 자동 계산 (총점의 60%)

2. **데이터 검증 강화**
   - 중복 Day 체크
   - 총 배점과 totalPoints 일치 검증
   - 선택지 중복 텍스트 경고

3. **통계 기능**
   - 퀴즈별 정답률 표시
   - 난이도 분석
   - 사용자 피드백 수집

---

**Last Updated:** 2026-01-01
**Contributors:** Claude AI
