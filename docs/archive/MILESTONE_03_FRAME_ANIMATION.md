# 마일스톤 03: 프레임 기반 애니메이션 시스템

> **기간:** 2025-12-13 ~ 2025-12-26
> **상태:** ✅ 완료

---

## 📋 요약

Rive 대신 Midjourney/Runway로 생성한 프레임 시퀀스 기반 애니메이션 시스템 구축.
10-state에서 13-state 통합 애니메이션 방식으로 재설계.

**상세 가이드:** [FRAME_ANIMATION_GUIDE.md](../FRAME_ANIMATION_GUIDE.md)

---

## 주요 변경 이력

### 📅 2025-12-26: 홈 화면 랜덤 애니메이션
- ✅ `_selectRandomHomeState()` 메서드 추가
- ✅ 5개 home state 중 랜덤 선택 (homeIdle, homeStudying, homeExcited, homeSleepy, homeCelebration)
- ✅ Icon 위젯 → AnimatedCharacter 위젯 교체

**커밋:** 068f974

---

### 📅 2025-12-24: 통합 애니메이션 방식 재설계 (13-State)

**핵심 변경:**
- 개별 상태 조합 방식 → 통합 애니메이션 방식
- 예: `quizCorrectFlow` = thinking → happy → idle 복귀를 **하나의 애니메이션**으로 제작
- 프레임 불일치로 인한 전환 끊김 문제 해결

**구현 완료:**
- ✅ CharacterAnimationState enum 재설계 (14개 → 13개)
- ✅ Enum → 폴더명 변환 로직 (`_stateToFolderName()`)
- ✅ 자동 전환 로직 (`autoTransitionTo` 필드)
- ✅ 폴더 구조 재편 (4캐릭터 × 13상태 = 52개 폴더)
- ✅ animation_config.json 재작성
- ✅ 화면별 State 사용 업데이트
- ✅ pubspec.yaml 52개 경로 등록

**커밋:** 1695ecc, 5e2f0b3, a6c6108, 088b510, e5ab1c6, bb8d045, 5950ff5

---

### 📅 2025-12-23: 애니메이션 상태 체계 재설계 (5 → 10)

**변경 내용:**
- 기존 "idle"이 실제로는 "greeting" → 개념 분리
- 홈 화면용 상태 4개 추가 (homeStudying, homeExcited, homeSleepy, homeCelebration)
- Idle 애니메이션 5초 복합 구성 (캐릭터 성향 표현)

**커밋:** 94c0a91

---

### 📅 2025-12-19: 프레임 애니메이션 버그 수정

**수정 내용:**
- ✅ PNG 포맷 지원 (`.webp` → `.png`)
- ✅ 상태 전환 시 에러 방지 (`_hasFrames` 플래그 리셋)
- ✅ AnimationController 크래시 수정 (`TickerProviderStateMixin`)
- ✅ Placeholder 깜빡임 제거
- ✅ 온보딩 화면 캐릭터 크기 1.8배 증가

**커밋:** 6e30cfa, 25238a0, 12e7fa4, 66cd6dc, f931c17, c874ef2, eb14c64

---

### 📅 2025-12-16: JSON 기반 애니메이션 설정 시스템

**구현 내용:**
- ✅ AnimationConfigLoader 서비스
- ✅ 캐릭터별 animation_config.json 생성 (4개)
- ✅ CharacterFrameAnimation.forStateAsync() 메서드
- ✅ JSON 로딩 실패 시 자동 fallback

**효과:**
- 프레임 수 변경 시 코드 수정 불필요
- 디자이너가 JSON 직접 수정 가능

**커밋:** 4e2c67e

---

### 📅 2025-12-13: 프레임 기반 캐릭터 애니메이션 시스템 구현

**결정 배경:**
- Rive 대신 Midjourney Video로 빠른 프로토타이핑
- 디자인 유연성 및 제작 비용 절감

**구현 내용:**
- ✅ CharacterFrameAnimation 모델
- ✅ AnimatedCharacter 위젯 (AnimationController 기반)
- ✅ 프레임 프리셋 설정 (idle, selected, happy, thinking, confused)

---

## 📊 최종 스펙

| 항목 | 값 |
|------|-----|
| 총 상태 | 13개 |
| 총 애니메이션 | 52개 (4캐릭터 × 13상태) |
| 해상도 | 600x600px |
| 프레임 레이트 | 24fps |
| 포맷 | WebP (권장) / PNG |
| 총 용량 | ~192MB (PNG) / ~96MB (WebP) |

**13-State 목록:**
1. characterGreetingLoop, characterSelected
2. personalityIdle, personalitySelected
3. quizIdle, quizCorrectFlow, quizWrongFlow
4. resultCelebration
5. homeIdle, homeStudying, homeExcited, homeSleepy, homeCelebration

---

## 🔗 관련 문서
- [FRAME_ANIMATION_GUIDE.md](../FRAME_ANIMATION_GUIDE.md) - 상세 제작 가이드
- [DESIGN_DECISIONS.md](../DESIGN_DECISIONS.md) - 기술 결정 사항

---

**작성일:** 2025-12-26
**아카이브일:** 2026-02-15
