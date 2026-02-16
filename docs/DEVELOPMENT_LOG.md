# MoneyPet 개발 로그

> **현재 마일스톤:** MVP v1.0 출시 준비
>
> 이 파일에는 현재 마일스톤 관련 개발 로그만 포함됩니다.
> 이전 마일스톤 기록은 아카이브를 참고하세요:
>
> | 마일스톤 | 기간 | 파일 |
> |---------|------|------|
> | 01. 초기 설정 및 온보딩 | 2025-01 | [MILESTONE_01_INIT_ONBOARDING.md](./archive/MILESTONE_01_INIT_ONBOARDING.md) |
> | 02. 학습/퀴즈 및 Firebase Auth | 2025-11 ~ 2025-12 | [MILESTONE_02_LEARNING_AUTH.md](./archive/MILESTONE_02_LEARNING_AUTH.md) |
> | 03. 프레임 애니메이션 시스템 | 2025-12-13 ~ 2025-12-26 | [MILESTONE_03_FRAME_ANIMATION.md](./archive/MILESTONE_03_FRAME_ANIMATION.md) |
>
> **기준:** 마일스톤 완료 시 해당 로그를 아카이브로 이동합니다.

---

## 📅 2026-01-18: 데이터 영속성 및 마크업 파싱 구현

### 🎯 목표
MVP 출시를 위한 1순위 작업: 데이터 영속성 구현 및 텍스트 마크업 파싱 확장

### 📋 완료된 작업

#### 1. 텍스트 마크업 파싱 확장 ✅
**파일:** `lib/utils/text_renderer.dart`

**변경 사항:**
- ✅ 6가지 마크업 지원 (볼드, 이탤릭, 밑줄, 취소선, 색상, 크기)
- ✅ 통합 정규식 패턴으로 모든 마크업 동시 처리
- ✅ `_parseColor()` 헬퍼 메서드 추가

**지원 문법:**
```
**볼드** / *이탤릭* / __밑줄__ / ~~취소선~~
[color:#FF0000]색상[/color] / [size:20]크기[/size]
```

---

#### 2. SharedPreferences 로컬 저장 구현 ✅
**파일:** `lib/providers/user_provider.dart`

**변경 사항:**
- ✅ `loadUser()` 완전 구현 (JSON 파싱)
- ✅ `_saveToStorage()` 완전 구현 (JSON 직렬화)
- ✅ `logout()` SharedPreferences 클리어 추가

**데이터 흐름:**
```
온보딩 중: 메모리 (Provider)
로그인 전: SharedPreferences (임시)
로그인 후: Firestore (영구) + SharedPreferences (캐시)
```

---

#### 3. Firestore 사용자 데이터 동기화 구현 ✅
**파일:** `lib/services/user_service.dart` (신규)

**구현된 메서드:**
- `createUserProfile()` - 회원가입 시 Firestore에 프로필 생성
- `loadUserProfile()` - 로그인 시 Firestore에서 프로필 로드
- `updateUserProfile()` - 사용자 데이터 업데이트
- `deleteUserProfile()` - 프로필 삭제
- `watchUserProfile()` - 실시간 스트림
- `userExists()` - 존재 여부 확인

**UserProvider 확장:**
- ✅ `loginWithFirebase()` 메서드 추가
- ✅ `isFirebaseUser` getter 추가
- ✅ `firebaseUid` 필드 추가 (UserModel)

---

### 📊 진행 상황

**완료율:** 16% → 36% (+20%)

**남은 MVP 필수 작업:**
1. 학습 콘텐츠 작성 (40개)
2. 퀴즈 콘텐츠 작성 (200문항)
3. 애니메이션 제작 (16개)
4. Firestore 콘텐츠 로딩 시스템 완성
5. 통합 테스트

---

## 📅 2026-01-01: Firestore 백오피스 통합 구현

### 🎯 목표
백오피스 팀이 설계한 Firestore 스키마에 맞춰 학습 콘텐츠 및 퀴즈 데이터 통합

### 📋 완료된 작업

#### 1. Firestore 모델 생성 ✅
**파일:** `lib/models/learning_content_model.dart`, `lib/models/quiz_model.dart`

**LearningContent 모델:**
- 필드: `day`, `personality`, `title`, `estimatedMinutes`, `points`, `cards[]`, `createdAt`, `updatedAt`
- Firestore Timestamp → DateTime 자동 변환
- cards 배열 자동 정렬 (order 필드 기준)

**Quiz 모델:**
- 필드: `day`, `personality`, `questions[]`, `totalPoints`, `passingScore`
- QuizQuestion, QuizOption 중첩 모델

**커밋:** 8800ae0

---

#### 2. Firestore 서비스 생성 ✅
**파일:** `lib/services/learning_content_service.dart`

**구현된 메서드:**
- `getLearningContent(day, personality)`
- `getQuiz(day, personality)`
- `getLearningContentWithQuiz(day, personality)` - 병렬 로딩

**커밋:** 8800ae0

---

#### 3. LearningProvider Firestore 통합 ✅
**파일:** `lib/providers/learning_provider.dart`

**변경 사항:**
- ✅ `loadLearningDay()` Firestore 연동
- ✅ 어댑터 패턴 (Firestore 모델 → 기존 LearningDayModel)
- ✅ quiz_link 카드 필터링

**커밋:** 8800ae0

---

#### 4. LearningScreen 업데이트 ✅
**파일:** `lib/screens/learning/learning_screen.dart`

**변경 사항:**
- ✅ personality 자동 전달
- ✅ 콘텐츠 없음 에러 처리 ("준비 중인 학습입니다")
- ✅ 이미지 로딩 인디케이터 추가
- ✅ 이미지 로드 실패 처리

**커밋:** 8800ae0

---

### 🎯 기술적 결정

| 항목 | 결정 | 이유 |
|------|------|------|
| 어댑터 패턴 | ✅ 채택 | 기존 UI 로직 유지, 점진적 마이그레이션 |
| 병렬 로딩 | ✅ 채택 | Future.wait()로 ~50% 시간 단축 |
| quiz_link 필터링 | ✅ 채택 | 현재 앱 구조에서 학습→퀴즈 순차 진행 |

---

## 🔗 관련 문서

- [TODO.md](./TODO.md) - MVP 출시 체크리스트
- [DESIGN_DECISIONS.md](./DESIGN_DECISIONS.md) - 설계 결정사항
- [BACKOFFICE_DESIGN.md](./BACKOFFICE_DESIGN.md) - 백오피스 설계
- [FRAME_ANIMATION_GUIDE.md](./FRAME_ANIMATION_GUIDE.md) - 애니메이션 가이드
- [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) - 릴리즈 체크리스트

---

**마지막 업데이트:** 2026-02-15
