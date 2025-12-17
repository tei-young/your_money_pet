# 캐릭터 애니메이션 전략 변경

> **최초 작성**: 2025-12-13
> **마지막 업데이트**: 2025-12-16 (고해상도 최적화)

## 🎯 핵심 결정

### **Rive → 프레임 기반 (GIF/Video → WebP 추출)**

| 항목 | 이전 (Rive) | 현재 (프레임 기반) |
|------|------------|-------------------|
| **제작 도구** | Rive Editor | Midjourney Video |
| **파일 포맷** | .riv (벡터) | WebP (래스터, 압축) |
| **파일 크기** | 200KB-1MB | 12MB (WebP 압축) |
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

## 📊 최종 스펙 (2025-12-16 업데이트)

```
제작 도구:  Midjourney Video
프레임 수:   24fps (영화급 부드러움)
해상도:      600x600px (Retina 3x 대응)
포맷:        WebP (PNG 대비 용량 50% 절감)
총 용량:     약 12MB (4 캐릭터 × 5 상태)
```

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

### **2. 폴더 구조**
```
assets/animations/characters/
├── hunter_cat/
│   ├── animation_config.json  ← 신규: 프레임 수 설정
│   ├── idle/
│   ├── selected/
│   └── ...
├── money_bear/
│   ├── animation_config.json
│   └── ...
├── save_sheep/
└── chaser_fox/
```

### **3. 문서화**
- [x] `docs/FRAME_ANIMATION_GUIDE.md` (전체 가이드)
- [x] `assets/animations/characters/README.md` (사용법)

### **4. Fallback 로직**
- 프레임 파일 없으면 Placeholder (이모지 원) 표시
- 개발 중에도 앱 정상 작동

---

## 🎬 다음 단계 (디자인팀)

### **Phase 1: 헌터캣 Idle 테스트**

1. Midjourney로 헌터캣 베이스 이미지 생성
2. Midjourney Video로 Idle 영상 생성 (숨쉬기, 1초)
3. ffmpeg로 24프레임 WebP 추출:
   ```bash
   ffmpeg -i hunter_cat_idle.gif \
     -vf "fps=24,scale=600:600:flags=lanczos" \
     -quality 90 \
     assets/animations/characters/hunter_cat/idle/frame_%02d.webp
   ```
4. `flutter pub get` 실행
5. 앱에서 확인

### **Phase 2: 전체 제작**

- 나머지 4개 상태 제작 (헌터캣)
- 나머지 3개 캐릭터 제작
- 총 20개 애니메이션 완성

---

## 📝 사용 방법 (디자인팀용)

### **1. JSON 설정 수정 (프레임 수 변경 - 신규!)**

**영상 길이가 다른 경우:**
```bash
# 1. animation_config.json 파일 열기
vim assets/animations/characters/hunter_cat/animation_config.json

# 2. frameCount 수정
{
  "idle": {
    "frameCount": 125,  # 5초 영상 = 125프레임 (24fps)
    "frameDuration": 42,
    "loop": true
  }
}

# 3. 앱 재실행 → 자동 적용 ✅
```

**장점:**
- ✅ 코드 수정 불필요
- ✅ 디자이너가 직접 수정 가능
- ✅ 캐릭터별 독립적 설정

---

### **2. 프레임 파일 생성 (권장 방식)**

```bash
# Midjourney에서 다운로드한 GIF/MP4를 WebP 프레임으로 추출
ffmpeg -i input.gif \
  -vf "fps=24,scale=600:600:flags=lanczos" \
  -quality 90 \
  -start_number 1 \
  frame_%02d.webp
```

**옵션 설명:**
- `fps=24`: 24fps (부드러움)
- `scale=600:600`: 고해상도
- `flags=lanczos`: 고품질 리샘플링
- `quality=90`: WebP 품질 (90 = 거의 무손실)

### **2. 폴더에 배치**

```
assets/animations/characters/hunter_cat/idle/
├── frame_01.webp
├── frame_02.webp
└── frame_24.webp
```

**중요:** 파일명은 반드시 `frame_01.webp` 형식!

### **3. flutter pub get 실행**

```bash
cd your_money_pet
flutter pub get
```

### **4. 앱에서 자동 적용**

프레임 파일만 배치하면 AnimatedCharacter 위젯이 자동으로 사용합니다!

---

## 🔧 개발자 노트

### **자동 적용 메커니즘**

```dart
AnimatedCharacter(
  characterType: PersonalityType.aggressive, // 헌터캣
  state: CharacterAnimationState.idle,
  size: 200,
)
```

위 코드는 자동으로:
1. `assets/animations/characters/hunter_cat/idle/` 폴더에서 프레임 로드
2. 24fps로 재생 (CharacterFrameAnimation 프리셋 기준)
3. 루프 재생 (Idle은 loop: true)
4. 프레임 없으면 Placeholder 표시

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
