# 📋 TODO & Task Tracking

> **실시간 업데이트 문서** - 개발 진행 상황과 남은 작업 추적

마지막 업데이트: 2025-01-15

---

## 🚨 긴급 (High Priority)

### 1. Google 로그인/회원가입 구현 ⭐⭐⭐
**상태:** 🔴 TODO
**우선순위:** P0 (필수)
**담당:** TBD
**예상 소요:** 2-3일

**요구사항:**
- Firebase Authentication 연동
- Google OAuth 로그인
- 직접 회원가입 (이메일/비밀번호)
- 온보딩 완료 후 → 홈 화면 진입 전 필수 로그인
- 퀴즈/학습 진행 시 미로그인 시 로그인 화면으로 리다이렉트

**구현 화면:**
```
온보딩 완료 → [로그인/회원가입 화면] → 홈 화면
                ↓
        ┌─────────────────┐
        │  머니펫에 오신   │
        │  것을 환영해요!  │
        │                 │
        │ [Google 로그인]  │
        │ [직접 회원가입]  │
        │                 │
        │   나중에 하기    │
        └─────────────────┘
```

**세부 작업:**
- [ ] Firebase Authentication 프로젝트 설정
- [ ] `firebase_auth`, `google_sign_in` 패키지 추가
- [ ] `lib/screens/auth/login_screen.dart` 생성
- [ ] `lib/services/auth_service.dart` 생성
- [ ] Google OAuth 클라이언트 ID 설정 (iOS/Android)
- [ ] 로그인 상태 Provider 연동
- [ ] UserProvider에 Firebase UID 매핑
- [ ] 로그인 후 사용자 데이터 Firestore 동기화
- [ ] "나중에 하기" 옵션 (온보딩만 가능, 학습은 차단)

**참고:**
- Firestore Security Rules: `/users/{userId}` 본인만 읽기/쓰기
- 로그인 없이 온보딩 내용은 로컬 메모리에 임시 저장
- 로그인 시 Firestore에 영구 저장

---

### 2. Rive 애니메이션 통합
**상태:** 🟡 대기 중 (애니메이션 파일 필요)
**우선순위:** P1
**담당:** 사용자 (애니메이션 제작) + 개발자 (통합)
**예상 소요:** 1-2일 (통합만)

**현재 상태:**
- ✅ `AnimatedCharacter` 위젯 Placeholder 구현 완료
- ✅ 애니메이션 상태 enum 정의 (`CharacterAnimationState`)
- ✅ 캐릭터별 대사 시스템 구현
- 🔴 실제 .riv 파일 없음

**필요한 애니메이션 (캐릭터당 5종):**
1. **Idle** - 숨쉬기 (2초 loop)
2. **Selected** - 선택됨 (점프, 1회)
3. **Speaking** - 말하기 (말풍선 동안)
4. **Happy** - 기쁨 (학습 완료)
5. **Sad** - 슬픔 (미접속 3일+)

**통합 작업:**
- [ ] `assets/animations/` 폴더에 .riv 파일 추가
- [ ] `pubspec.yaml`에 assets 경로 등록
- [ ] `AnimatedCharacter`에서 `RiveAnimation.asset()` 사용
- [ ] 상태별 애니메이션 전환 로직
- [ ] Fallback 로직 유지 (파일 없을 시 Placeholder)

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

## 🟠 중요 (Medium Priority)

### 4. 실제 학습 콘텐츠 작성
**상태:** 🔴 TODO
**우선순위:** P2
**담당:** 콘텐츠 작성자
**예상 소요:** 2-4주

**목표:**
- Day 1-10: 각 성향별 콘텐츠 (총 40개)
- 퀴즈 문항: 5문항 × 10일 × 4성향 = 200개

**성향별 커리큘럼:**
- **안전형**: 예적금, 복리, 채권
- **밸런스형**: 예적금 + 펀드 기초
- **공격형**: 주식 기초, ETF
- **도전형**: 가상화폐, 선물옵션 입문

**작성 형식:**
```dart
{
  "contentId": "day_001_safe",
  "day": 1,
  "personalityType": "safe",
  "title": "예적금의 기본",
  "cards": [
    {
      "type": "intro",
      "content": "예금과 적금의 차이를 알아볼까요?",
      "imageUrl": null
    }
  ]
}
```

---

### 5. Firebase Firestore 연동
**상태:** 🔴 TODO
**우선순위:** P2
**담당:** TBD
**예상 소요:** 1-2일

**구현 내용:**
- [ ] Firebase 프로젝트 생성
- [ ] `firebase_core`, `cloud_firestore` 설정
- [ ] Collections 생성:
  - `users/{userId}/profile`
  - `users/{userId}/learning_progress/{dayId}`
  - `users/{userId}/quiz_results/{quizId}`
  - `learning_contents/{contentId}`
  - `quiz_contents/{quizId}`
  - `character_configs/{characterId}`
  - `app_config/config`
- [ ] Security Rules 설정 (참고: `BACKOFFICE_DESIGN.md`)
- [ ] `lib/services/firebase_service.dart` 구현
- [ ] UserProvider → Firestore 동기화

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

### MVP v1.0 완료율
```
온보딩:          ████████░░ 80% (8/10)
핵심 기능:       ██░░░░░░░░ 20% (1/5)
게이미피케이션:  ███░░░░░░░ 30% (부분)
콘텐츠:          ░░░░░░░░░░  0% (0/120)
애니메이션:      ██░░░░░░░░ 20% (Placeholder)
Firebase:        ░░░░░░░░░░  0%
전체:            ███░░░░░░░ 30%
```

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
- [x] 문서화 (DEVELOPMENT_LOG.md, BACKOFFICE_DESIGN.md)

---

## 🐛 알려진 이슈

### Critical
- 없음 (현재 모든 에러 해결됨)

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
