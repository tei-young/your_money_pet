# 캐릭터 애니메이션 전략 변경

> **최초 작성**: 2025-12-13
> **마지막 업데이트**: 2025-12-24 (통합 애니메이션 방식 재설계: 10개 → 13개 상태)

## 🎯 핵심 결정

### **Rive → 프레임 기반 (GIF/Video → PNG/WebP 추출)**

| 항목 | 이전 (Rive) | 현재 (프레임 기반) |
|------|------------|-------------------|
| **제작 도구** | Rive Editor | Midjourney Video |
| **파일 포맷** | .riv (벡터) | PNG/WebP (래스터, 압축) |
| **파일 크기** | 200KB-1MB | 12MB (PNG) / 6MB (WebP) |
| **제작 난이도** | 높음 (리깅 필요) | 낮음 (AI 자동 생성) |
| **제작 비용** | $500-2000 | $12/월 (Midjourney) |
| **제작 시간** | 1-2주 | 1-2일 |
| **인터랙티브** | ✅ 완벽 | ✅ 완벽 |
| **해상도** | 벡터 (무한 확대) | 600px (고해상도 대응) |
| **부드러움** | ✅ 완벽 | ✅ 24fps (Rive 수준) |

### **왜 변경했나?**

1. ✅ **빠른 제작**: Midjourney로 1-2일이면 완성
2. ✅ **저렴한 비용**: $12/월 (Rive 외주 대비 1/40)
3. ✅ **테스트 용이**: 다양한 fps 실험 가능
4. ✅ **퀄리티 보장**: 24fps + 600px로 Rive 수준 달성

---

## 📊 최종 스펙 (2025-12-24 업데이트)

```
제작 도구:  Midjourney Video
프레임 수:   24fps (영화급 부드러움)
해상도:      600x600px (Retina 3x 대응)
포맷:        PNG (현재) / WebP (추후 변환 가능)
상태 수:     13개 (통합 애니메이션 방식)
총 용량:     약 192MB (PNG) / 96MB (WebP 변환 시)
총 애니메이션: 52개 (4캐릭터 × 13상태)
```

**주요 변경 (2025-12-24):**
- ✅ **통합 애니메이션 방식**: quiz_correct_flow = thinking → happy → idle 복귀를 하나의 애니메이션으로 제작
- ✅ **유연한 타이밍 정책**: "정확히 XX프레임" → "약 X초" (Midjourney/Runway 특성 고려)
- ✅ **자동 전환**: personalitySelected → personalityIdle (자동 복귀)

**포맷 선택:**
- ✅ **PNG**: 현재 지원 중 (추출 간편, 투명 배경 보장)
- 🔄 **WebP**: 추후 변환 가능 (용량 50% 절감)

---

## ✅ 완료된 작업

### **개발팀 (2025-12-13)**
- [x] `CharacterFrameAnimation` 모델 생성
- [x] `AnimatedCharacter` 위젯 전면 수정
- [x] `CharacterAnimationPreloader` 서비스 생성
- [x] 점진적 로딩 전략 구현

### **개발팀 (2025-12-16 - JSON 설정 시스템 구축)**
- [x] `AnimationConfigLoader` 서비스 생성 (JSON 로딩 및 캐싱)
- [x] `animation_config.json` 파일 4개 생성 (캐릭터별)
- [x] `CharacterFrameAnimation.forStateAsync()` 추가 (JSON 기반)
- [x] `AnimatedCharacter` async 로딩 지원
- [x] 코드 수정 없이 프레임 수 변경 가능

### **개발팀 (2025-12-19 - PNG 지원 및 버그 수정)**
- [x] PNG 포맷 지원 (`.webp` → `.png`)
- [x] 상태 전환 시 에러 방지 로직 추가
- [x] Placeholder fallback 개선 (불필요한 로드 방지)
- [x] **AnimationController 크래시 수정** (치명적 버그)
  - SingleTickerProviderStateMixin → TickerProviderStateMixin
  - Controller 재사용 패턴 도입
  - idle ↔ selected 전환 안정화
- [x] **Placeholder 깜빡임 제거**
  - 상태 전환 시 애니메이션 프레임 유지
  - 부드러운 전환 효과
- [x] **온보딩 화면 캐릭터 크기 증가**
  - 캐릭터 선택 화면: 100 → 180 (1.8배)
  - 성향 결과 화면: 150 → 270 (1.8배)
  - 성향 테스트 화면: 80 → 160 (2배)
  - 애니메이션 시각적 임팩트 향상
- [x] **캐릭터 선택 화면 오버플로우 수정**
  - 패딩 및 간격 조정으로 레이아웃 최적화
  - 캐릭터 크기 180px 유지
- [x] **성향 테스트 화면 레이아웃 위치 조정**
  - 캐릭터와 질문을 116px 위로 이동
  - 전체 콘텐츠 가시성 향상
- [x] 실제 프레임 파일 테스트 완료 (hunter_cat idle/selected)

### **개발팀 (2025-12-23 - 애니메이션 상태 체계 재설계)**
- [x] **애니메이션 상태 시스템 재설계 (5개 → 10개)**
  - 기존 "idle" → "greeting"으로 재정의 (손 흔들며 인사)
  - 새로운 "idle" 개념 추가 (조용한 대기, 5초 복합 애니메이션)
  - 홈 화면 전용 상태 4개 추가
- [x] **CharacterAnimationState enum 확장** (8개 → 14개 상태)
  - 카테고리 1: 캐릭터 선택 화면 (greeting, selected)
  - 카테고리 2: 범용 상태 (idle, thinking, happy, confused)
  - 카테고리 3: 홈 화면 전용 (homeStudying, homeExcited, homeSleepy, homeCelebration)
- [x] **애니메이션 프리셋 업데이트** (CharacterFrameAnimation.forState)
  - 10개 상태별 프레임 수 및 지속 시간 설정
  - loop 설정 (greeting/idle/home: true, selected/happy/confused: false)
- [x] **폴더 구조 재편**
  - 기존 `idle/` 폴더 → `greeting/` 폴더로 이름 변경 (git mv)
  - 새로운 폴더 생성: `idle/`, `home_studying/`, `home_excited/`, `home_sleepy/`, `home_celebration/`
  - 4개 캐릭터 × 5개 폴더 = 20개 폴더 생성
- [x] **animation_config.json 업데이트**
  - 4개 캐릭터 설정 파일 전체 재작성
  - 10개 상태별 frameCount, frameDuration, loop, description 설정
- [x] **pubspec.yaml 업데이트**
  - 40개 애니메이션 폴더 경로 등록 (4캐릭터 × 10상태)
- [x] **화면별 상태 적용**
  - 캐릭터 선택 화면: idle → greeting
  - 성향 테스트 화면: idle → thinking
  - 프리로더: idle → greeting
- [x] **문서 업데이트**
  - DEVELOPMENT_LOG.md: 2025-12-23 섹션 추가
  - TODO.md: 10-state 시스템 반영
  - FRAME_ANIMATION_GUIDE.md: 전체 재작성
  - characters/README.md: 폴더 구조 및 사용법 업데이트
  - README.md: 애니메이션 섹션 업데이트

### **개발팀 (2025-12-24 - 통합 애니메이션 방식 재설계: 13-State)**
- [x] **CharacterAnimationState enum 재설계** (14개 → 13개) - Commit: 1695ecc
  - 삭제: thinking, happy, confused, reactionPositive/Negative/Neutral (6개)
  - 추가: personalityIdle, personalitySelected, quizIdle, quizCorrectFlow, quizWrongFlow, resultCelebration (6개)
  - 이름 변경: greeting → characterGreetingLoop, selected → characterSelected, idle → homeIdle (3개)
  - 통합 애니메이션 방식 적용 (quiz_correct_flow = thinking→happy→idle 복귀)
- [x] **Enum → 폴더명 변환 로직 구현** - Commit: 5e2f0b3
  - _stateToFolderName() 헬퍼 함수 추가 (camelCase → snake_case)
  - getFramePath() 메서드 업데이트 (올바른 경로 생성)
  - forState() fallback 메서드 13개 상태로 재작성
- [x] **자동 전환 로직 구현** - Commit: a6c6108
  - CharacterFrameAnimation에 autoTransitionTo 필드 추가
  - AnimationConfigLoader에서 JSON autoTransitionTo 읽기 지원
  - AnimatedCharacter에 자동 전환 처리 로직 구현
  - personalitySelected → personalityIdle 자동 전환
  - quizCorrectFlow/quizWrongFlow → quizIdle 자동 전환
- [x] **폴더 구조 재편 (13-State)** - Commit: 088b510, 75264c1
  - 이름 변경: greeting/ → character_greeting_loop/, selected/ → character_selected/
  - 삭제: idle/, thinking/, happy/, confused/ (12개 .gitkeep)
  - 신규 생성: personality_idle/, personality_selected/, quiz_idle/, quiz_correct_flow/, quiz_wrong_flow/, result_celebration/, home_idle/ (각 캐릭터별 7개)
  - 최종 결과: 4개 캐릭터 × 13개 상태 = 52개 폴더

### **2. 폴더 구조 (2025-12-24 업데이트 - 13-State)**
```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json           ← JSON 설정 (13개 상태)
│   ├── character_greeting_loop/        (손 흔들며 인사, 약 5초, loop)
│   ├── character_selected/             (선택 반응, 약 1-2초, one-shot)
│   ├── personality_idle/               (성향 퀴즈 대기, 약 3초, loop)
│   ├── personality_selected/           (성향 선택 반응, 약 2초, auto→personalityIdle)
│   ├── quiz_idle/                      (학습 퀴즈 대기, 약 3초, loop)
│   ├── quiz_correct_flow/              (통합: thinking→happy→idle, 약 5초, auto→quizIdle)
│   ├── quiz_wrong_flow/                (통합: thinking→confused→idle, 약 5초, auto→quizIdle)
│   ├── result_celebration/             (결과 축하, 약 3초, one-shot)
│   ├── home_idle/                      (홈 기본 대기, 약 5초, loop)
│   ├── home_studying/                  (책 읽기, 약 3초, loop)
│   ├── home_excited/                   (활기참, 약 2초, loop)
│   ├── home_sleepy/                    (졸림, 약 3초, loop)
│   └── home_celebration/               (목표 달성, 약 2초, auto→homeIdle)
├── money_bear/                         (동일한 13개 폴더)
├── save_sheep/                         (동일한 13개 폴더)
└── chaser_fox/                         (동일한 13개 폴더)
```

**폴더명 규칙 (2025-12-24):**
- snake_case 사용 (예: `character_greeting_loop/`, `quiz_correct_flow/`)
- camelCase enum → snake_case 폴더명 자동 변환

### **3. 문서화**
- [x] `docs/FRAME_ANIMATION_GUIDE.md` (전체 가이드)
- [x] `assets/animations/characters/README.md` (사용법)

### **4. Fallback 로직**
- 프레임 파일 없으면 Placeholder (이모지 원) 표시
- 개발 중에도 앱 정상 작동

---

## 🎬 다음 단계 (디자인팀)

### **Phase 1: 헌터캣 Greeting/Selected 테스트** ✅ 완료

1. Midjourney로 헌터캣 베이스 이미지 생성
2. Midjourney Video로 Greeting 영상 생성 (손 흔들며 인사, 5.2초)
3. ffmpeg로 125프레임 PNG 추출:
   ```bash
   ffmpeg -i hunter_cat_greeting.mp4 \
     -vf "fps=24,scale=600:600:flags=lanczos" \
     assets/animations/characters/hunter_cat/greeting/frame_%02d.png
   ```
4. Selected 영상 생성 및 추출 (20프레임)
5. `flutter pub get` 실행
6. 앱에서 확인 ✅

### **Phase 2: 전체 제작 (2025-12-24 업데이트 - 13-State)**

**현재 상태:**
- ✅ 완료: 2개 (헌터캣 character_greeting_loop, character_selected)
- 🔴 필요: 50개 남음

**제작 계획 (통합 애니메이션 방식):**
- 나머지 11개 상태 제작 (헌터캣: personality_idle, personality_selected, quiz_idle, quiz_correct_flow, quiz_wrong_flow, result_celebration, home_idle, home_studying, home_excited, home_sleepy, home_celebration)
- 나머지 3개 캐릭터 × 13개 상태 = 39개
- **총 52개 애니메이션 완성** (현재 2/52 완료)

**우선순위:**
1. **Phase 1 (온보딩)**: character_greeting_loop, character_selected, personality_idle, personality_selected (4개 × 4캐릭터 = 16개)
2. **Phase 2 (학습 퀴즈)**: quiz_idle, quiz_correct_flow, quiz_wrong_flow, result_celebration (4개 × 4캐릭터 = 16개)
3. **Phase 3 (홈 화면)**: home_idle, home_studying, home_excited, home_sleepy, home_celebration (5개 × 4캐릭터 = 20개)

---

## 📝 사용 방법 (디자인팀용)

### **1. JSON 설정 수정 (프레임 수 변경 - 2025-12-24 업데이트)**

**영상 길이가 다른 경우:**
```bash
# 1. animation_config.json 파일 열기
vim assets/animations/characters/hunter_cat/animation_config.json

# 2. frameCount 수정 (13개 상태 예시)
{
  "characterGreetingLoop": {
    "frameCount": 120,  # 약 5초 영상 (실제 프레임 수는 제작 후 확정)
    "frameDuration": 42,
    "loop": true,
    "description": "손 흔들며 인사"
  },
  "personalitySelected": {
    "frameCount": 48,   # 약 2초 영상
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "personalityIdle",  # ← 자동 전환!
    "description": "성향 선택 반응"
  },
  "quizCorrectFlow": {
    "frameCount": 120,  # 약 5초 영상 (통합 애니메이션)
    "frameDuration": 42,
    "loop": false,
    "autoTransitionTo": "quizIdle",  # ← 자동 전환!
    "description": "정답 플로우: thinking→happy→idle"
  },
  "homeStudying": {
    "frameCount": 72,   # 약 3초 영상
    "frameDuration": 42,
    "loop": true,
    "description": "책 읽기"
  }
  // ... 나머지 9개 상태
}

# 3. 앱 재실행 → 자동 적용 ✅
```

**신규 기능 (2025-12-24):**
- ✅ **autoTransitionTo**: 애니메이션 완료 후 자동으로 다음 상태로 전환
- ✅ **유연한 타이밍**: "약 X초"로 명시, 정확한 프레임 수는 제작 후 조정

**장점:**
- ✅ 코드 수정 불필요
- ✅ 디자이너가 직접 수정 가능
- ✅ 캐릭터별 독립적 설정

---

### **2. 프레임 파일 생성**

**방법 1: PNG 추출 (권장, 현재 지원)**
```bash
# Midjourney에서 다운로드한 GIF/MP4를 PNG 프레임으로 추출
ffmpeg -i input.mp4 \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  frame_%02d.png
```

**방법 2: WebP 변환 (용량 절감, 추후)**
```bash
# PNG → WebP 변환 (50% 용량 절감)
for file in frame_*.png; do
  ffmpeg -i "$file" -quality 90 "${file%.png}.webp"
done

# 코드도 .png → .webp로 변경 필요
# lib/models/character_frame_animation.dart:28
```

**옵션 설명:**
- `fps=24`: 24fps (부드러움)
- `scale=600:600`: 고해상도
- `flags=lanczos`: 고품질 리샘플링
- `quality=90`: WebP 품질 (90 = 거의 무손실, WebP 전용)

### **3. 폴더에 배치**

```
assets/animations/characters/hunter_cat/character_greeting_loop/
├── frame_01.png
├── frame_02.png
└── frame_120.png  (약 5초 = ~120프레임)

assets/animations/characters/hunter_cat/quiz_correct_flow/
├── frame_01.png
├── frame_02.png
└── frame_120.png  (통합 애니메이션: thinking→happy→idle)

assets/animations/characters/hunter_cat/home_idle/
├── frame_01.png
├── frame_02.png
└── frame_120.png  (약 5초 복합 애니메이션)
```

**중요 (2025-12-24 업데이트):**
- 파일명: 반드시 `frame_01.png` 형식 (01부터, 2자리 패딩)
- 폴더명: snake_case (예: `character_greeting_loop/`, `quiz_correct_flow/`)
- 프레임 수: 제작 후 실제 프레임 수에 맞춰 JSON 수정

### **4. flutter pub get 실행**

```bash
cd your_money_pet
flutter pub get
```

### **5. 앱에서 자동 적용**

프레임 파일만 배치하면 AnimatedCharacter 위젯이 자동으로 사용합니다!

**테스트 결과 (2025-12-24 업데이트):**
- ✅ hunter_cat character_greeting_loop: 125프레임 정상 재생 (loop)
- ✅ hunter_cat character_selected: 20프레임 one-shot 재생
- 🔴 나머지 11개 상태: placeholder 표시 (제작 대기)
- ✅ 다른 캐릭터: placeholder 안전하게 표시
- ✅ 자동 전환 로직: 정상 작동 (personalitySelected → personalityIdle)

---

## 🔧 개발자 노트

### **자동 적용 메커니즘 (2025-12-24 업데이트)**

```dart
AnimatedCharacter(
  characterType: PersonalityType.aggressive, // 헌터캣
  state: CharacterAnimationState.homeIdle,
  size: 200,
)
```

위 코드는 자동으로:
1. `assets/animations/characters/hunter_cat/home_idle/` 폴더에서 프레임 로드 (snake_case 자동 변환)
2. 24fps로 재생 (CharacterFrameAnimation 프리셋 기준)
3. 루프 재생 (homeIdle은 loop: true)
4. 프레임 없으면 Placeholder 표시

**신규 기능 (2025-12-24):**
- ✅ **자동 전환**: personalitySelected 완료 후 자동으로 personalityIdle로 전환
- ✅ **통합 애니메이션**: quizCorrectFlow = thinking→happy→idle 복귀가 하나의 애니메이션으로
- ✅ **camelCase → snake_case**: enum 이름이 자동으로 폴더명으로 변환

---

## 📚 관련 문서

- **전체 가이드**: `docs/FRAME_ANIMATION_GUIDE.md`
- **사용법**: `assets/animations/characters/README.md`
- **TODO 업데이트**: `docs/TODO.md`
- **개발 로그**: `docs/DEVELOPMENT_LOG.md`

---

**작성일**: 2025-12-13
**작성자**: Development Team
**상태**: 코드 구현 완료, 애니메이션 제작 대기
