# 캐릭터 애니메이션 프레임

> **업데이트**: 2025-12-19 (24fps, 600x600, PNG)

이 폴더는 프레임 기반 캐릭터 애니메이션 파일을 저장하는 곳입니다.

## 📁 폴더 구조

```
characters/
├── hunter_cat/              (헌터캣)
│   ├── animation_config.json  ← 프레임 수 설정 (JSON)
│   ├── idle/                  (숨쉬기, 24 frames, 1초 루프)
│   ├── selected/              (손 흔들기, 20 frames, 0.8초)
│   ├── happy/                 (점프, 30 frames, 1.2초)
│   ├── thinking/              (고민, 24 frames, 1초 루프)
│   └── confused/              (혼란, 20 frames, 0.8초)
├── money_bear/              (머니베어)
├── save_sheep/              (세이브쉽)
└── chaser_fox/              (체이서폭스)
```

## 📝 파일 네이밍 규칙

각 상태 폴더 안에 프레임 파일을 배치하세요:

```
frame_01.png
frame_02.png
frame_03.png
...
frame_24.png
```

**중요:**
- 반드시 `frame_01.png` 형식 (2자리 숫자)
- 소문자 사용
- PNG 포맷 (현재 지원, 투명 배경 보장)

## 🎬 사용 방법

### 1. Midjourney로 영상 생성

```
프롬프트 예시:
"cute purple cat character, standing idle pose,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"
```

### 2. ffmpeg로 프레임 추출 (권장)

```bash
# GIF → PNG 프레임 추출 (24fps, 600x600px, 고품질)
ffmpeg -i hunter_cat_idle.gif \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  hunter_cat/idle/frame_%02d.png

# MP4 → PNG 프레임 추출
ffmpeg -i hunter_cat_idle.mp4 \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  hunter_cat/idle/frame_%02d.png
```

**옵션 설명:**
- `fps=24`: 24fps (부드러움)
- `scale=600:600`: 고해상도 (Retina 대응)
- `flags=lanczos`: 고품질 리샘플링

**WebP 변환 (추후 용량 절감):**
```bash
# PNG → WebP 변환 (50% 용량 절감)
for file in frame_*.png; do
  ffmpeg -i "$file" -quality 90 "${file%.png}.webp"
done
# 코드 수정도 필요 (lib/models/character_frame_animation.dart:28)
```

### 3. animation_config.json 수정 (선택)

프레임 수를 코드 수정 없이 변경할 수 있습니다:

```json
{
  "idle": {
    "frameCount": 125,
    "frameDuration": 42,
    "loop": true,
    "description": "숨쉬기 루프 (5.2초)"
  }
}
```

**영상이 5초라면:** `frameCount`를 125로 변경 (5초 × 24fps)
**영상이 1초라면:** 24로 유지

### 4. 폴더에 배치

```
assets/animations/characters/hunter_cat/idle/
├── frame_01.png
├── frame_02.png
└── ...
```

### 4. flutter pub get 실행

```bash
flutter pub get
```

### 5. 앱에서 확인

프레임 파일을 배치하면 자동으로 AnimatedCharacter 위젯이 사용합니다!

```dart
AnimatedCharacter(
  characterType: PersonalityType.aggressive, // 헌터캣
  state: CharacterAnimationState.idle,
  size: 200,
)
```

## ⚠️ 주의사항

- 프레임 파일이 없으면 Placeholder(이모지 원)가 표시됩니다
- 파일 추가 후 반드시 `flutter pub get` 실행
- 파일명 규칙을 정확히 지켜야 합니다

## 📚 상세 가이드

전체 제작 워크플로우는 `docs/FRAME_ANIMATION_GUIDE.md` 참고하세요.
