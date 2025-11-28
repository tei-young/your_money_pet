# 콘텐츠 데이터 구조

이 폴더는 학습 콘텐츠와 퀴즈 데이터를 저장합니다.

## 📁 폴더 구조

```
assets/data/
├── learning/          # 학습 콘텐츠
│   ├── _TEMPLATE.json # 작성 템플릿
│   ├── day_001_safe.json
│   ├── day_001_balanced.json
│   ├── day_001_aggressive.json
│   └── day_001_challenger.json
│
└── quiz/              # 퀴즈 콘텐츠
    ├── _TEMPLATE.json # 작성 템플릿
    ├── day_001_safe_quiz.json
    ├── day_001_balanced_quiz.json
    ├── day_001_aggressive_quiz.json
    └── day_001_challenger_quiz.json
```

## 📝 파일명 규칙

### 학습 콘텐츠
- 형식: `day_XXX_PERSONALITY.json`
- 예시: `day_001_safe.json`, `day_030_aggressive.json`

### 퀴즈 콘텐츠
- 형식: `day_XXX_PERSONALITY_quiz.json`
- 예시: `day_001_safe_quiz.json`, `day_030_balanced_quiz.json`

## 🎯 투자 성향 (personalityType)

- `safe`: 안전형
- `balanced`: 밸런스형
- `aggressive`: 공격형
- `challenger`: 도전형

## 📋 작성 가이드

### 1. 학습 콘텐츠 (Learning Content)

**필수 필드:**
- `contentId`: 고유 ID (예: "day_001_safe")
- `day`: Day 번호 (1-365)
- `personalityType`: 투자 성향
- `title`: 학습 주제
- `cards`: 학습 카드 배열
  - `order`: 카드 순서 (1부터 시작)
  - `type`: 카드 타입 ("text", "image", "video")
  - `content`: 카드 내용 (마크다운 지원)
  - `imageUrl`: 이미지 URL (선택)
- `estimatedMinutes`: 예상 소요 시간
- `points`: 완료 시 획득 포인트 (기본 50)

**선택 필드:**
- `tags`: 태그 배열
- `version`: 버전 (기본 "1.0")
- `isPublished`: 공개 여부 (기본 true)

### 2. 퀴즈 콘텐츠 (Quiz Content)

**필수 필드:**
- `quizId`: 고유 ID (예: "day_001_safe_quiz")
- `day`: Day 번호
- `personalityType`: 투자 성향
- `questions`: 퀴즈 문제 배열 (5문항)
  - `order`: 문제 순서
  - `question`: 문제 내용
  - `options`: 선택지 배열 (4개)
    - `text`: 선택지 텍스트
    - `isCorrect`: 정답 여부
    - `explanation`: 정답 해설 (정답만 작성)
  - `points`: 문제당 점수 (기본 20)
- `totalPoints`: 총점 (기본 100)
- `passingScore`: 합격 점수 (기본 60)

## 💡 작성 팁

### 학습 콘텐츠
1. **카드 개수**: 3-5개 권장
2. **내용 길이**: 카드당 150-300자 권장
3. **마크다운**: 제목(#), 강조(**), 리스트(-) 활용
4. **이모지**: 적절히 사용하여 친근감 연출

### 퀴즈
1. **문제 수**: 반드시 5문항
2. **선택지**: 반드시 4개
3. **난이도**: 학습 내용에서 80% 이상 다룬 내용
4. **해설**: 정답 이유를 친절하게 설명

## 🔄 백오피스 연동

### Phase 1: JSON 파일 (현재)
- 이 폴더의 JSON 파일을 앱에서 직접 로드
- `pubspec.yaml`에 assets 경로 등록 필요

### Phase 2: Firestore 업로드
- JSON 파일을 Firestore로 일괄 업로드
- 백오피스에서 관리 가능

### Phase 3: 백오피스 완성
- 백오피스 UI에서 직접 생성/수정
- Firestore에 저장
- 앱에서 실시간 업데이트

## 📚 참고 문서

- `docs/BACKOFFICE_DESIGN.md`: 백오피스 설계 문서
- `lib/models/learning_day_model.dart`: 데이터 모델 정의
