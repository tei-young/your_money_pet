# 📋 MoneyPet MVP 출시 체크리스트

> MVP v1.0 실제 유저 출시를 위한 작업 목록

마지막 업데이트: 2026-01-18

---

## 🎯 MVP 출시 기준

**목표:** 최소 기능으로 실제 유저에게 학습 경험 제공
- Day 1-10 학습 콘텐츠 (4개 성향)
- 온보딩부터 학습까지 완전한 플로우
- 안정적인 데이터 저장 및 로드

---

## 🚨 Critical (필수 - MVP 출시 불가능)

### 1. 학습 콘텐츠 작성 (40개)
**상태:** 🔴 TODO
**담당:** 콘텐츠 작성 전문가
**현재:** 더미 데이터만 존재

**필요 콘텐츠:**
- Day 1-10 × 4성향 = 40개 학습 콘텐츠
- 각 콘텐츠당 3-5개 학습 카드

**성향별 주제:**
- **안전형:** 예적금, 복리, 채권 기초
- **밸런스형:** 예적금 + 펀드 입문
- **공격형:** 주식 기초, ETF
- **도전형:** 가상화폐, 고위험 투자 입문

**작성 방법:**
- 백오피스 웹에서 직접 입력
- 마크업 문법 사용 가능 (볼드, 색상, 크기 등)
- Firestore에 자동 저장

**관련 문서:**
- `docs/BACKOFFICE_DESIGN.md` - 콘텐츠 구조
- `assets/data/README.md` - 데이터 가이드

---

### 2. 퀴즈 콘텐츠 작성 (200문항)
**상태:** 🔴 TODO
**담당:** 콘텐츠 작성 전문가
**현재:** 더미 데이터만 존재

**필요 퀴즈:**
- Day 1-10 × 4성향 × 5문항 = 200개 퀴즈 문항
- 각 문항당 4개 선택지 + 해설

**요구사항:**
- 학습 내용에서 80% 이상 다룬 내용
- 난이도: 쉬움~보통
- 해설: 정답 이유를 친절하게 설명

**작성 방법:**
- 백오피스 웹에서 직접 입력
- Firestore에 자동 저장

---

### 3. 캐릭터 애니메이션 제작 (최소 16개)
**상태:** 🔴 진행 중 (hunter_cat 4/16 완료)
**담당:** 디자인팀 (Midjourney/Runway)
**우선순위:** Phase 1 온보딩 16개 최우선

**제작 물량:**
- **Phase 1 (MVP 필수):** 온보딩 4개 상태 × 4캐릭터 = 16개
  - character_greeting_loop (약 5초, loop)
  - character_selected (약 1-2초, one-shot)
  - personality_idle (약 3초, loop)
  - personality_selected (약 2초, one-shot)

- **Phase 2 (학습 기능):** 퀴즈 4개 상태 × 4캐릭터 = 16개
- **Phase 3 (홈 화면):** 홈 5개 상태 × 4캐릭터 = 20개

**현재 완료:**
- ✅ hunter_cat: 4개 상태 (character_greeting_loop, character_selected, home_idle, personality_selected 일부)
- ⚠️ 나머지 3 캐릭터: 0개

**제작 워크플로우:**
1. Midjourney/Runway로 24fps 영상 제작
2. ffmpeg로 PNG 추출 (600x600px)
3. rembg로 배경 제거
4. cwebp로 WebP 변환 (40% 용량 절감)
5. `assets/animations/characters/{캐릭터}/{상태}/` 폴더에 배치
6. `animation_config.json`에 실제 프레임 수 기록

**관련 문서:**
- `docs/FRAME_ANIMATION_GUIDE.md`
- `docs/ANIMATION_UPDATE_2025-12-13.md`
- `assets/animations/characters/README.md`

**관련 파일:**
- `assets/animations/characters/*/animation_config.json`

---

## ⚠️ Important (중요 - UX 품질에 영향)

### 4. Firestore 콘텐츠 로딩 시스템
**상태:** 🟡 부분 구현 (코드만 존재, 실제 콘텐츠 없음)
**담당:** 개발팀
**예상 소요:** 1일

**현재 상태:**
- ✅ `lib/services/learning_content_service.dart` - Firestore 연동 코드 완료
- ✅ `lib/providers/learning_provider.dart` - 더미 데이터 fallback
- 🔴 실제 Firestore에 콘텐츠 없음 (백오피스에서 작성 필요)

**구현 내용:**
- [ ] Firestore Collections 구조 확인
  - `learning_contents/{contentId}` - 학습 콘텐츠
  - `quiz_contents/{quizId}` - 퀴즈 콘텐츠
- [ ] 캐싱 전략 구현 (오프라인 대응)
- [ ] 로딩 인디케이터 UI 추가
- [ ] 네트워크 에러 핸들링
- [ ] 콘텐츠 버전 관리 (업데이트 감지)

**Security Rules 확인:**
```javascript
// 콘텐츠: 모두 읽기, 관리자만 쓰기
match /learning_contents/{contentId} {
  allow read: if true;
  allow write: if isAdmin();
}
```

**관련 문서:**
- `docs/BACKOFFICE_DESIGN.md`

**관련 파일:**
- `lib/services/learning_content_service.dart`
- `lib/providers/learning_provider.dart`
- `firestore.rules`

---

### 5. 에러 처리 개선
**상태:** 🟡 부분 구현 (일부만 처리)
**담당:** 개발팀
**예상 소요:** 1일

**현재 상태:**
- ✅ Firebase Auth 에러 (14가지 한국어 메시지)
- 🟡 네트워크 에러 (일부 화면만)
- 🔴 콘텐츠 로딩 실패 처리 미흡
- 🔴 전역 에러 핸들러 없음

**구현 내용:**
- [ ] 전역 에러 핸들러 추가 (`main.dart`)
- [ ] 네트워크 에러 감지 및 재시도 로직
- [ ] 콘텐츠 로딩 실패 시 fallback UI
- [ ] 사용자 친화적 에러 메시지 (구어체)
- [ ] 크래시 리포팅 (Firebase Crashlytics)

**에러 메시지 예시:**
- ✅ "로그인에 실패했어요. 다시 시도해주세요."
- ✅ "네트워크 연결을 확인해주세요."
- ❌ "Error: Network request failed"

**관련 파일:**
- `lib/main.dart`
- `lib/services/*.dart`

---

### 6. 통합 테스트
**상태:** 🔴 TODO
**담당:** 개발팀
**예상 소요:** 1일

**테스트 시나리오:**

**6-1. 온보딩 플로우**
- [ ] 스플래시 → 앱 소개 → 캐릭터 선택 → 성향 진단 → 로그인 → 홈
- [ ] 각 단계에서 뒤로가기 동작 확인
- [ ] 데이터 영속성 확인 (앱 재시작)

**6-2. 학습 플로우**
- [ ] 홈 → 학습 시작 → 카드 스와이프 → 퀴즈 → 결과 → 홈
- [ ] 학습 완료 후 포인트 적용 확인
- [ ] 진도 업데이트 확인

**6-3. 데이터 동기화**
- [ ] 로그인 전/후 데이터 일관성
- [ ] 여러 기기에서 동일 계정 로그인 시 동기화
- [ ] 오프라인 → 온라인 전환 시 동기화

**6-4. 에러 케이스**
- [ ] 네트워크 끊김 상태에서 앱 사용
- [ ] Firestore 콘텐츠 없을 때 동작
- [ ] 잘못된 로그인 정보
- [ ] 앱 강제 종료 후 재시작

**테스트 환경:**
- iOS Simulator
- Android Emulator
- 실제 기기 (iPhone, Android)

**관련 도구:**
- Flutter DevTools
- Firebase Console
- Xcode / Android Studio

---

## 💡 Nice-to-have (권장 - 성능 및 완성도)

### 7. WebP 변환 (애니메이션 용량 40% 절감)
**상태:** 🔴 TODO
**담당:** 디자인팀 or 개발팀
**예상 소요:** 0.5일 (스크립트 자동화)

**현재:**
- PNG: ~97KB/프레임
- 총 용량: ~192MB (52개 애니메이션 × 평균 40프레임)

**목표:**
- WebP: ~30KB/프레임 (40% 절감)
- 총 용량: ~96MB

**변환 방법:**
```bash
# 일괄 변환 스크립트
find assets/animations -name "*.png" -print0 | while IFS= read -r -d '' file; do
  cwebp -q 85 "$file" -o "${file%.png}.webp"
done
```

**코드 수정:**
- `lib/models/character_frame_animation.dart` - 파일 확장자 변경

**효과:**
- 앱 크기 50% 감소
- 초기 로딩 속도 30-40% 향상
- 메모리 사용량 감소

**관련 문서:**
- `performance_optimization_guide.md`

---

### 8. ListView 최적화
**상태:** 🔴 TODO
**담당:** 개발팀
**예상 소요:** 0.5일

**적용 대상:**
- 학습 탭 (Day 목록)
- 설정 화면 (옵션 리스트)

**최적화 내용:**
- [ ] `cacheExtent` 설정 (미리 렌더링)
- [ ] `addAutomaticKeepAlives: true` (상태 유지)
- [ ] 각 아이템에 고유 `key` 추가
- [ ] Lazy loading (필요 시)

**예시 코드:**
```dart
ListView.builder(
  cacheExtent: 100,
  addAutomaticKeepAlives: true,
  itemBuilder: (context, index) {
    return ItemWidget(
      key: ValueKey(items[index].id),
      item: items[index],
    );
  },
)
```

**효과:**
- 스크롤 부드러움 향상
- 메모리 효율 개선

**관련 파일:**
- `lib/screens/learning_tab/learning_tab_screen.dart`
- `lib/screens/settings/settings_screen.dart`

---

### 9. 사용자 피드백 수집
**상태:** 🔴 TODO
**담당:** 개발팀 + 기획팀
**예상 소요:** 1일

**구현 내용:**
- [ ] 앱 내 피드백 버튼 (설정 화면)
- [ ] Firebase Analytics 이벤트 추가
  - 화면 진입 (screen_view)
  - 학습 완료 (learning_complete)
  - 퀴즈 완료 (quiz_complete)
  - 캐릭터 선택 (character_select)
- [ ] Crashlytics 연동 (자동 크래시 리포트)
- [ ] 사용자 설문 (추후 구글 폼 링크)

**Analytics 이벤트 예시:**
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'learning_complete',
  parameters: {
    'day': 1,
    'personality': 'safe',
    'duration': 180, // 초
  },
);
```

**효과:**
- 사용자 행동 분석
- 이탈 지점 파악
- 개선 방향 도출

**관련 패키지:**
- `firebase_analytics`
- `firebase_crashlytics`

---

## 📊 진행 상황

**전체 완료율:**
```
1. 학습 콘텐츠 작성        ░░░░░░░░░░  0%
2. 퀴즈 콘텐츠 작성        ░░░░░░░░░░  0%
3. 애니메이션 제작         ██░░░░░░░░ 20% (hunter_cat 일부)
4. Firestore 로딩 시스템   ████░░░░░░ 40% (코드 완료, 콘텐츠 없음)
5. 에러 처리 개선          ███░░░░░░░ 30%
6. 통합 테스트             ░░░░░░░░░░  0%
7. WebP 변환               ░░░░░░░░░░  0%
8. ListView 최적화         ░░░░░░░░░░  0%
9. 사용자 피드백 수집      ░░░░░░░░░░  0%
────────────────────────────────────
전체 MVP 완료율:          ████░░░░░░ 36%
```

**Critical 항목 (1-3):** 7% 완료
**Important 항목 (4-6):** 23% 완료
**Nice-to-have 항목 (7-9):** 0% 완료

**✅ 최근 완료 (2026-01-18):**
- 데이터 영속성 구현 (SharedPreferences + Firestore) - 100% 완료
- 텍스트 마크업 파싱 구현 (6가지 문법) - 100% 완료

---

## ✅ 이미 완료된 작업

### 코어 기능 (개발팀)
- [x] Flutter 프로젝트 초기 설정
- [x] 온보딩 플로우 전체 (스플래시, 앱 소개, 캐릭터 선택, 성향 진단, 이름/목표 설정)
- [x] Firebase Authentication (Google + 이메일/비밀번호)
- [x] 메인 화면 (하단 탭 네비게이션)
- [x] 홈 화면 (기본 구조)
- [x] 학습 화면 (카드 스와이프)
- [x] 퀴즈 화면 (5문항 객관식)
- [x] 학습 탭 (진도 관리)
- [x] 설정 화면
- [x] 프레임 기반 애니메이션 시스템 (13-state)
- [x] 성능 최적화 (RepaintBoundary, ValueListenableBuilder, Image 캐싱)

### 디자인 (디자인팀 + 개발팀)
- [x] 다크 퍼플 테마
- [x] 성향별 컬러 시스템
- [x] 캐릭터 상호작용 UI
- [x] 말풍선 위젯
- [x] 학습/퀴즈 화면 디자인 개선

### 백오피스 (2026-01-04 완료)
- [x] Next.js 15 기반 웹 백오피스
- [x] WYSIWYG 에디터 (학습 콘텐츠)
- [x] 모바일 실시간 프리뷰
- [x] 마크업 파서 (6가지 문법)
- [x] Firestore 연동

**참고:** 백오피스는 이미 완성되어 있으므로, 콘텐츠 작성자가 바로 사용 가능

---

## 🎯 MVP 출시 조건

**최소 요구사항 (모두 완료 시 출시 가능):**
1. ⬜ Day 1-10 학습 콘텐츠 (40개) 작성 완료
2. ⬜ Day 1-10 퀴즈 (200문항) 작성 완료
3. ⬜ 온보딩 애니메이션 (16개) 제작 완료
4. ⬜ Firestore 콘텐츠 로딩 완료
5. ⬜ 통합 테스트 완료

**권장 사항 (품질 향상):**
- 에러 처리 개선
- WebP 변환
- 사용자 피드백 수집

**✅ 이미 완료 (2026-01-18):**
- 데이터 영속성 구현 (SharedPreferences + Firestore)
- 텍스트 마크업 파싱 구현 (6가지 문법)

---

## 🔗 관련 문서

- [DESIGN_DECISIONS.md](./DESIGN_DECISIONS.md) - 설계 및 기술 결정사항
- [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - 상세 개발 로그
- [BACKOFFICE_DESIGN.md](./BACKOFFICE_DESIGN.md) - 백오피스 설계
- [FRAME_ANIMATION_GUIDE.md](./FRAME_ANIMATION_GUIDE.md) - 애니메이션 가이드
- [README.md](../README.md) - 프로젝트 개요

---

**작성일:** 2026-01-18
**마일스톤:** MVP v1.0 출시
**목표 출시일:** 콘텐츠 및 애니메이션 제작 완료 후
