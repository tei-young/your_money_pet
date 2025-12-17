# 🎬 머니펫 프레임 기반 애니메이션 가이드

> **최종 결정**: GIF/Video → PNG 프레임 추출 방식
> **업데이트**: 2025-12-13

---

## 📋 목차

1. [핵심 결정사항](#1-핵심-결정사항)
2. [애니메이션 제작 워크플로우](#2-애니메이션-제작-워크플로우)
3. [폴더 구조 & 파일 규격](#3-폴더-구조--파일-규격)
4. [코드 구현](#4-코드-구현)
5. [테스트 가이드](#5-테스트-가이드)
6. [로딩 전략](#6-로딩-전략)

---

## 1. 핵심 결정사항

### ✅ 최종 스펙 (2025-12-16 업데이트)

| 항목 | 스펙 | 이유 |
|------|------|------|
| **제작 도구** | Midjourney (Video) | 구독 플랜에서 영상 생성 가능 |
| **프레임 수** | 24fps | 영화급 부드러움, Rive 수준 |
| **해상도** | 600x600px | 고해상도 디바이스 대응 (Retina 3x) |
| **포맷** | WebP | 용량 50% 절감, PNG 대비 효율적 |
| **총 캐릭터** | 4개 | 머니베어, 세이브쉽, 헌터캣, 체이서폭스 |
| **총 상태** | 5개 | Idle, Selected, Happy, Thinking, Confused |
| **총 용량** | 약 12MB | 4 캐릭터 × 5 상태 × 평균 24프레임 (WebP 압축) |

### ✅ 필수 조건 충족

| 조건 | 충족 여부 |
|------|-----------|
| 1. 인터랙티브 (터치, 상태 전환) | ✅ 완벽 지원 |
| 2. 자연스러운 움직임 | ✅ 24fps (Rive 수준 부드러움) |
| 3. 높은 해상도 | ✅ 600px (고해상도 완벽 대응) |

---

## 2. 애니메이션 제작 워크플로우

### **Step 1: Midjourney로 베이스 이미지 생성**

각 캐릭터당 1개의 고품질 정지 이미지

**프롬프트 예시 (헌터캣):**
```
cute purple cat character, standing idle pose,
full body, white background, flat color illustration,
children's book style, simple and clean design,
front view, kawaii style --ar 1:1 --v 6
```

**생성 결과:**
```
hunter_cat_base.png
money_bear_base.png
save_sheep_base.png
chaser_fox_base.png
```

---

### **Step 2: Midjourney Video로 애니메이션 생성**

베이스 이미지를 기반으로 각 상태별 영상 생성

**상태별 Motion 지시:**

#### **Idle (숨쉬기)**
```
Motion: gentle breathing motion, subtle up and down movement,
calm and peaceful, looping animation

길이: 1초 (24 frames @ 24fps)
루프: Yes
```

#### **Selected (손 흔들기)**
```
Motion: excited waving motion, jumping slightly,
happy greeting gesture, energetic movement

길이: 0.8초 (20 frames @ 24fps)
루프: No (one-shot)
```

#### **Happy (점프)**
```
Motion: jump up and down with joy,
celebratory bounce, stars or sparkles effect

길이: 1.2초 (30 frames @ 24fps)
루프: No
```

#### **Thinking (고민)**
```
Motion: tilting head left and right,
thoughtful expression, slow contemplative motion

길이: 1초 (24 frames @ 24fps)
루프: Yes
```

#### **Confused (혼란)**
```
Motion: slight wobble, question mark appearing,
confused head shake, uncertain movement

길이: 0.8초 (20 frames @ 24fps)
루프: No
```

---

### **Step 3: 프레임 추출 (ffmpeg)**

Midjourney에서 다운로드한 영상을 PNG 프레임으로 추출

**설치:**
```bash
# Mac
brew install ffmpeg

# Windows
https://ffmpeg.org/download.html
```

**추출 명령어 (권장: 24fps, 600x600, WebP):**
```bash
# GIF → WebP 프레임 추출 (한 번에 처리)
ffmpeg -i hunter_cat_idle.gif \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  -quality 90 \
  -start_number 1 \
  assets/animations/characters/hunter_cat/idle/frame_%02d.webp

# MP4 → WebP 프레임 추출
ffmpeg -i hunter_cat_idle.mp4 \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  -quality 90 \
  -start_number 1 \
  assets/animations/characters/hunter_cat/idle/frame_%02d.webp

# 결과:
# frame_01.webp, frame_02.webp, ..., frame_24.webp
```

**옵션 설명:**
- `fps=24`: 24fps로 추출 (영화급 부드러움)
- `scale=600:600`: 고해상도 (Retina 3x 대응)
- `flags=lanczos`: 고품질 리샘플링
- `quality=90`: WebP 품질 (90 = 거의 무손실)

**2단계 방식 (PNG → WebP):**
```bash
# 1단계: GIF → PNG 추출
ffmpeg -i idle.gif -vf "fps=24,scale=600:600:flags=lanczos" frame_%02d.png

# 2단계: PNG → WebP 변환 (일괄)
for file in frame_*.png; do
  ffmpeg -i "$file" -quality 90 "${file%.png}.webp"
done

# 3단계: PNG 삭제 (선택사항)
rm frame_*.png
```

---

### **Step 4: 폴더 배치 (자동 적용)**

추출한 프레임을 아래 폴더 구조에 맞게 배치하면 **자동으로 앱에 적용됩니다.**

```
assets/animations/characters/
└── hunter_cat/
    └── idle/
        ├── frame_01.webp
        ├── frame_02.webp
        └── ... (프레임 수만큼)
```

**중요:** 파일명은 반드시 `frame_01.webp`, `frame_02.webp` 형식!

---

### **Step 5: JSON 설정 파일 수정 (선택사항)**

각 캐릭터 폴더의 `animation_config.json` 파일에서 **프레임 수를 코드 수정 없이 변경**할 수 있습니다.

**animation_config.json 예시:**
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

**변경 방법:**
1. `assets/animations/characters/hunter_cat/animation_config.json` 열기
2. `frameCount` 값 수정 (예: 24 → 125)
3. `flutter pub get` 실행 (선택)
4. 앱 재실행 → 자동 적용 ✅

**장점:**
- ✅ 코드 수정 불필요
- ✅ 디자이너가 직접 수정 가능
- ✅ 캐릭터별 독립적 설정
- ✅ 영상 길이가 달라도 유연하게 대응

---

## 3. 폴더 구조 & 파일 규격

### **최종 폴더 구조**

```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json  ← 프레임 수 설정
│   ├── idle/                  (24 frames, 1초 루프)
│   │   ├── frame_01.webp
│   │   ├── frame_02.webp
│   │   └── frame_24.webp
│   ├── selected/              (20 frames, 0.8초 one-shot)
│   │   └── ...
│   ├── happy/                 (30 frames, 1.2초 one-shot)
│   │   └── ...
│   ├── thinking/              (24 frames, 1초 루프)
│   │   └── ...
│   └── confused/              (20 frames, 0.8초 one-shot)
│       └── ...
│
├── money_bear/
│   ├── idle/
│   ├── selected/
│   └── ...
│
├── save_sheep/
│   └── ...
│
└── chaser_fox/
    └── ...
```

### **파일 네이밍 규칙**

```
형식: frame_{number}.png
예시:
- frame_01.png
- frame_02.png
- frame_12.png

⚠️ 주의:
- 반드시 2자리 숫자 (01, 02, ..., 12)
- 소문자 사용
- PNG 포맷
```

### **캐릭터 ID 매핑**

| 캐릭터 | 폴더명 | PersonalityType |
|--------|--------|-----------------|
| 머니베어 | `money_bear` | `safe` |
| 세이브쉽 | `save_sheep` | `balanced` |
| 헌터캣 | `hunter_cat` | `aggressive` |
| 체이서폭스 | `chaser_fox` | `challenger` |

---

## 4. 코드 구현

### **4.1. CharacterFrameAnimation 모델**

**위치:** `lib/models/character_frame_animation.dart`

프레임 경로, fps, 루프 설정 관리

**주요 기능:**
- 상태별 프레임 수 자동 감지
- 경로 자동 생성
- fps 설정

**코드:**
```dart
class CharacterFrameAnimation {
  final String characterId;
  final CharacterAnimationState state;
  final int frameCount;
  final Duration frameDuration;
  final bool loop;

  String getFramePath(int frameIndex) {
    final stateFolder = state.name;
    final frameNumber = (frameIndex + 1).toString().padLeft(2, '0');
    return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.png';
  }
}
```

---

### **4.2. AnimatedCharacter 위젯**

**위치:** `lib/widgets/animated_character.dart`

프레임 시퀀스 재생 및 인터랙티브 처리

**주요 기능:**
- AnimationController로 프레임 전환
- 터치 인터랙티브 지원
- 상태 변경 시 자동 재생
- onAnimationComplete 콜백

**사용 예시:**
```dart
AnimatedCharacter(
  characterType: PersonalityType.aggressive, // 헌터캣
  state: CharacterAnimationState.idle,
  size: 200,
  onAnimationComplete: () {
    print('애니메이션 완료!');
  },
)
```

---

### **4.3. CharacterAnimationPreloader 서비스**

**위치:** `lib/services/character_animation_preloader.dart`

프레임 이미지 사전 로딩

**주요 기능:**
- `loadAllIdleStates()`: 4개 캐릭터 Idle 로딩
- `loadCharacterAllStates()`: 특정 캐릭터 전체 상태 로딩
- 점진적 로딩 지원

---

### **4.4. pubspec.yaml 설정**

프레임 이미지 등록

```yaml
flutter:
  assets:
    # 캐릭터 애니메이션 프레임
    - assets/animations/characters/hunter_cat/idle/
    - assets/animations/characters/hunter_cat/selected/
    - assets/animations/characters/hunter_cat/happy/
    - assets/animations/characters/hunter_cat/thinking/
    - assets/animations/characters/hunter_cat/confused/

    - assets/animations/characters/money_bear/idle/
    - assets/animations/characters/money_bear/selected/
    # ... (나머지 캐릭터도 동일)
```

**⚠️ 중요:** 새 프레임 추가 시 `flutter pub get` 실행 필수!

---

## 5. 테스트 가이드

### **Phase 1: 헌터캣 Idle 테스트**

**목표:** 12fps가 자연스러운지 확인

**절차:**
1. Midjourney로 헌터캣 Idle 영상 생성
2. ffmpeg로 12프레임 추출
3. `assets/animations/characters/hunter_cat/idle/` 폴더에 배치
4. `flutter pub get` 실행
5. `character_preview_screen`에서 확인

**평가 기준:**
- ✅ 자연스러운가?
- ✅ 깜빡거림 없는가?
- ✅ 루프가 부드러운가?

---

### **Phase 2: 프레임 수 비교 테스트**

**목표:** 최적의 fps 찾기

**절차:**
1. 같은 영상으로 12fps, 18fps, 24fps 프레임 추출
2. 각각 다른 임시 폴더에 배치
3. 코드에서 `frameCount` 변경하며 테스트
4. 가장 자연스러운 fps 선택

**참고:**
```dart
// lib/models/character_frame_animation.dart
case CharacterAnimationState.idle:
  return CharacterFrameAnimation(
    frameCount: 12,  // ← 여기 값 변경하며 테스트
    ...
  );
```

---

### **Phase 3: 인터랙티브 테스트**

**목표:** 터치 반응 확인

**절차:**
1. `character_preview_screen`에서 헌터캣 터치
2. Idle → Selected → Idle 전환 확인
3. 애니메이션 끊김 없는지 확인

**기대 동작:**
```
[Idle 재생 중]
    ↓ 사용자 터치
[Selected 재생 (0.8초)]
    ↓ 완료
[Idle 재생 재개]
```

---

### **Phase 4: 전체 통합 테스트**

**목표:** 모든 캐릭터, 모든 상태 확인

**체크리스트:**
- [ ] 4개 캐릭터 모두 Idle 재생 확인
- [ ] 각 상태 전환 부드러운지 확인
- [ ] 로딩 속도 확인 (Welcome Screen)
- [ ] 저사양 디바이스 테스트

---

## 6. 로딩 전략

### **6.1. Phase 1: Idle만 먼저 (Welcome Screen)**

**로딩 시점:** Welcome Screen 마지막 슬라이드

**로딩 대상:**
```
4개 캐릭터 × Idle 상태 × 12프레임 = 48개 이미지
```

**예상 용량:** 약 2MB (12fps 기준)

**예상 시간:** 2-3초 (WiFi)

**코드 위치:** `lib/screens/onboarding/welcome_screen.dart`

```dart
Future<void> _preloadIdleAnimations() async {
  await CharacterAnimationPreloader.loadAllIdleStates(context);
  setState(() => _isReady = true);
}
```

---

### **6.2. Phase 2: 선택 캐릭터 전체 (백그라운드)**

**로딩 시점:** 캐릭터 선택 직후

**로딩 대상:**
```
1개 캐릭터 × 4개 상태 × 평균 10프레임 = 40개 이미지
```

**예상 용량:** 약 1.6MB

**예상 시간:** 1-2초 (백그라운드, 사용자 인지 못함)

**코드 위치:** `lib/screens/onboarding/character_preview_screen.dart`

```dart
void _onCharacterSelected(PersonalityType type) {
  final characterId = type.animationConfig.characterId;

  // 백그라운드 로딩
  CharacterAnimationPreloader.loadCharacterAllStates(context, characterId);

  // 즉시 다음 화면
  Navigator.push(...);
}
```

---

### **6.3. Phase 3: 나머지 캐릭터 (유휴 시간)**

**로딩 시점:** 홈 화면 진입 후 5초 뒤

**로딩 대상:**
```
3개 캐릭터 × 5개 상태 × 평균 10프레임 = 150개 이미지
```

**예상 용량:** 약 6MB

**예상 시간:** 3-5초 (백그라운드)

**코드 위치:** `lib/screens/main/main_screen.dart`

```dart
@override
void initState() {
  super.initState();
  Future.delayed(Duration(seconds: 5), _loadRemainingCharacters);
}
```

---

## 7. 용량 최적화 (추후 고려)

### **Option 1: WebP 변환**

PNG → WebP 변환 시 30-50% 절감

```bash
# 설치
brew install webp

# 변환
cwebp -q 85 frame_01.png -o frame_01.webp
```

**효과:** 8MB → 4-5MB

---

### **Option 2: 해상도 조정**

상황별 해상도 차등

```
character_preview_screen: 300px (선명)
홈 화면 작은 캐릭터: 200px (용량 절감)
```

---

### **Option 3: 상태별 프레임 수 조정**

사용 빈도에 따라

```
자주 보는 상태:
- Idle: 12 frames (부드러움 중요)

덜 보는 상태:
- Confused: 8 frames (효율 우선)
```

---

## 8. 트러블슈팅

### **Q1: 프레임이 깜빡거려요**

**원인:** 이미지 로딩 지연

**해결:**
```dart
Image.asset(
  path,
  gaplessPlayback: true,  // ← 이 옵션 필수!
)
```

---

### **Q2: 애니메이션이 재생 안돼요**

**체크리스트:**
- [ ] 파일명이 `frame_01.png` 형식인가?
- [ ] pubspec.yaml에 경로 등록했나?
- [ ] `flutter pub get` 실행했나?
- [ ] 프레임 파일이 실제로 존재하나?

---

### **Q3: 용량이 너무 커요**

**해결책:**
1. WebP 변환 (30-50% 절감)
2. 해상도 축소 (300px → 250px)
3. 프레임 수 감소 (12fps → 10fps)

---

## 9. 다음 단계

### **현재 상태**
- ✅ 전략 문서화 완료
- ✅ 코드 구현 완료
- ⏳ 애니메이션 제작 대기

### **To-Do**
1. [ ] Midjourney로 헌터캣 베이스 이미지 생성
2. [ ] Midjourney Video로 Idle 영상 생성
3. [ ] ffmpeg로 프레임 추출 (12fps)
4. [ ] 폴더에 배치 및 테스트
5. [ ] 퀄리티 확인 후 나머지 진행

---

## 10. 참고 자료

### **ffmpeg 명령어 치트시트**

```bash
# 프레임 추출
ffmpeg -i input.mp4 -vf "fps=12,scale=300:300" frame_%02d.png

# 특정 구간만 추출
ffmpeg -i input.mp4 -ss 00:00:00 -t 00:00:01 -vf "fps=12" frame_%02d.png

# GIF → PNG
ffmpeg -i input.gif -vf "fps=12" frame_%02d.png

# 배경 투명화 (선택사항)
ffmpeg -i input.png -vf "colorkey=white:0.3:0.2" -pix_fmt rgba output.png
```

### **유용한 도구**

- **EZGIF**: https://ezgif.com/ (GIF → 프레임 추출 웹 도구)
- **ffmpeg 공식 문서**: https://ffmpeg.org/documentation.html
- **Midjourney**: https://www.midjourney.com/

---

**작성일**: 2025-12-13
**마지막 업데이트**: 2025-12-13
**담당**: Development Team
