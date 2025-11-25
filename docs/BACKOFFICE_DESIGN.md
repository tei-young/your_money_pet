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
```dart
// LearningContent Collection
{
  "contentId": "day_001_safe",
  "day": 1,
  "personalityType": "safe",  // null이면 공통
  "title": "예적금의 기본",
  "cards": [
    {
      "order": 1,
      "type": "text",  // text, image, video
      "content": "예금과 적금의 차이는...",
      "imageUrl": null
    }
  ],
  "estimatedMinutes": 3,
  "points": 50,
  "isPublished": true,
  "version": "1.0",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z",
  "createdBy": "admin_user_id",
  "tags": ["예금", "적금", "기본"]
}
```

#### 2.2 Quiz Content (퀴즈 콘텐츠)
```dart
// QuizContent Collection
{
  "quizId": "day_001_safe_quiz",
  "day": 1,
  "personalityType": "safe",
  "questions": [
    {
      "order": 1,
      "question": "예금과 적금의 차이는?",
      "options": [
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
  "isPublished": true,
  "version": "1.0",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z",
  "createdBy": "admin_user_id"
}
```

#### 2.3 Character Config (캐릭터 설정)
```dart
// CharacterConfig Collection
{
  "characterId": "money_bear",
  "personalityType": "safe",
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
  "version": "1.0",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

#### 2.4 App Config (앱 설정)
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
  "updatedAt": "2025-01-15T10:00:00Z",
  "updatedBy": "admin_user_id"
}
```

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

### Phase 1: 데이터 모델 개선
- [ ] User 모델에 백오피스 필드 추가 (createdAt, updatedAt, metadata)
- [ ] Content 모델 생성 (LearningContent, QuizContent)
- [ ] CharacterConfig 모델 생성
- [ ] AppConfig 모델 생성

### Phase 2: Firebase 연동
- [ ] Firestore 컬렉션 설계 및 생성
- [ ] User CRUD 구현
- [ ] Content CRUD 구현
- [ ] 로컬 캐싱 전략

### Phase 3: 백오피스 웹 개발
- [ ] 관리자 인증 (Firebase Auth)
- [ ] 사용자 관리 페이지
- [ ] 콘텐츠 관리 페이지 (WYSIWYG 에디터)
- [ ] 퀴즈 관리 페이지
- [ ] 통계 대시보드

### Phase 4: 고도화
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

## 참고사항

- 콘텐츠는 버전 관리를 통해 A/B 테스트 가능
- 사용자 데이터는 개인정보 보호 정책 준수 필요
- 콘텐츠 CDN 활용으로 로딩 속도 최적화
- 오프라인 모드 대비 로컬 캐싱 전략 필요
