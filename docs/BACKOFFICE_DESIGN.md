# 백오피스 데이터 관리 설계

## 개요
MoneyPet 앱의 콘텐츠 및 사용자 데이터를 백오피스에서 효율적으로 관리하기 위한 데이터 구조 설계

## 데이터 분류

### 1. User Data (사용자 데이터)
**관리 주체:** 사용자 직접 생성/수정
**백오피스 역할:** 조회, 통계, 관리자 수정

```dart
// User Collection
{
  "userId": "unique_user_id",
  "name": "머니베어",
  "personalityType": "safe",
  "goal": "주택 구매",
  "currentDay": 1,
  "totalPoints": 0,
  "currentStreak": 0,
  "maxStreak": 0,
  "lastLearningDate": "2025-01-15T10:00:00Z",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z",
  "isActive": true,
  "metadata": {
    "appVersion": "1.0.0",
    "platform": "ios"
  }
}
```

### 2. App Content (앱 콘텐츠)
**관리 주체:** 백오피스 관리자
**사용자 역할:** 읽기 전용

#### 2.1 Learning Content (학습 콘텐츠)

**⚠️ 중요: 콘텐츠 마크업 시스템 적용됨 (2024-12-09)**
- `content` 및 `tip` 필드는 **마크업 문법** 지원
- 현재: `**텍스트**` (볼드)
- 향후: `[color:#HEX]텍스트[/color]`, `[size:크기]텍스트[/size]`
- 자세한 내용: `docs/CONTENT_MARKUP_GUIDE.md` 참조

```dart
// LearningContent Collection
{
  "contentId": "day_001_safe",
  "day": 1,
  "personality": "safe",  // "safe", "balanced", "aggressive", "challenger"
  "title": "예적금의 기본",
  "cards": [
    {
      "order": 1,
      "type": "text",  // "text", "image", "quiz_link"
      "content": "**예금**은 자유롭게 입출금이 가능하고, **적금**은 정해진 기간 동안 저축해요.",
      "imageUrl": null,
      "tip": "**복리**의 힘은 시간이 지날수록 커져요!"  // 선택적 필드
    }
  ],
  "estimatedMinutes": 3,
  "points": 50,
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

**콘텐츠 입력 시 주의사항:**
- `content`와 `tip` 필드에 마크업 문법 사용 가능
- `**키워드**` 형식으로 중요 용어 강조
- 백오피스 UI에서 실시간 프리뷰 제공 권장

#### 2.2 Quiz Content (퀴즈 콘텐츠)
```dart
// QuizContent Collection
{
  "quizId": "day_001_safe_quiz",
  "day": 1,
  "personality": "safe",  // "safe", "balanced", "aggressive", "challenger"
  "questions": [
    {
      "order": 1,
      "question": "예금과 적금의 차이는?",
      "options": [  // 배열 순서 보장 (order 필드 없음)
        {
          "text": "예금은 자유입출금",
          "isCorrect": true,
          "explanation": "맞습니다!"
        }
      ],
      "points": 20
    }
  ],
  "totalPoints": 100,
  "passingScore": 60,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**참고:** 퀴즈 백오피스는 아직 미구현 상태. 학습 콘텐츠와 동일한 최소 구조로 구현 예정.

#### 2.3 Character Config (캐릭터 설정)
**⚠️ 참고: 미구현 섹션 (향후 백오피스 구현 예정)**

```dart
// CharacterConfig Collection
{
  "characterId": "money_bear",
  "personality": "safe",  // "safe", "balanced", "aggressive", "challenger"
  "displayName": "머니베어",
  "fullName": "Money Bear 머니베어",
  "description": "든든하게 지키는",
  "emoji": "🐻",
  "colorHex": "#718096",
  "animationUrls": {
    "idle": "https://cdn.../money_bear_idle.riv",
    "selected": "https://cdn.../money_bear_selected.riv",
    "happy": "https://cdn.../money_bear_happy.riv"
  },
  "dialogues": {
    "intro": "안전하게 함께 시작해요! 🐻",
    "quizGreeting": "함께 성향을 알아볼까요?",
    "resultMatch": "우리 딱 맞는 것 같아요!"
  },
  "curriculum": "예적금의 기본과 복리의 힘부터...",
  "isActive": true,
  "sortOrder": 1,
  "updatedAt": Timestamp
}
```

**참고:** 캐릭터 설정 백오피스는 아직 미구현 상태. 향후 구현 예정.

#### 2.4 App Config (앱 설정)
**⚠️ 참고: 미구현 섹션 (향후 백오피스 구현 예정)**

```dart
// AppConfig Collection
{
  "configId": "app_config",
  "minAppVersion": "1.0.0",
  "forceUpdateVersion": "1.0.0",
  "maintenanceMode": false,
  "maintenanceMessage": null,
  "features": {
    "characterSelection": true,
    "dailyReminder": true,
    "sharing": true
  },
  "constants": {
    "totalDays": 365,
    "learningPoints": 50,
    "quizPointsPerQuestion": 20
  },
  "updatedAt": Timestamp
}
```

**참고:** 앱 설정 백오피스는 아직 미구현 상태. 향후 구현 예정.

## 백오피스 기능 요구사항

### 1. User Management (사용자 관리)
- **조회:** 전체 사용자 목록, 검색, 필터링
- **통계:**
  - 총 사용자 수
  - 일별/월별 신규 가입자
  - 성향별 분포
  - 학습 진행률 분포
  - 이탈률 (마지막 학습일 기준)
- **관리:**
  - 사용자 상세 조회
  - 학습 기록 조회
  - 계정 활성화/비활성화
  - 데이터 초기화 (테스트용)

### 2. Content Management (콘텐츠 관리)

#### 2.1 Learning Content
- **CRUD:**
  - 학습 콘텐츠 생성/수정/삭제
  - 카드 순서 변경
  - 이미지/비디오 업로드
- **버전 관리:**
  - Draft/Published 상태 관리
  - 버전 히스토리
  - 롤백 기능
- **미리보기:**
  - 앱 화면 프리뷰
  - 디바이스별 테스트

#### 2.2 Quiz Content
- **CRUD:**
  - 퀴즈 문제 생성/수정/삭제
  - 정답률 통계
  - 난이도 조정
- **분석:**
  - 문제별 정답률
  - 평균 소요 시간
  - 사용자 피드백

#### 2.3 Character Config
- **CRUD:**
  - 캐릭터 설정 수정
  - 대사 관리
  - 애니메이션 URL 업데이트
- **순서 관리:**
  - 캐릭터 표시 순서
  - 활성화/비활성화

#### 2.4 App Config
- **설정 관리:**
  - 앱 버전 관리
  - 강제 업데이트 설정
  - 점검 모드 전환
  - 기능 플래그 토글

### 3. Analytics (분석)
- **학습 통계:**
  - 일별 학습 완료 수
  - Day별 이탈률
  - 평균 학습 시간
- **퀴즈 통계:**
  - 평균 점수
  - 문제별 정답률
  - 재시도율
- **사용자 행동:**
  - 성향 변경 빈도
  - 이름 변경 빈도
  - 공유 빈도

## Firebase Firestore 구조

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile (User 기본 정보)
│       ├── learning_progress/
│       │   └── {dayId} (학습 완료 기록)
│       └── quiz_results/
│           └── {quizId} (퀴즈 결과)
│
├── learning_contents/
│   └── {contentId} (Learning Content)
│
├── quiz_contents/
│   └── {quizId} (Quiz Content)
│
├── character_configs/
│   └── {characterId} (Character Config)
│
└── app_config/
    └── config (App Config)
```

## API 설계 (예시)

### Content API
```
GET    /api/v1/contents/learning?day=1&personality=safe
POST   /api/v1/contents/learning
PUT    /api/v1/contents/learning/{contentId}
DELETE /api/v1/contents/learning/{contentId}

GET    /api/v1/contents/quiz?day=1&personality=safe
POST   /api/v1/contents/quiz
PUT    /api/v1/contents/quiz/{quizId}
DELETE /api/v1/contents/quiz/{quizId}
```

### User API
```
GET    /api/v1/users?page=1&limit=50
GET    /api/v1/users/{userId}
PUT    /api/v1/users/{userId}
DELETE /api/v1/users/{userId}

GET    /api/v1/users/stats/overview
GET    /api/v1/users/stats/personality-distribution
```

### Character API
```
GET    /api/v1/characters
GET    /api/v1/characters/{characterId}
PUT    /api/v1/characters/{characterId}
```

## 구현 우선순위

### Phase 1: 데이터 모델 개선 ✅ 완료 (2025-12-29)
- [x] User 모델에 백오피스 필드 추가 (createdAt, updatedAt, metadata)
- [x] Content 모델 생성 (LearningContent, QuizContent)
- [x] CharacterConfig 모델 생성
- [x] AppConfig 모델 생성

### Phase 2: Firebase 연동 🚧 진행 중
- [x] **Firestore 컬렉션 설계 및 생성** (2025-12-29 완료)
  - Firebase 프로젝트: `moneypet-74066`
  - 위치: `asia-northeast3 (Seoul)`
  - 모드: Production mode
  - Security Rules 설정 완료
  - 관리자 계정 생성 및 admin custom claim 설정 완료
  - 초기 데이터 생성 완료:
    - app_config: 1개
    - character_configs: 4개 (머니베어, 세이브쉽, 헌터캣, 체이서폭스)
    - learning_contents: 1개 (샘플)
    - quiz_contents: 1개 (샘플)
- [ ] User CRUD 구현
- [ ] Content CRUD 구현
- [ ] 로컬 캐싱 전략

### Phase 3: 백오피스 웹 개발 🚧 진행 중 (2025-12-30 ~ 2025-12-31)
- [x] **백오피스 프로젝트 생성** (2025-12-30 완료)
  - Next.js 15 (App Router) + TypeScript
  - Tailwind CSS + shadcn/ui
  - Firebase Client SDK 연동
  - 프로젝트 위치: `backoffice/`
- [x] **관리자 인증** (2025-12-30 완료)
  - Firebase Auth 로그인 페이지 (`/login`)
  - Admin custom claim 검증
  - 보호된 라우트 구현
  - 관리자 계정: admin@moneypet.com
- [x] **대시보드** (2025-12-30 완료)
  - 성향별 콘텐츠 관리 카드 (🐻 머니베어, 🐑 세이브쉽, 🐱 헌터캣, 🦊 체이서폭스)
  - 로그아웃 기능
  - 자동 리다이렉트 로직
- [x] **성향별 페이지** (2025-12-31 완료)
  - 동적 라우팅: `/dashboard/[personality]`
  - 탭 UI (학습 콘텐츠 / 퀴즈)
  - 성향별 색상 및 아이콘 표시
- [x] **학습 콘텐츠 관리 페이지** (2025-12-31 완료)
  - **목록 페이지** (`/dashboard/[personality]` - 학습 콘텐츠 탭)
    - Firestore 데이터 조회 (성향별 필터링)
    - Day 필터 (1-365) 및 정렬 (오름차순/내림차순)
    - 테이블 뷰: Day, 제목, 카드 개수, 작성일, 수정일, 액션
    - 삭제 확인 모달
  - **신규 작성 페이지** (`/dashboard/[personality]/learning/new`)
    - 기본 정보: Day, 제목, 예상 소요 시간, 포인트
    - 동적 카드 폼 (추가/삭제)
    - 카드 타입: text, image, quiz_link
    - 접을 수 있는 "💡 팁 추가하기" 섹션 (모든 카드에 선택적)
    - Firebase Storage 이미지 업로드 및 미리보기
    - 폼 검증 및 Firestore 저장
  - **수정 페이지** (`/dashboard/[personality]/learning/[id]`)
    - 기존 데이터 자동 로드
    - 모든 필드 수정 가능
    - Firestore 업데이트
  - **Flutter 팀 협의 완료** (2025-12-31)
    - Tip을 별도 카드 타입에서 카드 속성으로 변경
    - 데이터 구조 Flutter 모델과 정합성 확인
    - UserProvider.user.personalityType 존재 확인
- [x] **퀴즈 관리 페이지** (2026-01-01 완료)
  - **목록 페이지** (`/dashboard/[personality]` - 퀴즈 탭)
    - Firestore 데이터 조회 (성향별 필터링)
    - Day 필터 (1-365) 및 정렬 (오름차순/내림차순)
    - 테이블 뷰: Day, 문제 개수, 총점, 통과점수, 작성일, 수정일, 액션
    - 삭제 확인 모달
  - **신규 작성 페이지** (`/dashboard/[personality]/quiz/new`)
    - 기본 정보: Day, 총점, 통과점수
    - 동적 질문 폼 (추가/삭제, order 자동 관리)
    - 질문별 동적 선택지 폼 (최소 2개, 추가/삭제)
    - 정답 선택 (라디오 버튼)
    - 선택지별 해설 입력
    - 질문별 배점 설정
    - 종합 폼 검증 (최소 1문제, 최소 2선택지, 정답 필수)
  - **수정 페이지** (`/dashboard/[personality]/quiz/[id]`)
    - 기존 데이터 자동 로드
    - 모든 필드 수정 가능
    - Firestore 업데이트
  - **Flutter 팀 협의 확정** (2025-12-31)
    - 질문은 order 필드로 정렬
    - 선택지는 배열 순서 보장 (order 필드 없음)
    - 모든 유저가 동일한 선택지 순서 확인
- [ ] **사용자 관리 페이지** (향후)
  - 유저 활성화/비활성화
  - 탈퇴 처리

### Phase 4: 고도화 📋 예정
- [ ] 버전 관리 시스템
- [ ] A/B 테스트 기능
- [ ] 푸시 알림 관리
- [ ] 사용자 세그먼트별 콘텐츠 제공

## 보안 고려사항

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data: 본인만 읽기/쓰기
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Content: 모두 읽기, 관리자만 쓰기
    match /learning_contents/{contentId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }

    match /quiz_contents/{quizId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }

    // Character & App Config: 모두 읽기, 관리자만 쓰기
    match /character_configs/{characterId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }

    match /app_config/{configId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

---

## 콘텐츠 에디터 UI 설계 (상세)

### Phase 1: 기본 텍스트 입력 (MVP)

**구현 시점**: 백오피스 초기 구축 시
**복잡도**: 낮음

#### UI 레이아웃
```
┌─────────────────────────────────────────────┐
│ 학습 콘텐츠 작성                              │
├─────────────────────────────────────────────┤
│ Day: [1 ▼]  성향: [공통 ▼]                   │
│ 제목: [____________________________]         │
│                                              │
│ 카드 1                                  [삭제] │
│ ┌─────────────────────────────────────────┐ │
│ │ 콘텐츠:                                  │ │
│ │ **예금**은 자유롭게 입출금이 가능하고,    │ │
│ │ **적금**은 정해진 기간 동안 저축해요.     │ │
│ │                                          │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ ┌─────────────────────────────────────────┐ │
│ │ Tip (선택):                              │ │
│ │ **복리**의 힘은 시간이 지날수록 커져요!   │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ 이미지 URL: [____________________________]   │
│                                              │
│                              [+ 카드 추가]    │
│                                              │
│                   [미리보기] [저장] [발행]    │
└─────────────────────────────────────────────┘
```

#### 마크업 가이드 표시
```
💡 마크업 문법 도움말
• **텍스트**: 굵게 강조
  예시: **예금**은 자유롭게...
```

---

### Phase 2: 실시간 프리뷰 (권장)

**구현 시점**: 백오피스 1차 고도화
**복잡도**: 중간

#### 분할 화면 레이아웃
```
┌─────────────────────┬─────────────────────┐
│ 편집 영역           │ 실시간 프리뷰        │
├─────────────────────┼─────────────────────┤
│ 콘텐츠:             │ ┌─────────────────┐ │
│ **예금**은 자유롭게 │ │ 예금은 자유롭게  │ │
│ 입출금이 가능하고,   │ │ 입출금이 가능하고,│ │
│ **적금**은...       │ │ 적금은...        │ │
│                     │ │                  │ │
│                     │ │ (Pretendard W500)│ │
│                     │ │ 키워드: W700     │ │
│                     │ └─────────────────┘ │
│                     │                     │
│ Tip:                │ 💡 Tip              │
│ **복리**의 힘은...  │ 복리의 힘은...      │
└─────────────────────┴─────────────────────┘
```

#### 구현 방법
```jsx
// React 예시
function ContentEditor() {
  const [content, setContent] = useState('');

  return (
    <div className="editor-container">
      <div className="edit-panel">
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
        />
      </div>

      <div className="preview-panel">
        <MobilePreview content={content} />
      </div>
    </div>
  );
}

function MobilePreview({ content }) {
  // **키워드** -> <strong>키워드</strong>
  const renderMarkdown = (text) => {
    return text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  };

  return (
    <div className="mobile-screen">
      <div
        className="learning-card"
        dangerouslySetInnerHTML={{
          __html: renderMarkdown(content)
        }}
      />
    </div>
  );
}
```

#### CSS 스타일 (앱과 동일하게)
```css
.learning-card {
  font-family: 'Pretendard', sans-serif;
  font-size: 17px;
  font-weight: 500;
  line-height: 1.7;
  color: #2D3748;
}

.learning-card strong {
  font-weight: 700;
}
```

---

### Phase 3: WYSIWYG 에디터 (고급)

**구현 시점**: 백오피스 2차 고도화
**복잡도**: 높음

#### 툴바 기반 에디터
```
┌─────────────────────────────────────────────┐
│ [B] [색상▼] [크기▼] [이미지] [실행취소]      │
├─────────────────────────────────────────────┤
│                                              │
│ 예금은 자유롭게 입출금이 가능하고,            │
│ 적금은 정해진 기간 동안 저축해요.             │
│ ^---^                                        │
│ (선택 시 툴바 활성화)                         │
│                                              │
└─────────────────────────────────────────────┘
```

#### 사용 흐름
1. 텍스트 드래그 선택
2. 툴바에서 [B] 버튼 클릭
3. 자동으로 `**예금**` 마크업 삽입
4. 실시간 프리뷰 업데이트

#### 추천 라이브러리
- **Draft.js** (Facebook): 강력한 커스터마이징
- **Slate.js**: 가벼운 React 에디터
- **TipTap**: Vue/React 호환, 마크다운 지원

#### 구현 예시 (Draft.js)
```jsx
import { Editor, EditorState, RichUtils } from 'draft-js';

function WYSIWYGEditor() {
  const [editorState, setEditorState] = useState(
    EditorState.createEmpty()
  );

  const handleBold = () => {
    setEditorState(
      RichUtils.toggleInlineStyle(editorState, 'BOLD')
    );
  };

  return (
    <>
      <button onClick={handleBold}>B</button>
      <Editor
        editorState={editorState}
        onChange={setEditorState}
      />
    </>
  );
}
```

---

## 타이포그래피 시스템 (현재 구현 상태)

### Pretendard 폰트 사용
**도입일**: 2024-12-09
**위치**: `lib/utils/theme.dart`, `pubspec.yaml`

#### 폰트 굵기 체계
| Weight | 이름 | 용도 |
|--------|------|------|
| 400 | Regular | 기본 텍스트 (bodyLarge) |
| 500 | Medium | 본문, 버튼 (bodyMedium) |
| 600 | SemiBold | 부제목 |
| 700 | Bold | 제목, 강조 키워드 |

#### 학습 콘텐츠 타이포그래피
```dart
// 본문 (일반 텍스트)
TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 17,
  fontWeight: FontWeight.w500,  // Medium
  height: 1.7,
)

// 키워드 (볼드 마크업)
TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 17,
  fontWeight: FontWeight.w700,  // Bold
  height: 1.7,
)
```

### 백오피스에서 폰트 미리보기 구현

#### 웹 폰트 로딩
```html
<!-- 백오피스 HTML head -->
<link rel="stylesheet"
  href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
```

#### CSS 적용
```css
/* 앱과 동일한 스타일 */
.preview-content {
  font-family: 'Pretendard', -apple-system, sans-serif;
  font-size: 17px;
  font-weight: 500;
  line-height: 1.7;
}

.preview-content strong {
  font-weight: 700;
}
```

---

## 마크업 확장 로드맵

### v1.0 (현재)
- [x] `**텍스트**` - 볼드
- [x] ContentTextRenderer 구현
- [x] 학습 화면 적용 (content, tip)

### v2.0 (백오피스 구축 시)
- [ ] `[color:#HEX]텍스트[/color]` - 색상
- [ ] `[size:크기]텍스트[/size]` - 크기
- [ ] 백오피스 에디터 UI (Phase 2)
- [ ] 실시간 프리뷰

### v3.0 (향후)
- [ ] `*텍스트*` - 이탤릭
- [ ] `__텍스트__` - 밑줄
- [ ] 복합 마크업 지원
- [ ] WYSIWYG 에디터 (Phase 3)

### 구현 위치
**파일**: `lib/utils/text_renderer.dart`
**확장 메서드**:
- `_parseWithColors()` - 준비됨
- `_parseWithSizes()` - 준비됨
- `_parseWithAllMarkups()` - 준비됨

---

## 백오피스 체크리스트

### 콘텐츠 관리자용
- [ ] 마크업 문법 가이드 숙지 (`docs/CONTENT_MARKUP_GUIDE.md`)
- [ ] **키워드** 형식으로 중요 용어 강조
- [ ] 한 문장에 2-3개 키워드만 강조
- [ ] 입력 후 앱에서 프리뷰 확인

### 개발자용
- [ ] Pretendard 폰트 웹폰트 로딩
- [ ] CSS 스타일 앱과 동기화
- [ ] 마크업 파싱 로직 구현 (정규식)
- [ ] 실시간 프리뷰 컴포넌트
- [ ] Firebase 저장 시 마크업 포함

### 디자이너용
- [ ] 모바일 화면 프리뷰 디자인
- [ ] 툴바 아이콘 디자인 (Phase 3)
- [ ] 색상 팔레트 정의
- [ ] 에디터 레이아웃 디자인

---

## 참고사항

- 콘텐츠는 버전 관리를 통해 A/B 테스트 가능
- 사용자 데이터는 개인정보 보호 정책 준수 필요
- 콘텐츠 CDN 활용으로 로딩 속도 최적화
- 오프라인 모드 대비 로컬 캐싱 전략 필요
- **타이포그래피 시스템**: Pretendard 폰트, 마크업 지원 (2024-12-09 추가)
- **관련 문서**:
  - `docs/CONTENT_MARKUP_GUIDE.md` - 마크업 문법 상세 가이드
  - `docs/DEVELOPMENT_LOG.md` - 구현 히스토리
  - `lib/utils/text_renderer.dart` - 렌더링 로직
