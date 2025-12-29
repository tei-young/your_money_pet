# 캐릭터 애니메이션 프레임

> **업데이트**: 2025-12-24 (통합 애니메이션 방식 재설계: 13개 상태)

이 폴더는 프레임 기반 캐릭터 애니메이션 파일을 저장하는 곳입니다.

## 📁 폴더 구조 (2025-12-24 재설계)

```
characters/
├── hunter_cat/              (헌터캣)
│   ├── animation_config.json  ← 프레임 수 설정 (JSON)
│   │
│   ├── character_greeting_loop/  (손 흔들며 인사, 약 5초, loop)
│   ├── character_selected/        (선택 반응, 약 1-2초, one-shot)
│   │
│   ├── personality_idle/          (성향 문제 대기, 약 3초, loop)
│   ├── personality_selected/      (성향 선택 반응, 약 2초, auto→idle)
│   │
│   ├── quiz_idle/                 (학습 문제 대기, 약 3초, loop)
│   ├── quiz_correct_flow/         (통합: thinking→happy→idle, 약 4-6초)
│   ├── quiz_wrong_flow/           (통합: thinking→confused→idle, 약 4-6초)
│   │
│   ├── result_celebration/        (성향 결과 축하, 약 3초)
│   │
│   ├── home_idle/                 (홈 대기 - 복합, 약 5초, loop)
│   ├── home_studying/             (책 읽기, 약 3초, loop)
│   ├── home_excited/              (활기참, 약 2초, loop)
│   ├── home_sleepy/               (졸림, 약 3초, loop)
│   └── home_celebration/          (목표 달성, 약 2초, auto→home_idle)
│
├── money_bear/              (머니베어, 동일한 13개 폴더)
├── save_sheep/              (세이브쉽, 동일한 13개 폴더)
└── chaser_fox/              (체이서폭스, 동일한 13개 폴더)
```

## 🎯 상태 체계 (2025-12-24 재설계 - 통합 애니메이션 방식)

### ⭐ 핵심 변경: 통합 애니메이션
**문제:** 개별 상태 조합 시 프레임 불일치로 전환이 끊김
**해결:** 화면별 통합 애니메이션 제작 (예: `quiz_correct_flow` = thinking → happy → idle 복귀를 **하나의 애니메이션**으로)

### 카테고리 1: 캐릭터 선택 화면 (2개)
- **character_greeting_loop**: 손 흔들며 인사 (약 5초, loop)
- **character_selected**: 선택됨 반응 (약 1-2초, one-shot)

### 카테고리 2-A: 성향 퀴즈 (2개)
- **personality_idle**: 성향 문제 대기 (약 3초, loop)
- **personality_selected**: 성향 선택 반응 (약 2초, one-shot, auto → personality_idle)

### 카테고리 2-B: 학습 퀴즈 (3개) ⭐ 통합 애니메이션
- **quiz_idle**: 학습 문제 대기 (약 3초, loop)
- **quiz_correct_flow**: thinking → happy → idle 복귀 (약 4-6초, auto → quiz_idle)
- **quiz_wrong_flow**: thinking → confused → idle 복귀 (약 4-6초, auto → quiz_idle)

### 카테고리 3: 결과 화면 (1개)
- **result_celebration**: 성향 결과 축하 (약 3초, one-shot)

### 카테고리 4: 홈 화면 (5개)
- **home_idle**: 기본 대기 - 복합 애니메이션 (약 5초, loop, 캐릭터 성향 표현)
- **home_studying**: 책 읽기 (약 3초, loop)
- **home_excited**: 활기찬 모습 (약 2초, loop)
- **home_sleepy**: 졸린 모습 (약 3초, loop)
- **home_celebration**: 목표 달성 (약 2초, one-shot, auto → home_idle)

**총 13개 상태 × 4개 캐릭터 = 52개 애니메이션**

## 📝 파일 네이밍 규칙

각 상태 폴더 안에 프레임 파일을 배치하세요:

```
frame_01.webp
frame_02.webp
frame_03.webp
...
```

**중요:**
- 폴더명: **snake_case** (예: `character_greeting_loop/`, `quiz_correct_flow/`)
- 파일명: 반드시 `frame_01.webp` 형식 (2자리 숫자, 01부터 시작)
- 소문자 사용
- WebP 포맷 권장 (PNG도 지원, 투명 배경 보장)

## 🎬 사용 방법

### 1. Midjourney/Runway로 영상 생성

```
프롬프트 예시:
"cute purple cat character, waving hand greeting,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"
```

**중요:** 정확한 프레임 수는 제작 후 확정됩니다. "약 X초" 목표로 제작하세요.

### 2. ffmpeg로 프레임 추출

```bash
# MP4 → PNG 프레임 추출 (24fps, 600x600)
ffmpeg -i hunter_cat_greeting.mp4 \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  frame_%02d.png

# 실제 프레임 수 카운트
ls frame_*.png | wc -l
# 예: 125개 나옴
```

**옵션 설명:**
- `fps=24`: 24fps (부드러움)
- `scale=600:600`: 고해상도 (Retina 대응)
- `flags=lanczos`: 고품질 리샘플링
- `frame_%02d.png`: 2자리 패딩 (01, 02, ...)

### 3. 배경 제거 (rembg)

```bash
# PNG 배경 제거 (투명 배경)
rembg p frame_*.png output/
```

### 4. WebP 변환 (용량 40% 절감)

```bash
# PNG → WebP 변환
for file in output/frame_*.png; do
  cwebp -q 85 "$file" -o "${file%.png}.webp"
done

# PNG 삭제 (WebP만 사용)
rm output/frame_*.png
```

### 5. animation_config.json 업데이트 (필수!)

프레임 수를 코드 수정 없이 JSON에 기록:

```json
{
  "characterGreetingLoop": {
    "frameCount": 125,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사 (약 5초)"
  },
  "quizCorrectFlow": {
    "frameCount": 110,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",  // ← 자동 전환
    "description": "정답 플로우 (약 4-6초): thinking → happy → idle"
  }
}
```

**⚠️ 유연한 타이밍 정책:**
- "정확히 96프레임" ❌ → "약 4-6초" ✅
- Midjourney/Runway는 정확한 프레임 수 통제 불가
- 제작 후 실제 프레임 수를 JSON에 기록

### 6. 폴더에 배치

```
assets/animations/characters/hunter_cat/
├── character_greeting_loop/
│   ├── frame_01.webp
│   ├── frame_02.webp
│   └── frame_125.webp  (실제 프레임 수)
├── quiz_correct_flow/
│   ├── frame_01.webp
│   └── frame_110.webp  (실제 프레임 수)
└── ...
```

### 7. flutter pub get 실행

```bash
flutter pub get
```

### 8. 앱에서 확인

프레임 파일을 배치하면 자동으로 AnimatedCharacter 위젯이 사용합니다!

```dart
AnimatedCharacter(
  characterType: PersonalityType.aggressive, // 헌터캣
  state: CharacterAnimationState.quizCorrectFlow,
  size: 200,
)
// → 4-6초 재생 후 자동으로 quizIdle로 전환
```

## ⚠️ 주의사항

- **폴더명:** snake_case (예: `quiz_correct_flow/`)
- **파일명:** `frame_01.webp` (2자리 패딩, 01부터)
- **프레임 수:** 제작 후 실제 프레임 수를 JSON에 기록
- **자동 전환:** `autoTransitionTo` 필드 활용
- 프레임 파일이 없으면 Placeholder(이모지 원)가 표시됩니다
- 파일 추가 후 반드시 `flutter pub get` 실행

## 📊 제작 우선순위

**Phase 1: 온보딩 (16개) 🎯 최우선**
- character_greeting_loop (4캐릭터)
- character_selected (4캐릭터)
- personality_idle (4캐릭터)
- personality_selected (4캐릭터)

**Phase 2: 학습 퀴즈 (16개)**
- quiz_idle, quiz_correct_flow, quiz_wrong_flow, result_celebration (각 4캐릭터)

**Phase 3: 홈 화면 (20개)**
- home_idle, home_studying, home_excited, home_sleepy, home_celebration (각 4캐릭터)

## 📚 상세 가이드

- 전체 제작 워크플로우: `docs/FRAME_ANIMATION_GUIDE.md`
- 코드 작업 상세: `docs/TODO.md` (2025-12-24 섹션)
- 개발 로그: `docs/DEVELOPMENT_LOG.md` (2025-12-24 섹션)
