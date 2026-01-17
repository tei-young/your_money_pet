# 📐 설계 결정 사항 (Design Decisions)

> MoneyPet 프로젝트의 주요 설계 및 기술 결정사항 기록

마지막 업데이트: 2026-01-18

---

## 🎯 설계 결정 사항

### 1. 캐릭터 우선 온보딩 (2025-01-15)

**결정:** 온보딩 플로우에서 캐릭터 선택을 성향 진단보다 먼저 진행

**이유:**
- 게이미피케이션 특색 강조
- 캐릭터와의 유대감 조기 형성
- 사용자 몰입도 향상

**영향:**
- CharacterProvider에 `selectedCharacter` vs `finalPersonality` 분리
- 성향 결과 화면에서 캐릭터 이름 제거 (성향 중심)
- 이름 설정 시 선택한 캐릭터 기본 이름 사용

**관련 파일:**
- `lib/providers/character_provider.dart`
- `lib/screens/onboarding/*`

---

### 2. 성향 변경 정책

**결정:** 성향 변경 시 Day 1부터 재시작, 기존 기록은 보관

**세부 정책:**
- 성향 변경 시 Day 1부터 재시작
- 기존 학습 기록은 `personality.history`에 보관
- 변경 시 확인 팝업 필수
- 변경 횟수 제한 없음 (추후 재검토 가능)

**이유:**
- 각 성향별 커리큘럼이 완전히 다름
- 중간부터 시작 시 학습 흐름 단절
- 기록 보관으로 사용자 데이터 손실 방지

**관련 파일:**
- `lib/models/user_model.dart`
- `lib/screens/settings/settings_screen.dart`

---

### 3. 포인트 시스템

**결정:** MVP는 포인트 획득만 구현, 사용처는 추후 버전에서 추가

**로드맵:**
- **MVP (v1.0):** 획득만 (학습 완료, 퀴즈 정답)
- **v1.1:** 꾸미기 아이템 상점
- **v1.2:** 캐릭터 진화 시스템

**이유:**
- MVP 개발 범위 축소
- 핵심 기능(학습) 집중
- 추후 확장 가능하도록 설계

**포인트 획득:**
- 학습 완료: 50P
- 퀴즈 문항당: 20P
- 퀴즈 만점: +50P 보너스
- 연속 학습: 추후 추가 예정

**관련 파일:**
- `lib/models/user_model.dart`
- `lib/providers/user_provider.dart`

---

### 4. 퀴즈 재개 없음

**결정:** 퀴즈 중단 시 재개 기능 없음, 처음부터 다시 풀기

**이유:**
- 5문항으로 짧아서 재개 필요성 낮음
- 개발 복잡도 감소
- 상태 관리 단순화

**대안:**
- 퀴즈 시작 전 "5문항입니다" 안내
- 중단 시 "처음부터 다시 시작됩니다" 경고

**관련 파일:**
- `lib/screens/learning/quiz_screen.dart`

---

## 🔧 기술 결정 사항

### 1. Provider vs Riverpod

**선택:** Provider

**이유:**
- 간단한 상태 관리로 충분
- 낮은 러닝 커브
- 충분한 커뮤니티 지원
- 프로젝트 규모에 적합

**고려했던 대안:**
- Riverpod: 더 강력하지만 과한 스펙
- Bloc: 보일러플레이트 코드 과다

**관련 파일:**
- `lib/providers/*`
- `pubspec.yaml`

---

### 2. Rive vs Lottie → 프레임 기반 PNG

**변경 히스토리:**
- **초기 (2025-11):** Rive 선택
- **2025-12-13:** 프레임 기반 PNG로 변경
- **2025-12-24:** 통합 애니메이션 방식으로 재설계

**최종 선택:** 프레임 기반 PNG 시퀀스 (24fps)

**이유:**
- Midjourney/Runway로 제작 가능
- 디자이너가 직접 제어 가능
- Rive 학습 곡선 없음
- 개별 상태 조합 시 프레임 불일치 문제 해결

**트레이드오프:**
- 장점: 제작 용이, 품질 높음, 전환 부드러움
- 단점: 파일 크기 증가 (WebP 변환으로 완화)

**관련 문서:**
- `docs/FRAME_ANIMATION_GUIDE.md`
- `docs/ANIMATION_UPDATE_2025-12-13.md`

**관련 파일:**
- `lib/models/character_frame_animation.dart`
- `lib/widgets/animated_character.dart`

---

### 3. SharedPreferences vs Hive

**선택:** SharedPreferences (로그인 전) + Firestore (로그인 후)

**이유:**
- 간단한 데이터 구조
- Firebase 우선 전략
- 클라우드 동기화 필수

**데이터 저장 전략:**
- 온보딩 중: 메모리 (Provider)
- 로그인 전: SharedPreferences (임시)
- 로그인 후: Firestore (영구)

**관련 파일:**
- `lib/providers/user_provider.dart`
- `lib/services/auth_service.dart`

---

### 4. 스크롤 물리 효과

**선택:** ClampingScrollPhysics 전역 적용

**결정:**
- iOS 바운스 효과 제거
- 디자인 일관성 확보
- 안드로이드와 통일된 UX

**적용 방법:**
```dart
MaterialApp(
  theme: ThemeData(
    scrollBehavior: ClampingScrollBehavior(),
  ),
)
```

**관련 파일:**
- `lib/main.dart`

---

## 💬 개발 가이드라인

### 1. 구어체 톤앤매너

**규칙:** 모든 사용자 대면 텍스트는 "~해요" 어미 사용

**예시:**
- ✅ "같이 시작해요!"
- ✅ "우리 딱 맞는 것 같아요!"
- ✅ "학습을 완료했어요!"
- ❌ "학습을 완료했습니다"
- ❌ "시작하세요"

**적용 범위:**
- 안내 문구
- 버튼 텍스트
- 캐릭터 대사
- 알림 메시지

**예외:**
- 에러 메시지 (명확성 우선)
- 법적 고지 (정확성 우선)

**관련 파일:**
- 모든 화면 파일 (`lib/screens/**/*.dart`)

---

### 2. 캐릭터 대사

**규칙:** 각 캐릭터마다 고유한 말투와 성격 반영

**캐릭터별 말투:**
- **헌터캣 (Hunter Cat):** 호기심 많고 활동적
  - "오! 재미있겠는데?"
  - "같이 찾아볼까?"

- **머니베어 (Money Bear):** 안정적이고 신중함
  - "차근차근 알아볼게요"
  - "안전하게 시작해요"

- **세이브쉽 (Save Sheep):** 친근하고 부드러움
  - "걱정 마요, 같이해요"
  - "천천히 하면 돼요"

- **체이서폭스 (Chaser Fox):** 적극적이고 도전적
  - "빨리 시작해볼까요?"
  - "더 높은 목표로!"

**정의 위치:**
- `lib/models/character_animation_config.dart`

**관련 파일:**
- `lib/widgets/speech_bubble.dart`
- `lib/screens/*/`

---

### 3. 애니메이션 성능

**목표:** 60 FPS 유지

**필수 사항:**
- `RepaintBoundary` 사용 (불필요한 rebuild 방지)
- `ValueListenableBuilder` 사용 (setState() 최소화)
- Image cacheWidth/cacheHeight 설정

**성능 최적화 완료 (2026-01-14):**
- ✅ RepaintBoundary 추가
- ✅ ValueListenableBuilder 전환
- ✅ Image 캐싱 추가
- ✅ 점진적 로딩 (480 → 150 프레임)

**측정 방법:**
```bash
flutter run --profile
# DevTools에서 Performance 탭 확인
```

**관련 파일:**
- `lib/widgets/animated_character.dart`
- `lib/services/character_animation_preloader.dart`
- `performance_optimization_guide.md`

---

### 4. Firebase Security Rules

**정책:**
- 콘텐츠: 모두 읽기, 관리자만 쓰기
- 사용자 데이터: 본인만 읽기/쓰기

**규칙:**
```javascript
// 콘텐츠 (학습, 퀴즈)
match /learning_contents/{contentId} {
  allow read: if true;
  allow write: if isAdmin();
}

// 사용자 프로필
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

**관련 파일:**
- `firestore.rules`
- `firebase_database_rule`

---

## 📊 애니메이션 시스템 설계

### 프레임 기반 애니메이션 (2025-12-24)

**상태 개수:** 13개

**설계 원칙:**
- 개별 상태 조합 방식 → 화면별 통합 애니메이션 방식
- thinking → happy → idle 복귀를 하나의 애니메이션으로 제작
- 부드러운 전환을 위한 자동 전환 로직

**총 제작 물량:**
- 4 캐릭터 × 13 상태 = 52개 애니메이션

**우선순위:**
1. Phase 1: 온보딩 (16개) - 최우선
2. Phase 2: 학습 퀴즈 (16개)
3. Phase 3: 홈 화면 (20개)

**상세 문서:**
- `docs/FRAME_ANIMATION_GUIDE.md`
- `docs/ANIMATION_UPDATE_2025-12-13.md`

---

## 🔗 관련 문서

- [TODO.md](./TODO.md) - MVP 출시를 위한 작업 목록
- [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - 상세 개발 로그
- [BACKOFFICE_DESIGN.md](./BACKOFFICE_DESIGN.md) - 백오피스 설계
- [FRAME_ANIMATION_GUIDE.md](./FRAME_ANIMATION_GUIDE.md) - 애니메이션 가이드
- [README.md](../README.md) - 프로젝트 개요

---

**작성일:** 2026-01-18
**작성 목적:** TODO.md에서 설계 결정사항을 분리하여 별도 관리
