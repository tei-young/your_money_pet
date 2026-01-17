# 백오피스 개발 현황

**작성일**: 2026-01-04
**상태**: ✅ Phase 1 완료 (콘텐츠 관리 시스템)

---

## 📊 개발 완료 항목

### 1. ✅ 실시간 모바일 미리보기

**구현 일자**: 2026-01-04

#### 학습 콘텐츠 미리보기
- **파일**: `backoffice/components/preview/MobilePreview.tsx`
- **기능**:
  - iPhone 14 프레임 (390x700px)
  - 실제 Flutter 앱 UI 재현
    - 배경색: #1A1625 (진한 다크 퍼플)
    - 액센트: #B794F6 (파스텔 보라)
  - 카드 네비게이션 (이전/다음 버튼)
  - 진행률 표시 (퍼센트 + 카드 번호)
  - 캐릭터 메시지 (마지막 카드에서 변경)
  - 콘텐츠 길이에 맞는 자동 카드 높이 조절
  - 스크롤 가능한 카드 영역

#### 퀴즈 미리보기
- **파일**: `backoffice/components/preview/QuizPreview.tsx`
- **기능**:
  - 문제별 네비게이션
  - 선택지 클릭 인터랙션
  - 정답/오답 즉시 피드백
  - 해설 자동 표시
  - 실시간 마크업 렌더링

#### 개선 사항
- 미리보기 높이 축소 (844px → 700px)
- 한눈에 볼 수 있는 크기로 최적화
- 카드 크기 자동 조절 (콘텐츠에 맞게)

---

### 2. ✅ WYSIWYG 마크업 에디터

**구현 일자**: 2026-01-04

#### 핵심 기능
- **파일**: `backoffice/components/editor/MarkupEditor.tsx`
- **위치**: 학습 콘텐츠 및 퀴즈 모든 텍스트 필드

#### 지원 마크업
1. **Bold (굵게)**: `**텍스트**`
2. **Italic (기울임)**: `*텍스트*`
3. **Underline (밑줄)**: `[u]텍스트[/u]`
4. **Strikethrough (취소선)**: `~~텍스트~~`
5. **Color (색상)**: `[color:#HEX]텍스트[/color]`
6. **Size (크기)**: `[size:large|normal|small]텍스트[/size]`

#### 에디터 UI
- **툴바 버튼**: 4개 (Bold, Italic, Underline, Strikethrough)
- **색상 선택기**: 3x2 그리드
  - 메인 보라 (#9F7AEA)
  - 초록 (#48BB78)
  - 빨강 (#F56565)
  - 주황 (#ED8936)
  - 파랑 (#4299E1)
  - 회색 (#718096)
- **크기 선택기**: 드롭다운 (큰 글씨/보통 글씨/작은 글씨)

#### 스마트 기능
- 텍스트 선택 자동 감지
- 선택된 텍스트를 마크업으로 자동 감싸기
- 선택 없을 시 커서 위치에 마크업 삽입 + 커서 이동
- 실시간 미리보기 연동

#### UI/UX 개선
- 컴팩트한 색상 선택기 (3x2 그리드)
- 적절한 크기 (w-5 h-5 색상 박스)
- 오버플로우 방지
- Hover 시 색상 이름 툴팁

---

### 3. ✅ 마크업 파서

**구현 일자**: 2026-01-04

#### 파서 로직
- **파일**: `backoffice/lib/markupParser.ts`
- **기능**: 마크업 → HTML 변환

#### 파싱 순서
1. 색상 파싱 (`[color:...]`)
2. 크기 파싱 (`[size:...]`)
3. 밑줄 파싱 (`[u]...`)
4. 볼드 파싱 (`**...`)
5. 이탤릭 파싱 (`*...`)
6. 취소선 파싱 (`~~...`)
7. HTML 변환

#### 검증 로직
- Hex 색상 코드 검증 (6자리만 허용)
- 크기 키워드 검증 (large/normal/small만)
- 잘못된 마크업 → 원본 그대로 표시

---

### 4. ✅ 통합 적용

#### 학습 콘텐츠 폼
- **파일**: `backoffice/components/learning/LearningContentForm.tsx`
- **적용 필드**:
  - 카드 내용 (`content`): MarkupEditor
  - 팁 (`tip`): MarkupEditor
- **미리보기**: 실시간 모바일 프리뷰 (split-screen)

#### 퀴즈 폼
- **파일**: `backoffice/components/quiz/QuizContentForm.tsx`
- **적용 필드**:
  - 질문 (`question`): MarkupEditor
  - 선택지 텍스트 (`options.text`): MarkupEditor
  - 해설 (`options.explanation`): MarkupEditor
- **미리보기**: 실시간 퀴즈 프리뷰 (split-screen)

---

## 🎯 주요 성과

### UX 개선
- ✅ 텍스트 입력 → WYSIWYG 에디터로 전환
- ✅ 마크업 문법 암기 불필요 (툴바 버튼 클릭)
- ✅ 실시간 미리보기로 즉시 확인
- ✅ 실제 앱 화면과 동일한 프리뷰

### 개발 효율성
- ✅ 재사용 가능한 MarkupEditor 컴포넌트
- ✅ 학습 콘텐츠 + 퀴즈 통합 적용
- ✅ 일관된 마크업 시스템

### 디자인 일관성
- ✅ 앱 컬러 팔레트로 제한
- ✅ 사전 정의된 크기만 사용
- ✅ Flutter 앱과 동일한 UI 색상

---

## 🔧 기술 스택

### Frontend
- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **UI Library**: shadcn/ui + Tailwind CSS
- **Icons**: Lucide React

### Backend
- **Database**: Firebase Firestore
- **Storage**: Firebase Storage (이미지 업로드)
- **Authentication**: Firebase Auth

### 개발 환경
- **Package Manager**: npm
- **Build Tool**: Next.js built-in
- **Version Control**: Git

---

## ⚙️ 개발 환경 설정

### Firebase 보안 규칙 (개발용)

백오피스를 로컬에서 실행하려면 Firebase Console에서 보안 규칙을 완화해야 합니다.

#### 1. Firestore Rules
- **위치**: Firebase Console → Firestore Database → 규칙
- **변경 내용**: 관리자 체크(`isAdmin()`)를 로그인 체크(`isAuthenticated()`)로 완화

```javascript
// 개발용
match /learning_contents/{contentId} {
  allow read: if true;
  allow write: if request.auth != null;
}

match /quiz_contents/{quizId} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

⚠️ **프로덕션 배포 전**: `request.auth.token.admin == true`로 변경 필수

#### 2. Storage Rules
- **위치**: Firebase Console → Storage → 규칙
- **상태**: 이미 올바르게 설정됨 ✅

```javascript
match /learning/{personality}/{imageId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

#### 3. 로컬 규칙 파일
- `firestore.rules`: 개발용 설정 적용됨 (커밋: c856c3b)
- `storage.rules`: 이미 올바르게 설정됨

**배포 방법**: Firebase Console에서 수동 배포 (로컬 파일을 복사하여 붙여넣기)

---

## 📁 주요 파일 구조

```
backoffice/
├── components/
│   ├── editor/
│   │   └── MarkupEditor.tsx          # WYSIWYG 에디터
│   ├── preview/
│   │   ├── MobilePreview.tsx         # 학습 콘텐츠 미리보기
│   │   └── QuizPreview.tsx           # 퀴즈 미리보기
│   ├── learning/
│   │   └── LearningContentForm.tsx   # 학습 콘텐츠 폼
│   └── quiz/
│       └── QuizContentForm.tsx       # 퀴즈 폼
├── lib/
│   ├── markupParser.ts               # 마크업 파서
│   └── firebase.ts                   # Firebase 설정
└── app/
    └── dashboard/
        └── [personality]/            # 성향별 대시보드
            ├── learning/
            │   ├── new/              # 새 콘텐츠 작성
            │   └── [id]/             # 콘텐츠 수정
            └── quiz/
                ├── new/              # 새 퀴즈 작성
                └── [id]/             # 퀴즈 수정
```

---

## 🚀 다음 단계

### Flutter 팀 작업 대기
- ⏳ 마크업 파싱 로직 구현 (5가지 추가)
- ⏳ TextDecoration 중첩 처리
- ⏳ 실제 콘텐츠로 테스트

### 백오피스 추가 기능 (향후)
- 📋 콘텐츠 버전 관리
- 📋 콘텐츠 복사 기능
- 📋 일괄 편집 기능
- 📋 콘텐츠 검색 및 필터링
- 📋 이미지 최적화

---

## 📝 커밋 히스토리

### 미리보기 기능
- `e490137` - Feat: Add real-time mobile preview for learning content
- `39ef4e7` - Fix: Update mobile preview with accurate UI and card navigation
- `53070e2` - Feat: Add real-time quiz preview with interactive option selection
- `dd05201` - Fix: Improve mobile preview usability and card sizing
- `d4f09ce` - Fix: Reduce quiz preview height for better visibility

### 에디터 기능
- `ef0fd35` - Feat: Add WYSIWYG markup editor with toolbar
- `e5eafa6` - Fix: Make color picker compact and prevent overflow
- `929dd08` - Refactor: Improve color picker layout to 3x2 grid
- `827f545` - Improve: Increase color picker size and spacing
- `352be9e` - Refine: Reduce color picker box size for better proportions

---

**백오피스 개발 완료!** 🎉
**Flutter 구현을 기다립니다.** 🚀
