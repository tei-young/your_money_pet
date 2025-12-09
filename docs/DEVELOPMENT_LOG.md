# MoneyPet 개발 로그

## 📅 2024-12-09 세션: 학습 콘텐츠 타이포그래피 개선 및 마크업 시스템 구축

### 🎯 목표
학습 콘텐츠의 가독성과 강조 효과 개선, 백오피스 콘텐츠 관리 준비

---

## ✅ 완료된 작업

### 1. Pretendard 폰트 도입
**목표:** 브랜드 아이덴티티 강화 및 가독성 개선

#### 구현 내용
- **폰트 설정** (`pubspec.yaml`)
  - Pretendard Regular (W400)
  - Pretendard Medium (W500)
  - Pretendard SemiBold (W600)
  - Pretendard Bold (W700)

- **전역 폰트 적용** (`lib/utils/theme.dart`)
  - 모든 TextTheme에 `fontFamily: 'Pretendard'` 추가
  - AppBar, Button, Dialog, SnackBar 등 전체 UI 일관성 유지

- **폰트 다운로드 가이드** (`assets/fonts/README.md`)
  - Pretendard 다운로드 링크 및 설치 방법 안내

#### 디자인 결정
- **본문**: W500 (Medium) - 존재감 있으면서 편안한 가독성
- **키워드**: W700 (Bold) - 명확한 강조 효과
- **이유**: 교육 콘텐츠 특성상 장시간 읽기에 적합한 굵기

---

### 2. 콘텐츠 마크업 시스템 구축
**목표:** 백오피스에서 텍스트 서식 제어 가능하도록 확장 가능한 시스템 구축

#### 구현된 파일
1. **ContentTextRenderer** (`lib/utils/text_renderer.dart`)
   - 마크다운 스타일 마크업 파싱 및 렌더링
   - **현재 지원**: `**텍스트**` (볼드)
   - **향후 확장 준비**:
     - `[color:#HEX]텍스트[/color]` (색상)
     - `[size:크기]텍스트[/size]` (크기)
     - 복합 마크업 처리

   - **주요 메서드**:
     ```dart
     ContentTextRenderer.render(
       content,
       baseStyle: TextStyle(...),
       boldWeight: FontWeight.w700,
     )
     ```

2. **학습 화면 적용** (`lib/screens/learning/learning_screen.dart`)
   - 학습 카드 `content` 필드에 마크업 렌더링 적용
   - Tip 영역에도 마크업 렌더링 적용
   - Pretendard W500 본문 + W700 키워드

#### 사용 예시
**백오피스 입력:**
```
**예금**은 자유롭게 입출금이 가능하고, **적금**은 정해진 기간 동안 저축해요.
```

**앱 렌더링:**
- "예금", "적금" → Pretendard W700 (볼드)
- 나머지 텍스트 → Pretendard W500 (중간)

---

### 3. 백오피스 가이드 문서 작성
**목표:** 콘텐츠 관리자가 마크업을 쉽게 사용할 수 있도록 가이드 제공

#### 작성된 문서
1. **콘텐츠 마크업 가이드** (`docs/CONTENT_MARKUP_GUIDE.md`)
   - 현재 지원 문법 (볼드)
   - 향후 지원 예정 문법 (색상, 크기)
   - 실제 사용 예시 및 권장사항
   - 백오피스 구현 가이드 (3단계)
   - 기술 스펙 및 테스트 체크리스트

2. **폰트 설치 가이드** (`assets/fonts/README.md`)
   - Pretendard 다운로드 링크
   - 필요한 폰트 파일 목록
   - 설치 후 실행 방법

---

## 🏗️ 아키텍처 설계

### 확장 가능한 마크업 시스템
```
ContentTextRenderer
├── _parseContent()           // 현재: **볼드** 처리
├── _parseWithColors()        // 준비: 색상 처리
├── _parseWithSizes()         // 준비: 크기 처리
└── _parseWithAllMarkups()    // 향후: 복합 처리
```

### 백오피스 통합 로드맵
**Phase 1 (현재)**: 텍스트 입력만
- `<textarea>` 기반 입력
- 마크업 직접 작성

**Phase 2 (권장)**: 실시간 프리뷰
- 입력 영역 + 프리뷰 영역 분할
- 작성 중 실시간 렌더링 확인

**Phase 3 (향후)**: WYSIWYG 에디터
- 툴바 기반 서식 버튼
- 드래그 선택 후 클릭으로 마크업 자동 삽입
- 모바일 화면 프리뷰

---

## 📊 데이터 구조 변경 없음

### Learning Content 구조 유지
```json
{
  "content": "**예금**은 자유롭게...",  // 마크업 포함된 텍스트
  "tip": "**복리**의 힘은..."
}
```

- ✅ 기존 데이터 구조 그대로 사용
- ✅ Firebase 스키마 변경 불필요
- ✅ 백오피스 구축 시 별도 수정 불필요

---

## 🎨 디자인 개선 효과

### Before
- 시스템 기본 폰트
- Plain text only
- 강조 없음

### After
- Pretendard 폰트 (브랜드 아이덴티티)
- W500 본문 (읽기 편안)
- W700 키워드 (명확한 강조)
- 확장 가능한 서식 시스템

---

## 🔧 기술 상세

### 정규식 패턴
```dart
// 볼드 패턴 (non-greedy matching)
final boldPattern = RegExp(r'\*\*(.+?)\*\*');

// 향후 색상 패턴
final colorPattern = RegExp(r'\[color:(#[0-9A-Fa-f]{6})\](.+?)\[/color\]');
```

### TextSpan 구조
```dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: '일반 텍스트', style: baseStyle),
      TextSpan(text: '볼드 텍스트', style: baseStyle.copyWith(fontWeight: w700)),
    ],
  ),
)
```

---

## 📝 문서화

### 추가된 문서
1. `docs/CONTENT_MARKUP_GUIDE.md` - 백오피스 콘텐츠 작성 가이드
2. `assets/fonts/README.md` - Pretendard 폰트 설치 가이드
3. `lib/utils/text_renderer.dart` - 코드 내 상세 주석

### 업데이트된 문서
1. `docs/DEVELOPMENT_LOG.md` - 이 세션 기록 추가

---

## 🚀 다음 단계

### 즉시 필요
1. **Pretendard 폰트 파일 다운로드 및 추가**
   - `assets/fonts/` 디렉토리에 .otf 파일 추가
   - `flutter clean && flutter pub get` 실행

### 백오피스 구축 시
1. 콘텐츠 입력 UI 구현
2. 실시간 프리뷰 기능
3. 색상/크기 마크업 확장
4. WYSIWYG 에디터 도입

### 향후 개선 가능
1. 이탤릭, 밑줄 등 추가 서식
2. 링크, 목록 등 구조적 요소
3. 이미지 인라인 배치
4. 커스텀 컴포넌트 삽입

---

## 🐛 이슈 및 해결

### 이슈: 네트워크 제한으로 폰트 자동 다운로드 실패
**해결:**
- 폰트 다운로드 가이드 문서 작성
- 수동 다운로드 및 설치 안내

### 이슈: 폰트 파일 없이도 빌드 가능해야 함
**해결:**
- `fontFamily: 'Pretendard'` 설정 시 폰트 없으면 시스템 기본 폰트 사용
- 개발 중에도 정상 작동 보장

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

**Last Updated:** 2025-01-15
**Contributors:** Claude AI
