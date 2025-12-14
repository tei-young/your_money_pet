# 캐릭터 애니메이션 전략 변경 (2025-12-13)

## 🎯 핵심 결정

### **Rive → 프레임 기반 (GIF/Video → PNG 추출)**

| 항목 | 이전 (Rive) | 현재 (프레임 기반) |
|------|------------|-------------------|
| **제작 도구** | Rive Editor | Midjourney Video |
| **파일 포맷** | .riv (벡터) | PNG (래스터) |
| **파일 크기** | 200KB-1MB | 8MB (압축 후) |
| **제작 난이도** | 높음 (리깅 필요) | 낮음 (AI 자동 생성) |
| **제작 비용** | $500-2000 | $12/월 (Midjourney) |
| **제작 시간** | 1-2주 | 1-2일 |
| **인터랙티브** | ✅ 완벽 | ✅ 완벽 |
| **해상도** | 벡터 (무한 확대) | 300px (고정) |

### **왜 변경했나?**

1. ✅ **빠른 제작**: Midjourney로 1-2일이면 완성
2. ✅ **저렴한 비용**: $12/월 (Rive 외주 대비 1/40)
3. ✅ **테스트 용이**: 다양한 fps 실험 가능
4. ✅ **퀄리티 충분**: 12fps로도 부드러운 애니메이션 가능

---

## 📊 최종 스펙

```
제작 도구:  Midjourney Video
프레임 수:   12fps (테스트 후 조정 가능)
해상도:      300x300px
포맷:        PNG
총 용량:     약 8MB (4 캐릭터 × 5 상태)
```

---

## ✅ 완료된 작업 (개발팀, 2025-12-13)

### **1. 코드 구현**
- [x] `CharacterFrameAnimation` 모델 생성
- [x] `AnimatedCharacter` 위젯 전면 수정
- [x] `CharacterAnimationPreloader` 서비스 생성
- [x] 점진적 로딩 전략 구현

### **2. 폴더 구조**
```
assets/animations/characters/
├── hunter_cat/
├── money_bear/
├── save_sheep/
└── chaser_fox/
    ├── idle/
    ├── selected/
    ├── happy/
    ├── thinking/
    └── confused/
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
3. ffmpeg로 12프레임 추출:
   ```bash
   ffmpeg -i hunter_cat_idle.gif -vf "fps=12,scale=300:300" \
     assets/animations/characters/hunter_cat/idle/frame_%02d.png
   ```
4. `flutter pub get` 실행
5. 앱에서 확인

### **Phase 2: 퀄리티 확인**

- 12fps가 자연스러운지 확인
- 필요시 18fps 또는 24fps로 재추출
- 최적 fps 결정

### **Phase 3: 전체 제작**

- 나머지 4개 상태 제작 (헌터캣)
- 나머지 3개 캐릭터 제작
- 총 20개 애니메이션 완성

---

## 📝 사용 방법 (디자인팀용)

### **1. 프레임 파일 생성**

```bash
# Midjourney에서 다운로드한 GIF/MP4를 프레임으로 추출
ffmpeg -i input.gif -vf "fps=12,scale=300:300" \
  -start_number 1 \
  frame_%02d.png
```

### **2. 폴더에 배치**

```
assets/animations/characters/hunter_cat/idle/
├── frame_01.png
├── frame_02.png
└── frame_12.png
```

**중요:** 파일명은 반드시 `frame_01.png` 형식!

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
2. 12fps로 재생 (CharacterFrameAnimation 프리셋 기준)
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
