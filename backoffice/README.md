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

### 4. Firebase 보안 규칙 설정 (개발용)

**중요**: 개발 환경에서는 Firebase Console에서 보안 규칙을 완화해야 합니다.

#### Firestore Rules 업데이트
1. https://console.firebase.google.com/ 접속
2. **moneypet-74066** 프로젝트 선택
3. **Firestore Database** → **규칙** 탭
4. 다음 부분을 수정:

```javascript
// 개발용 설정
match /learning_contents/{contentId} {
  allow read: if true;
  allow write: if request.auth != null;  // 로그인한 사용자 허용
}

match /quiz_contents/{quizId} {
  allow read: if true;
  allow write: if request.auth != null;  // 로그인한 사용자 허용
}
```

5. **게시** 버튼 클릭

⚠️ **프로덕션 배포 시**: `request.auth != null` → `request.auth.token.admin == true`로 변경 필요

#### Storage Rules 확인
Storage 규칙은 이미 올바르게 설정되어 있습니다:
```javascript
match /learning/{personality}/{imageId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

## 주요 기능

### 콘텐츠 관리
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

### 🎨 WYSIWYG 에디터 (2026-01-04 구현 완료)
- [x] 텍스트 마크업 에디터
  - [x] 툴바 버튼 (Bold, Italic, Underline, Strikethrough)
  - [x] 색상 선택기 (앱 컬러 팔레트 6가지)
  - [x] 크기 선택기 (large/normal/small)
  - [x] 텍스트 선택 자동 감지
  - [x] 마크업 자동 삽입
- [x] 마크업 파싱 시스템
  - [x] 6가지 마크업 문법 지원
  - [x] HTML 변환 로직
  - [x] 실시간 렌더링

### 📱 실시간 미리보기 (2026-01-04 구현 완료)
- [x] 학습 콘텐츠 미리보기
  - [x] iPhone 14 프레임 (390x700px)
  - [x] 실제 Flutter 앱 UI 재현
  - [x] 카드 네비게이션 (이전/다음)
  - [x] 자동 카드 높이 조절
- [x] 퀴즈 미리보기
  - [x] 문제/선택지/해설 렌더링
  - [x] 정답/오답 인터랙션
  - [x] 실시간 마크업 표시

### 📥 JSON Import (2026-02-06 구현 완료)
- [x] JSON Import 기능 (Phase 1 완료)
  - [x] 학습 콘텐츠 JSON Import
  - [x] 퀴즈 JSON Import
  - [x] 파일 업로드 / 텍스트 붙여넣기
  - [x] 검증 및 중복 처리 (덮어쓰기 확인)
  - [x] 목록 페이지 통합 ([JSON Import] 버튼)
  - [x] personality 검증 수정 (safe, balanced, aggressive, challenger)

### 향후 계획
- [ ] JSON Import Phase 2
  - [ ] 미리보기 기능 (MobilePreview/QuizPreview 재사용)
  - [ ] 일괄 Import (여러 JSON 파일 동시 업로드)
  - [ ] Import 히스토리
  - [ ] JSON Export 기능
- [ ] 사용자 통계 대시보드
- [ ] 캐릭터 설정 관리
- [ ] 콘텐츠 버전 관리
- [ ] 이미지 최적화

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
│   ├── editor/                             # 🆕 WYSIWYG 에디터
│   │   └── MarkupEditor.tsx                # 마크업 에디터 컴포넌트
│   ├── preview/                            # 🆕 실시간 미리보기
│   │   ├── MobilePreview.tsx               # 학습 콘텐츠 미리보기
│   │   └── QuizPreview.tsx                 # 퀴즈 미리보기
│   ├── learning/
│   │   ├── LearningContentList.tsx         # 학습 콘텐츠 목록
│   │   └── LearningContentForm.tsx         # 학습 콘텐츠 작성/수정 폼 (에디터 통합)
│   ├── quiz/
│   │   ├── QuizContentList.tsx             # 퀴즈 목록
│   │   └── QuizContentForm.tsx             # 퀴즈 작성/수정 폼 (에디터 통합)
│   └── ui/                                 # shadcn/ui 컴포넌트
│       ├── button.tsx
│       ├── card.tsx
│       ├── input.tsx
│       └── tabs.tsx
├── lib/                                    # 유틸리티 함수
│   ├── firebase.ts                         # Firebase 설정
│   ├── markupParser.ts                     # 🆕 마크업 파서 (마크업 → HTML)
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
