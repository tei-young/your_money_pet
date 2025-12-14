# 캐릭터 애니메이션 프레임

이 폴더는 프레임 기반 캐릭터 애니메이션 파일을 저장하는 곳입니다.

## 📁 폴더 구조

```
characters/
├── hunter_cat/      (헌터캣)
├── money_bear/      (머니베어)
├── save_sheep/      (세이브쉽)
└── chaser_fox/      (체이서폭스)
    ├── idle/        (숨쉬기, 12 frames)
    ├── selected/    (손 흔들기, 10 frames)
    ├── happy/       (점프, 12 frames)
    ├── thinking/    (고민, 10 frames)
    └── confused/    (혼란, 8 frames)
```

## 📝 파일 네이밍 규칙

각 상태 폴더 안에 프레임 파일을 배치하세요:

```
frame_01.png
frame_02.png
frame_03.png
...
frame_12.png
```

**중요:**
- 반드시 `frame_01.png` 형식 (2자리 숫자)
- 소문자 사용
- PNG 포맷

## 🎬 사용 방법

### 1. Midjourney로 영상 생성

```
프롬프트 예시:
"cute purple cat character, standing idle pose,
full body, white background, flat color illustration,
children's book style --ar 1:1 --v 6"
```

### 2. ffmpeg로 프레임 추출

```bash
# GIF → PNG 프레임 추출 (12fps, 300x300px)
ffmpeg -i hunter_cat_idle.gif \
  -vf "fps=12,scale=300:300" \
  -start_number 1 \
  hunter_cat/idle/frame_%02d.png

# MP4 → PNG 프레임 추출
ffmpeg -i hunter_cat_idle.mp4 \
  -vf "fps=12,scale=300:300" \
  -start_number 1 \
  hunter_cat/idle/frame_%02d.png
```

### 3. 폴더에 배치

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
