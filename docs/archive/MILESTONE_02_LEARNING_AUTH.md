# 마일스톤 02: 학습/퀴즈 기능 및 Firebase Auth

> **기간:** 2025-11-27 ~ 2025-12-08
> **상태:** ✅ 완료

---

## 📋 요약

학습 완료 UI, 복습 모드 구현 및 Firebase Authentication 통합

---

## 📅 2025-12-08: 학습 완료 UI 및 복습 모드

### 변경 내용

**학습 완료 UI:**
- ✅ `hasLearnedToday = true` 상태에 따른 UI 분기
- ✅ 완료 축하 메시지 + 내일 학습 예고
- ✅ [복습하기] / [이전 학습 보기] 버튼

**복습 모드 (Review Mode):**
- ✅ `isReview` 플래그 추가 (LearningScreen, QuizScreen, QuizResultScreen)
- ✅ 복습 모드 시 주황색 배지 표시
- ✅ 복습 모드 시 포인트/스트릭 미증가
- ✅ 캐릭터 메시지 변경 ("다시 복습해봐요! 📖")

**버그 수정:**
- ✅ 성향 확인 완료 페이지 X 버튼 제거
- ✅ 퀴즈 결과 '홈으로' 버튼 → MainScreen 이동
- ✅ MainScreen 백버튼 비활성화 (PopScope)

### 수정된 파일
- `lib/screens/home/home_screen.dart`
- `lib/screens/learning/learning_screen.dart`
- `lib/screens/learning/quiz_screen.dart`
- `lib/screens/learning/quiz_result_screen.dart`

---

## 📅 2025-11-27: Firebase Authentication 구현

### 변경 내용

**Firebase 패키지 업그레이드:**
```yaml
firebase_core: ^2.27.0 → ^3.6.0
cloud_firestore: ^4.15.8 → ^5.4.4
firebase_auth: ^4.17.8 → ^5.3.1
firebase_storage: ^11.6.9 → ^12.3.4
firebase_analytics: ^10.8.9 → ^11.3.3
google_sign_in: ^6.2.1 (신규)
```

**AuthService 구현:**
- ✅ Google Sign-In 연동
- ✅ 이메일/비밀번호 회원가입/로그인
- ✅ 로그아웃
- ✅ 한국어 에러 메시지 (14종)

**플랫폼 설정:**
- ✅ Android SHA-1 지문 추가 (Google Sign-In용)
- ✅ iOS GoogleService-Info.plist 설정

### 수정된 파일
- `lib/services/auth_service.dart` (신규)
- `lib/screens/auth/login_screen.dart`
- `pubspec.yaml`

---

## 🔗 관련 커밋
- Firebase Authentication 구현 관련 커밋들

---

**작성일:** 2025-12-08
**아카이브일:** 2026-02-15
