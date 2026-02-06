# JSON Import 기능 구현 스펙

**작성일**: 2026-01-04
**상태**: ✅ Phase 1 구현 완료 (2026-02-06)
**담당**: 백오피스 팀

---

## 📋 개요

### 목적
콘텐츠 제작팀이 JSON 형식으로 작성한 학습 콘텐츠 및 퀴즈를 백오피스에 직접 업로드할 수 있도록 하는 기능

### 대상 사용자
- 콘텐츠 제작팀 (JSON 파일 생성)
- 백오피스 관리자 (JSON Import 실행)

### 지원 포맷
- **학습 콘텐츠**: JSON 형식 (Learning Content)
- **퀴즈**: JSON 형식 (Quiz Content)

---

## 🎯 기능 범위

### 학습 콘텐츠 Import
- JSON 파일 업로드 또는 텍스트 붙여넣기
- 데이터 검증 (필수 필드, 타입, 값 범위)
- 중복 day 체크 및 덮어쓰기 확인
- Firestore `learning_contents` 컬렉션에 저장

### 퀴즈 Import
- JSON 파일 업로드 또는 텍스트 붙여넣기
- 데이터 검증 (필수 필드, 정답 존재, options 개수)
- 중복 day 체크 및 덮어쓰기 확인
- Firestore `quiz_contents` 컬렉션에 저장

---

## 📐 JSON 형식 예시

### 1. Learning Content (학습 콘텐츠)

```json
{
  "day": 1,
  "personality": "safe",
  "title": "투자가 뭐예요?",
  "estimatedMinutes": 3,
  "points": 50,
  "cards": [
    {
      "order": 1,
      "type": "text",
      "content": "안녕하세요! 머니베어예요 🐻\n\n오늘부터 함께 '돈 공부'를 시작해볼까요?",
      "tip": null
    },
    {
      "order": 2,
      "type": "text",
      "content": "**투자란?**\n\n지금 가진 돈을 활용해서 미래에 더 많은 돈을 만드는 것이에요.",
      "tip": "물가는 보통 매년 2~3%씩 오릅니다."
    }
  ]
}
```

### 2. Quiz Content (퀴즈)

```json
{
  "day": 1,
  "personality": "safe",
  "totalPoints": 100,
  "passingScore": 60,
  "questions": [
    {
      "order": 1,
      "question": "투자란 무엇인가요?",
      "points": 20,
      "options": [
        {
          "text": "돈을 숨겨두는 것",
          "isCorrect": false,
          "explanation": "숨겨두면 이자도 없고 물가상승으로 가치만 떨어져요."
        },
        {
          "text": "돈이 돈을 벌게 하는 것",
          "isCorrect": true,
          "explanation": "맞아요! 투자는 지금 가진 돈을 활용해 미래에 더 많은 돈을 만드는 거예요."
        }
      ]
    }
  ]
}
```

---

## 💻 UI/UX 설계

### 위치
- **학습 콘텐츠**: `/dashboard/[personality]` (학습 탭)
  - 버튼: `[새 콘텐츠 작성] [JSON Import]`
- **퀴즈**: `/dashboard/[personality]` (퀴즈 탭)
  - 버튼: `[새 퀴즈 작성] [JSON Import]`

### 동작 플로우

```
1. [JSON Import] 버튼 클릭
   ↓
2. 모달 열림
   - 제목: "JSON Import - 학습 콘텐츠" / "JSON Import - 퀴즈"
   - 탭: [파일 업로드] [JSON 붙여넣기]
   ↓
3. JSON 입력
   [파일 업로드 탭]
   - <input type="file" accept=".json" />
   - 파일 선택 → FileReader로 읽기

   [JSON 붙여넣기 탭]
   - <textarea> JSON 텍스트 직접 입력
   ↓
4. [검증하기] 버튼 클릭
   ↓
5. 검증 실행
   - JSON.parse() 시도
   - 필수 필드 체크
   - 타입 검증
   - 값 범위 검증
   ↓
6-A. 검증 실패
   - ❌ 에러 메시지 표시
   - 예: "cards 배열이 비어있습니다"
   - 예: "question 필드가 누락되었습니다 (questions[2])"
   ↓
6-B. 검증 성공
   - ✅ 파싱된 데이터 요약 표시
   - 예: "Day 1: 투자가 뭐예요? (5개 카드)"
   ↓
7. [저장] 버튼 클릭
   ↓
8. 중복 day 체크
   - Firestore에서 같은 personality + day 조회
   ↓
9-A. 중복 없음
   - Firestore에 바로 저장 (addDoc)
   - 성공 메시지 → 모달 닫기 → 목록 새로고침
   ↓
9-B. 중복 있음
   - ⚠️ 경고 팝업 표시
   - "Day 1 콘텐츠가 이미 존재합니다. 덮어쓰시겠습니까?"
   - [취소] [덮어쓰기] 버튼
   ↓
10. 사용자 선택
    - [취소]: 모달 유지, 저장 안 함
    - [덮어쓰기]: 기존 문서 업데이트 (updateDoc)
    - 성공 메시지 → 모달 닫기 → 목록 새로고침
```

---

## ✅ 검증 로직

### 학습 콘텐츠 검증 항목

#### 필수 필드
```typescript
✓ day: number (양수)
✓ personality: "safe" | "balanced" | "aggressive" | "challenger"
✓ title: string (비어있지 않음)
✓ estimatedMinutes: number (양수)
✓ points: number (양수)
✓ cards: array (최소 1개 이상)
```

#### 카드 필드 검증
```typescript
각 cards[i]에 대해:
✓ order: number (1부터 시작, 연속적)
✓ type: "text" | "image" | "quiz_link"
✓ content: string (비어있지 않음)
✓ tip: string | null
```

#### 추가 검증
```typescript
✓ personality 값이 유효한지 ("safe", "balanced", "aggressive", "challenger")
✓ cards의 order가 중복되지 않는지
✓ cards의 order가 연속적인지 (1, 2, 3, ...)
```

### 퀴즈 검증 항목

#### 필수 필드
```typescript
✓ day: number (양수)
✓ personality: "safe" | "balanced" | "aggressive" | "challenger"
✓ totalPoints: number (양수)
✓ passingScore: number (0~100 사이)
✓ questions: array (최소 1개 이상)
```

#### 질문 필드 검증
```typescript
각 questions[i]에 대해:
✓ order: number (1부터 시작, 연속적)
✓ question: string (비어있지 않음)
✓ points: number (양수)
✓ options: array (최소 2개 이상)
```

#### 선택지 필드 검증
```typescript
각 questions[i].options[j]에 대해:
✓ text: string (비어있지 않음)
✓ isCorrect: boolean
✓ explanation: string (비어있지 않음)
```

#### 추가 검증
```typescript
✓ 각 question에 isCorrect: true인 option이 최소 1개 이상 있는지
✓ totalPoints === sum(questions[].points) (합계 일치)
✓ questions의 order가 중복되지 않는지
✓ questions의 order가 연속적인지 (1, 2, 3, ...)
```

---

## 🚨 에러 처리

### JSON 파싱 에러
```
"유효하지 않은 JSON 형식입니다. JSON 문법을 확인해주세요."
```

### 필드 누락 에러
```
"필수 필드 'title'이 누락되었습니다."
"cards[2]에 'content' 필드가 없습니다."
"questions[0].options[1]에 'explanation' 필드가 없습니다."
```

### 타입 에러
```
"'day'는 숫자여야 합니다. (현재: string)"
"'isCorrect'는 boolean이어야 합니다. (현재: string)"
"'cards'는 배열이어야 합니다."
```

### 값 범위 에러
```
"'day'는 양수여야 합니다. (현재: -1)"
"'passingScore'는 0~100 사이여야 합니다. (현재: 150)"
"'personality'는 'safe', 'balanced', 'aggressive', 'challenger' 중 하나여야 합니다."
```

### 배열 관련 에러
```
"cards 배열이 비어있습니다. 최소 1개 이상의 카드가 필요합니다."
"questions[0].options는 최소 2개 이상이어야 합니다."
"questions[0]에 정답(isCorrect: true)이 없습니다."
```

### 중복 에러 (경고 팝업)
```
⚠️ "Day 1 학습 콘텐츠가 이미 존재합니다. 덮어쓰시겠습니까?"
⚠️ "Day 1 퀴즈가 이미 존재합니다. 덮어쓰시겠습니까?"

[취소] [덮어쓰기]
```

---

## 🏗️ 컴포넌트 구조

### 새로 생성할 파일

```
backoffice/components/import/
├── LearningJsonImport.tsx    # 학습 콘텐츠 JSON Import 모달
└── QuizJsonImport.tsx         # 퀴즈 JSON Import 모달
```

### LearningJsonImport.tsx

**Props**:
```typescript
interface LearningJsonImportProps {
  personality: string;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}
```

**State**:
```typescript
- activeTab: "file" | "text"
- jsonInput: string
- validationResult: { success: boolean; data?: any; error?: string }
- isValidating: boolean
- isSaving: boolean
```

**주요 함수**:
```typescript
- handleFileUpload(file: File): void
- handleTextChange(text: string): void
- validateJson(): void
- checkDuplicate(day: number): Promise<boolean>
- saveToFirestore(data: LearningContentData): Promise<void>
```

### QuizJsonImport.tsx

**Props**:
```typescript
interface QuizJsonImportProps {
  personality: string;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}
```

**State**:
```typescript
- activeTab: "file" | "text"
- jsonInput: string
- validationResult: { success: boolean; data?: any; error?: string }
- isValidating: boolean
- isSaving: boolean
```

**주요 함수**:
```typescript
- handleFileUpload(file: File): void
- handleTextChange(text: string): void
- validateJson(): void
- checkDuplicate(day: number): Promise<boolean>
- saveToFirestore(data: QuizContentData): Promise<void>
```

---

## 📅 구현 단계

### Phase 1: 필수 기능 (현재 개발)
- ✅ JSON 파일 업로드
- ✅ JSON 텍스트 붙여넣기 (탭 UI)
- ✅ 기본 검증 (필수 필드, 타입)
- ✅ 상세 검증 (값 범위, 배열 관련)
- ✅ Firestore 저장
- ✅ 중복 day 체크 및 덮어쓰기 확인 팝업
- ✅ 성공/실패 메시지

### Phase 2: 선택 기능 (향후)
- ⏳ 미리보기 기능 (MobilePreview/QuizPreview 재사용)
- ⏳ 일괄 Import (여러 JSON 파일 동시 업로드)
- ⏳ Import 히스토리 (누가, 언제, 무엇을 import했는지)
- ⏳ JSON Export 기능 (기존 콘텐츠를 JSON으로 내보내기)

---

## 🧪 테스트 케이스

### 학습 콘텐츠 - 정상 케이스

```json
{
  "day": 1,
  "personality": "safe",
  "title": "투자 기초",
  "estimatedMinutes": 5,
  "points": 100,
  "cards": [
    {
      "order": 1,
      "type": "text",
      "content": "투자란 무엇일까요?",
      "tip": null
    }
  ]
}
```

**기대 결과**: ✅ 검증 성공, 저장 성공

### 학습 콘텐츠 - 에러 케이스

#### 1. 필수 필드 누락
```json
{
  "day": 1,
  "personality": "safe",
  "estimatedMinutes": 5,
  "points": 100,
  "cards": []
}
```
**에러**: "필수 필드 'title'이 누락되었습니다."

#### 2. 타입 에러
```json
{
  "day": "1",
  "personality": "safe",
  "title": "투자 기초",
  "estimatedMinutes": 5,
  "points": 100,
  "cards": []
}
```
**에러**: "'day'는 숫자여야 합니다. (현재: string)"

#### 3. 빈 배열
```json
{
  "day": 1,
  "personality": "safe",
  "title": "투자 기초",
  "estimatedMinutes": 5,
  "points": 100,
  "cards": []
}
```
**에러**: "cards 배열이 비어있습니다. 최소 1개 이상의 카드가 필요합니다."

### 퀴즈 - 정상 케이스

```json
{
  "day": 1,
  "personality": "safe",
  "totalPoints": 100,
  "passingScore": 60,
  "questions": [
    {
      "order": 1,
      "question": "투자란?",
      "points": 100,
      "options": [
        { "text": "A", "isCorrect": false, "explanation": "틀렸어요" },
        { "text": "B", "isCorrect": true, "explanation": "맞아요" }
      ]
    }
  ]
}
```

**기대 결과**: ✅ 검증 성공, 저장 성공

### 퀴즈 - 에러 케이스

#### 1. 정답 없음
```json
{
  "day": 1,
  "personality": "safe",
  "totalPoints": 100,
  "passingScore": 60,
  "questions": [
    {
      "order": 1,
      "question": "투자란?",
      "points": 100,
      "options": [
        { "text": "A", "isCorrect": false, "explanation": "틀렸어요" },
        { "text": "B", "isCorrect": false, "explanation": "틀렸어요" }
      ]
    }
  ]
}
```
**에러**: "questions[0]에 정답(isCorrect: true)이 없습니다."

#### 2. options 개수 부족
```json
{
  "day": 1,
  "personality": "safe",
  "totalPoints": 100,
  "passingScore": 60,
  "questions": [
    {
      "order": 1,
      "question": "투자란?",
      "points": 100,
      "options": [
        { "text": "A", "isCorrect": true, "explanation": "맞아요" }
      ]
    }
  ]
}
```
**에러**: "questions[0].options는 최소 2개 이상이어야 합니다."

---

## 📝 구현 체크리스트

### UI 컴포넌트
- [x] LearningJsonImport 모달 컴포넌트
- [x] QuizJsonImport 모달 컴포넌트
- [x] 탭 UI (파일 업로드 / JSON 붙여넣기)
- [x] 파일 업로드 input
- [x] JSON 텍스트 textarea
- [x] 검증 결과 표시 영역
- [x] 중복 확인 팝업 (Alert/Confirm)

### 검증 로직
- [x] JSON.parse() 에러 처리
- [x] 필수 필드 검증
- [x] 타입 검증
- [x] 값 범위 검증
- [x] 배열 검증 (빈 배열, 최소 개수)
- [x] 퀴즈 정답 존재 여부
- [x] order 연속성 검증
- [x] personality 검증 (safe, balanced, aggressive, challenger)

### Firestore 연동
- [x] 중복 day 조회 쿼리
- [x] addDoc (새 문서 생성)
- [x] updateDoc (기존 문서 덮어쓰기)
- [x] 저장 성공/실패 처리

### 통합
- [x] 학습 콘텐츠 목록 페이지에 버튼 추가
- [x] 퀴즈 목록 페이지에 버튼 추가
- [x] 모달 열기/닫기 상태 관리
- [x] 저장 후 목록 새로고침

---

## 🔗 관련 문서

- `docs/BACKOFFICE_DESIGN.md` - 백오피스 전체 디자인
- `docs/BACKOFFICE_DEVELOPMENT_STATUS.md` - 개발 현황
- `backoffice/README.md` - 백오피스 README

---

**작성**: 백오피스 팀
**최종 업데이트**: 2026-02-06 (Phase 1 구현 완료)

---

## 📋 구현 히스토리

### 2026-02-06: Phase 1 완료
- ✅ 컴포넌트 구현 완료 (`LearningJsonImport.tsx`, `QuizJsonImport.tsx`)
- ✅ 목록 페이지 통합 완료 (JSON Import 버튼)
- ✅ Personality 검증 수정 (safe, balanced, aggressive, challenger)
- ✅ 모든 검증 로직 구현
- ✅ Firestore 중복 체크 및 덮어쓰기 기능
- 📦 **커밋**: `521ee06e` - "Feat: Connect JSON Import to list pages (Phase 1 - 2/2)"
- 📦 **커밋**: `95c45284` - "Fix: Correct personality validation in JSON Import components"
