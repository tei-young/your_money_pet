# 🎬 머니펫 프레임 기반 애니메이션 가이드

> **최종 결정**: 통합 애니메이션 방식 (GIF/Video → PNG/WebP 프레임)
> **업데이트**: 2025-12-24 (13-state 시스템, 통합 애니메이션 방식 재설계)

---

## 📋 목차

1. [핵심 결정사항](#1-핵심-결정사항)
2. [13-State 시스템 개요](#2-13-state-시스템-개요)
3. [애니메이션 제작 워크플로우](#3-애니메이션-제작-워크플로우)
4. [폴더 구조 & 파일 규격](#4-폴더-구조--파일-규격)
5. [통합 애니메이션 상세](#5-통합-애니메이션-상세)
6. [테스트 가이드](#6-테스트-가이드)
7. [로딩 전략](#7-로딩-전략)

---

## 1. 핵심 결정사항

### ✅ 최종 스펙 (2025-12-24 재설계)

| 항목 | 스펙 | 이유 |
|------|------|------|
| **제작 도구** | Midjourney Video / Runway | AI 영상 생성, 빠른 제작 |
| **프레임 수** | 24fps | 영화급 부드러움, Rive 수준 |
| **해상도** | 600x600px | 고해상도 디바이스 대응 (Retina 3x) |
| **포맷** | WebP (권장) / PNG (지원) | WebP 40% 용량 절감 |
| **총 캐릭터** | 4개 | 머니베어, 세이브쉽, 헌터캣, 체이서폭스 |
| **총 상태** | 13개 | 통합 애니메이션 방식 (상세 아래 참고) |
| **총 용량** | 약 192MB (PNG) / 96MB (WebP) | 4 캐릭터 × 13 상태 |

### 🔄 핵심 변경: 통합 애니메이션 방식

**문제 발견:**
```
idle 애니메이션 (마지막 프레임: 포즈A)
  ↓ [전환]
thinking 애니메이션 (첫 프레임: 포즈B)

결과: 프레임 불일치로 뚝 끊기는 전환 💀
```

**해결:**
- 개별 상태 조합 방식 ❌
- **통합 애니메이션 방식** ✅
- 예: `quiz_correct_flow` = thinking → happy → idle 복귀를 **하나의 애니메이션**으로 제작

**Trade-off:**
- ✅ 장점: 완벽하게 부드러운 전환, 의도된 UX 플로우
- ❌ 단점: 용량 증가 (40MB → 192MB), 유연성 감소

**결정:** UX 우선순위로 통합 방식 채택

---

## 2. 13-State 시스템 개요

### 📊 State 체계 (카테고리별)

| 카테고리 | State | 설명 | 시간 | 프레임 | Loop | 자동전환 |
|---------|-------|------|------|--------|------|----------|
| **1. 캐릭터 선택** | `characterGreetingLoop` | 손 흔들며 인사 | 약 5초 | ~120 | ✅ | - |
| | `characterSelected` | 선택 반응 | 약 1-2초 | ~24-48 | ❌ | - |
| **2-A. 성향 퀴즈** | `personalityIdle` | 성향 문제 대기 | 약 3초 | ~72 | ✅ | - |
| | `personalitySelected` | 성향 선택 반응 | 약 2초 | ~48 | ❌ | `personalityIdle` |
| **2-B. 학습 퀴즈** | `quizIdle` | 학습 문제 대기 | 약 3초 | ~72 | ✅ | - |
| | `quizCorrectFlow` | **통합**: thinking→happy→idle | 약 4-6초 | ~96-144 | ❌ | `quizIdle` |
| | `quizWrongFlow` | **통합**: thinking→confused→idle | 약 4-6초 | ~96-144 | ❌ | `quizIdle` |
| **3. 결과 화면** | `resultCelebration` | 성향 결과 축하 | 약 3초 | ~72 | ❌ | - |
| **4. 홈 화면** | `homeIdle` | 기본 대기 (복합) | 약 5초 | ~120 | ✅ | - |
| | `homeStudying` | 책 읽기 | 약 3초 | ~72 | ✅ | - |
| | `homeExcited` | 활기찬 모습 | 약 2초 | ~48 | ✅ | - |
| | `homeSleepy` | 졸린 모습 | 약 3초 | ~72 | ✅ | - |
| | `homeCelebration` | 목표 달성 축하 | 약 2초 | ~48 | ❌ | `homeIdle` |

**합계:** 13개 상태 × 4개 캐릭터 = **52개 애니메이션**

### ⚠️ 유연한 타이밍 정책

**Before (경직적 - 기각):**
```
❌ quiz_correct_flow: 정확히 96프레임
   thinking(24프레임) + happy(48프레임) + idle복귀(24프레임)
```

**After (유연 - 채택):**
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

## 3. 애니메이션 제작 워크플로우

### 📍 Phase 1: 온보딩 애니메이션 (16개) 🎯 최우선

**제작 목록:**
- `character_greeting_loop` × 4캐릭터
- `character_selected` × 4캐릭터
- `personality_idle` × 4캐릭터
- `personality_selected` × 4캐릭터

**제작 순서 (캐릭터당):**

#### Step 1: Midjourney/Runway로 영상 생성

**1-1. character_greeting_loop (약 5초, loop)**
```
프롬프트 예시 (헌터캣):
"cute purple cat character, waving hand greeting animation,
full body, white background, flat color illustration,
children's book style, looping animation --ar 1:1 --v 6"

Motion 지시:
- 0-2초: 손 올리기
- 2-3초: 손 흔들기 (2-3회)
- 3-5초: 손 내리기
- 루프 가능하도록 시작/끝 포즈 일치
```

**1-2. character_selected (약 1-2초, one-shot)**
```
프롬프트 예시:
"cute purple cat character, happy jumping reaction,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"

Motion 지시:
- 0-0.5초: 놀란 표정
- 0.5-1.5초: 점프 + 기쁨 표현
```

**1-3. personality_idle (약 3초, loop)**
```
프롬프트 예시:
"cute purple cat character, standing idle breathing,
curious expression, full body, white background,
flat color illustration, children's book style --ar 1:1 --v 6"

Motion 지시:
- 조용한 숨쉬기 + 호기심 표정
- 미세한 움직임만 (눈 깜빡임, 귀 움직임)
- 루프 가능
```

**1-4. personality_selected (약 2초, one-shot)**
```
프롬프트 예시:
"cute purple cat character, nodding head in agreement,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"

Motion 지시:
- 0-1초: 고개 끄덕임 (2회)
- 1-2초: 원래 자세로 복귀 (personality_idle 시작 포즈와 동일!)
```

**⚠️ 중요:** `personality_selected`의 마지막 프레임은 `personality_idle`의 첫 프레임과 일치해야 부드러운 전환!

#### Step 2: ffmpeg로 프레임 추출

```bash
# MP4 → PNG 프레임 추출 (24fps, 600x600)
ffmpeg -i hunter_cat_greeting.mp4 \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  frame_%02d.png

# 실제 프레임 수 카운트
ls frame_*.png | wc -l
# 예: 125개 나옴 → JSON에 125 기록
```

#### Step 3: 배경 제거 (투명 배경)

```bash
# rembg로 배경 제거
rembg p frame_*.png output/
```

#### Step 4: WebP 변환 (용량 40% 절감)

```bash
# PNG → WebP 변환
for file in output/frame_*.png; do
  cwebp -q 85 "$file" -o "${file%.png}.webp"
done

# PNG 삭제 (WebP만 사용)
rm output/frame_*.png
```

#### Step 5: 폴더 배치

```bash
# 헌터캣 예시
cp output/frame_*.webp assets/animations/characters/hunter_cat/character_greeting_loop/
```

#### Step 6: animation_config.json 업데이트

```json
{
  "characterGreetingLoop": {
    "frameCount": 125,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사 (약 5초)"
  },
  "characterSelected": {
    "frameCount": 32,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": false,
    "description": "선택 반응 (약 1.3초)"
  },
  "personalityIdle": {
    "frameCount": 72,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": true,
    "description": "성향 문제 대기 (약 3초)"
  },
  "personalitySelected": {
    "frameCount": 48,  // ← 실제 카운트한 프레임 수
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "personalityIdle",
    "description": "성향 선택 반응 (약 2초)"
  }
}
```

#### Step 7: 테스트

```bash
flutter pub get
flutter run
```

앱에서 온보딩 플로우를 실행하여 애니메이션 확인!

---

### 📍 Phase 2: 학습 퀴즈 애니메이션 (16개)

**제작 목록:**
- `quiz_idle` × 4캐릭터
- `quiz_correct_flow` × 4캐릭터 ⭐ 통합 애니메이션
- `quiz_wrong_flow` × 4캐릭터 ⭐ 통합 애니메이션
- `result_celebration` × 4캐릭터

**제작 순서 (캐릭터당):**

#### 2-1. quiz_idle (약 3초, loop)

```
프롬프트 예시:
"cute purple cat character, thinking pose,
focused expression, full body, white background,
flat color illustration, children's book style --ar 1:1 --v 6"

Motion 지시:
- 조용한 숨쉬기 + 집중 표정
- 약간의 고민 동작 (팔짱, 턱 만지기)
- 루프 가능
```

#### 2-2. quiz_correct_flow (약 4-6초, 통합) ⭐

**⚠️ 중요: 하나의 긴 애니메이션으로 제작!**

```
프롬프트 예시:
"cute purple cat character, animation sequence:
thinking → happy jump → return to calm pose,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"

Motion 지시 (4-6초 통합):
- 0-1.5초: thinking 표정 (고민)
- 1.5-4초: happy 반응 (점프, 팔 들기, 웃음)
- 4-5초: 서서히 idle 복귀 (quiz_idle 시작 포즈와 동일!)

⚠️ 마지막 프레임 = quiz_idle 첫 프레임
```

#### 2-3. quiz_wrong_flow (약 4-6초, 통합) ⭐

```
프롬프트 예시:
"cute purple cat character, animation sequence:
thinking → confused shake head → return to calm pose,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"

Motion 지시 (4-6초 통합):
- 0-1.5초: thinking 표정 (고민)
- 1.5-4초: confused 반응 (머리 긁기, 당황)
- 4-5초: 서서히 idle 복귀 (quiz_idle 시작 포즈와 동일!)

⚠️ 마지막 프레임 = quiz_idle 첫 프레임
```

#### 2-4. result_celebration (약 3초, one-shot)

```
프롬프트 예시:
"cute purple cat character, celebration jump animation,
confetti and sparkles, full body, white background,
flat color illustration, children's book style --ar 1:1 --v 6"

Motion 지시:
- 0-1초: 깜짝 놀란 표정
- 1-2초: 점프 + 컨페티
- 2-3초: 착지 + 미소
```

---

### 📍 Phase 3: 홈 화면 애니메이션 (20개)

**제작 목록:**
- `home_idle` × 4캐릭터
- `home_studying` × 4캐릭터
- `home_excited` × 4캐릭터
- `home_sleepy` × 4캐릭터
- `home_celebration` × 4캐릭터

#### 3-1. home_idle (약 5초, loop, 복합)

**⚠️ 캐릭터 성향 표현 - 각 캐릭터마다 다름!**

**헌터캣 (공격형) 예시:**
```
프롬프트:
"cute purple cat character, idle animation with hunter personality,
sharp eyes, ear movements, wink gesture,
full body, white background --ar 1:1 --v 6"

Motion 지시 (5초 복합):
- 0-2초: 조용한 숨쉬기 (날카로운 눈빛)
- 2-3초: 윙크 (사냥꾼 본능)
- 3-4초: 귀 쫑긋 (집중력)
- 4-5초: 편안한 복귀
```

**머니베어 (안전형) 예시:**
```
Motion 지시 (5초 복합):
- 0-2초: 조용한 숨쉬기 (든든한 표정)
- 2-3초: 팔짱 끼기 (신뢰감)
- 3-4초: 고개 끄덕임 (안정감)
- 4-5초: 편안한 복귀
```

**세이브쉽 (밸런스형) 예시:**
```
Motion 지시 (5초 복합):
- 0-2초: 조용한 숨쉬기 (부드러운 표정)
- 2-3초: 고개 기울임 (조화로움)
- 3-4초: 미소 (균형감)
- 4-5초: 편안한 복귀
```

**체이서폭스 (도전형) 예시:**
```
Motion 지시 (5초 복합):
- 0-2초: 조용한 숨쉬기 (호기심 가득)
- 2-3초: 꼬리 흔들기 (영리함)
- 3-4초: 장난기 (활발함)
- 4-5초: 편안한 복귀
```

#### 3-2. home_studying (약 3초, loop)

```
프롬프트:
"cute character reading book animation,
turning pages, nodding in understanding,
full body, white background --ar 1:1 --v 6"

Motion 지시:
- 책 읽기 + 페이지 넘김 + 고개 끄덕임
```

#### 3-3. home_excited (약 2초, loop)

```
프롬프트:
"cute character excited bouncing animation,
happy energetic movement,
full body, white background --ar 1:1 --v 6"

Motion 지시:
- 통통 튀기 + 신나는 표정
```

#### 3-4. home_sleepy (약 3초, loop)

```
프롬프트:
"cute character sleepy yawning animation,
rubbing eyes, slow movements,
full body, white background --ar 1:1 --v 6"

Motion 지시:
- 하품 + 눈 비비기 + 천천히 흔들림
```

#### 3-5. home_celebration (약 2초, one-shot)

```
프롬프트:
"cute character goal achievement celebration,
jumping with confetti, victory pose,
full body, white background --ar 1:1 --v 6"

Motion 지시:
- 0-1초: 점프 + 컨페티
- 1-2초: 승리 포즈 → idle 복귀 (home_idle 시작 포즈와 동일!)
```

---

## 4. 폴더 구조 & 파일 규격

### 📁 최종 폴더 구조

```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json           (13개 상태 설정)
│   │
│   ├── character_greeting_loop/        (~120 frames)
│   │   ├── frame_01.webp
│   │   ├── frame_02.webp
│   │   └── frame_125.webp
│   │
│   ├── character_selected/             (~24-48 frames)
│   ├── personality_idle/               (~72 frames)
│   ├── personality_selected/           (~48 frames)
│   ├── quiz_idle/                      (~72 frames)
│   ├── quiz_correct_flow/              (~96-144 frames)
│   ├── quiz_wrong_flow/                (~96-144 frames)
│   ├── result_celebration/             (~72 frames)
│   ├── home_idle/                      (~120 frames)
│   ├── home_studying/                  (~72 frames)
│   ├── home_excited/                   (~48 frames)
│   ├── home_sleepy/                    (~72 frames)
│   └── home_celebration/               (~48 frames)
│
├── money_bear/                         (동일한 13개 폴더)
├── save_sheep/                         (동일한 13개 폴더)
└── chaser_fox/                         (동일한 13개 폴더)
```

### 📝 파일 네이밍 규칙

**폴더명:**
- **snake_case** (예: `character_greeting_loop/`, `quiz_correct_flow/`)
- 소문자 사용
- 언더스코어로 구분

**파일명:**
- `frame_01.webp`, `frame_02.webp`, ...
- 2자리 숫자 패딩 (01부터 시작)
- WebP 포맷 권장 (PNG도 지원)

### 📏 규격

| 항목 | 값 |
|------|-----|
| 해상도 | 600x600px |
| 프레임 레이트 | 24fps |
| 포맷 | WebP (q=85) or PNG |
| 배경 | 투명 (alpha channel) |

---

## 5. 통합 애니메이션 상세

### 🎯 왜 통합 애니메이션인가?

**문제:**
```dart
// 개별 상태 조합 방식
AnimatedCharacter(state: CharacterAnimationState.thinking)
// → thinking 애니메이션 재생 (마지막 프레임: 포즈A)

// 사용자가 정답 선택
AnimatedCharacter(state: CharacterAnimationState.happy)
// → happy 애니메이션 재생 (첫 프레임: 포즈B)

// 결과: 포즈A → 포즈B 전환 시 뚝 끊김! 💀
```

**해결:**
```dart
// 통합 애니메이션 방식
AnimatedCharacter(state: CharacterAnimationState.quizCorrectFlow)
// → thinking → happy → idle 복귀를 하나의 애니메이션으로 재생
// → 완벽하게 부드러운 전환! ✅
// → 4-6초 후 자동으로 quizIdle로 전환
```

### 📋 통합 애니메이션 목록

| State | 구성 | 시간 | 자동 전환 |
|-------|------|------|-----------|
| `quizCorrectFlow` | thinking → happy → idle | 약 4-6초 | → `quizIdle` |
| `quizWrongFlow` | thinking → confused → idle | 약 4-6초 | → `quizIdle` |
| `personalitySelected` | nod → idle | 약 2초 | → `personalityIdle` |
| `homeCelebration` | celebration → idle | 약 2초 | → `homeIdle` |

### ⚠️ 통합 애니메이션 제작 시 주의사항

**1. 마지막 프레임 = 다음 idle의 첫 프레임**
```
quiz_correct_flow의 마지막 프레임 (프레임 120)
    ↓ (완벽 일치!)
quiz_idle의 첫 프레임 (프레임 01)
```

**2. 자동 전환 설정 (JSON)**
```json
{
  "quizCorrectFlow": {
    "frameCount": 120,
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",  // ← 필수!
    "description": "정답 플로우 (약 5초)"
  }
}
```

**3. 캐릭터별 일관성**
- 4개 캐릭터 모두 같은 타이밍 구조
- 예: 모든 캐릭터의 `quiz_correct_flow`는 4-6초

---

## 6. 테스트 가이드

### ✅ Phase 1 테스트 (온보딩)

**테스트 플로우:**
```
1. 앱 실행 → 캐릭터 선택 화면
   → character_greeting_loop (4캐릭터 무한 루프 확인)

2. 헌터캣 터치
   → character_selected (1-2초 재생, 자동 종료 확인)

3. 성향 퀴즈 진행
   → personality_idle (루프 확인)
   → 선택지 터치
   → personality_selected (2초 재생 후 자동으로 personality_idle 전환 확인)
```

**체크리스트:**
- [ ] character_greeting_loop: 5초 루프, 부드러움
- [ ] character_selected: 1-2초 원샷, 깜빡임 없음
- [ ] personality_idle: 3초 루프, 자연스러움
- [ ] personality_selected: 2초 후 자동 전환 (깜빡임 없이!)

### ✅ Phase 2 테스트 (학습 퀴즈)

**테스트 플로우:**
```
1. 학습 퀴즈 화면 진입
   → quiz_idle (루프 확인)

2. 정답 선택
   → quiz_correct_flow (4-6초 재생)
   → thinking → happy → idle 전환 확인
   → 자동으로 quiz_idle 전환 확인

3. 오답 선택
   → quiz_wrong_flow (4-6초 재생)
   → thinking → confused → idle 전환 확인
   → 자동으로 quiz_idle 전환 확인
```

**체크리스트:**
- [ ] quiz_idle: 3초 루프, 집중 표정
- [ ] quiz_correct_flow: 통합 애니메이션 부드러움
- [ ] quiz_wrong_flow: 통합 애니메이션 부드러움
- [ ] 자동 전환: 깜빡임 없이 quiz_idle로 복귀

### ✅ Phase 3 테스트 (홈 화면)

**테스트 플로우:**
```
1. 홈 화면 진입
   → home_idle (5초 루프, 캐릭터 성향 표현 확인)

2. 학습 시작
   → home_studying (3초 루프)

3. 목표 달성
   → home_celebration (2초 재생)
   → 자동으로 home_idle 전환 확인
```

**체크리스트:**
- [ ] home_idle: 5초 복합, 캐릭터별 차별화
- [ ] home_studying: 3초 루프, 책 읽기 동작
- [ ] home_celebration: 2초 후 자동 전환

---

## 7. 로딩 전략 & 성능 최적화

### ✅ 구현 완료 (2026-01-14)

**애니메이션 시스템 성능 최적화:**
- ✅ **RepaintBoundary**: 애니메이션을 독립적인 렌더링 레이어로 분리
- ✅ **ValueListenableBuilder**: setState() 제거, 프레임만 업데이트 (초당 30-60회 rebuild → 0회)
- ✅ **Image 캐싱**: cacheWidth/cacheHeight로 메모리 50% 절감
- ✅ **점진적 로딩**: 첫 캐릭터 전체, 나머지 10프레임만 우선 로딩 (480 → 150프레임)

**성능 개선 효과:**
- 초기 로딩: 75% 단축 (3-5초 → 1-2초)
- 메모리 사용: 50-60% 절감
- 시뮬레이터: 30-50% 성능 향상
- 실제 기기: 10-20% 성능 향상

**구현 파일:**
- `lib/widgets/animated_character.dart` - RepaintBoundary, ValueListenableBuilder, Image 캐싱
- `lib/services/character_animation_preloader.dart` - 점진적 로딩

**상세 문서:** `performance_optimization_guide.md`

---

### 📦 Progressive Loading (단계별 로딩)

**Phase 1 애니메이션만 초기 로딩:**
```dart
// 앱 시작 시
await CharacterAnimationPreloader.loadPhase1Animations(context);
// 16개 애니메이션만 로드 (~48MB)

// 온보딩 완료 후 백그라운드 로딩
CharacterAnimationPreloader.loadPhase2Animations(context);
// 16개 애니메이션 로드 (~48MB)

// 홈 화면 진입 시
CharacterAnimationPreloader.loadPhase3Animations(context);
// 20개 애니메이션 로드 (~96MB)
```

### 🎯 로딩 우선순위

| Phase | 애니메이션 | 개수 | 용량 | 로딩 시점 |
|-------|------------|------|------|-----------|
| **Phase 1** | 온보딩 | 16개 | ~48MB | 앱 시작 |
| **Phase 2** | 학습 퀴즈 | 16개 | ~48MB | 온보딩 완료 후 |
| **Phase 3** | 홈 화면 | 20개 | ~96MB | 홈 화면 진입 시 |

### ⚡ 최적화 팁

1. **WebP 사용:** PNG 대비 40% 용량 절감
2. **Lazy Loading:** 사용하지 않는 캐릭터는 나중에 로드
3. **캐싱:** 한 번 로드한 애니메이션은 메모리에 유지

---

## 📚 관련 문서

- **작업 상세:** `docs/TODO.md` (2025-12-24 섹션)
- **개발 로그:** `docs/DEVELOPMENT_LOG.md` (2025-12-24 섹션)
- **사용법:** `assets/animations/characters/README.md`
- **전략 문서:** `docs/ANIMATION_UPDATE_2025-12-13.md`

---

**작성일:** 2025-12-13
**마지막 업데이트:** 2025-12-24 (13-state 통합 애니메이션 방식)
**작성자:** Development Team
