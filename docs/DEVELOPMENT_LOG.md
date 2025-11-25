# MoneyPet 개발 로그

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

**Last Updated:** 2025-01-15
**Contributors:** Claude AI
