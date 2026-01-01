# MoneyPet 백오피스

MoneyPet 앱의 학습 콘텐츠 및 퀴즈를 관리하는 백오피스 시스템

## 기술 스택

- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **Database:** Firebase Firestore
- **Authentication:** Firebase Auth

## 개발 환경 설정

### 1. 의존성 설치

```bash
cd backoffice
npm install
```

### 2. Firebase 설정

1. Firebase 프로젝트: `moneypet-74066`
2. `.env.local` 파일 생성 (아래 참고)

```.env.local
# Firebase Config
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=moneypet-74066
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_storage_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### 3. 개발 서버 실행

```bash
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

## 주요 기능

- [x] 관리자 로그인 (Firebase Auth + Custom Claims)
- [x] 학습 콘텐츠 관리 (CRUD)
  - [x] 성향별 콘텐츠 목록 조회
  - [x] 신규 콘텐츠 생성
  - [x] 기존 콘텐츠 수정
  - [x] 콘텐츠 삭제
  - [x] 이미지 업로드 (Firebase Storage)
  - [x] 동적 카드 관리 (text, image, quiz_link)
  - [x] 선택적 팁 추가
- [x] 퀴즈 관리 (CRUD)
  - [x] 성향별 퀴즈 목록 조회
  - [x] 신규 퀴즈 생성 (동적 질문/선택지)
  - [x] 기존 퀴즈 수정
  - [x] 퀴즈 삭제
  - [x] 정답 선택 (라디오 버튼)
  - [x] 선택지별 해설 관리
- [ ] 사용자 통계 대시보드
- [ ] 캐릭터 설정 관리

## 프로젝트 구조

```
backoffice/
├── app/                                    # Next.js App Router
│   ├── dashboard/
│   │   ├── page.tsx                        # 성향 선택 대시보드
│   │   └── [personality]/
│   │       ├── page.tsx                    # 성향별 메인 (학습/퀴즈 탭)
│   │       ├── learning/
│   │       │   ├── new/
│   │       │   │   └── page.tsx            # 신규 학습 콘텐츠 작성
│   │       │   └── [id]/
│   │       │       └── page.tsx            # 학습 콘텐츠 수정
│   │       └── quiz/
│   │           ├── new/
│   │           │   └── page.tsx            # 신규 퀴즈 작성
│   │           └── [id]/
│   │               └── page.tsx            # 퀴즈 수정
│   ├── login/
│   │   └── page.tsx                        # 관리자 로그인
│   ├── layout.tsx                          # 루트 레이아웃
│   ├── page.tsx                            # 홈 페이지 (리다이렉트)
│   └── globals.css                         # 전역 스타일
├── components/
│   ├── learning/
│   │   ├── LearningContentList.tsx         # 학습 콘텐츠 목록
│   │   └── LearningContentForm.tsx         # 학습 콘텐츠 작성/수정 폼
│   ├── quiz/
│   │   ├── QuizContentList.tsx             # 퀴즈 목록
│   │   └── QuizContentForm.tsx             # 퀴즈 작성/수정 폼
│   └── ui/                                 # shadcn/ui 컴포넌트
│       ├── button.tsx
│       ├── card.tsx
│       ├── input.tsx
│       └── tabs.tsx
├── lib/                                    # 유틸리티 함수
│   ├── firebase.ts                         # Firebase 설정
│   └── utils.ts                            # Tailwind 유틸리티
├── public/                                 # 정적 파일
└── package.json
```

## 개발 가이드

### 관리자 계정

백오피스에 접근하려면 Firebase에서 `admin` custom claim이 설정된 계정이 필요합니다.

관리자 권한 부여 방법:
```bash
cd ../scripts
node set-admin.js <USER_UID>
```

## 배포

TBD

## 라이센스

Private
