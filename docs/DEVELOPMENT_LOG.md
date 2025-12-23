# MoneyPet 개발 로그

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

**Last Updated:** 2025-01-15
**Contributors:** Claude AI
