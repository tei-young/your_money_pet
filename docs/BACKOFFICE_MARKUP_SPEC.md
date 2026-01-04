# 백오피스 텍스트 마크업 시스템 구현 요청서

**작성일**: 2026-01-04
**업데이트**: 2026-01-04 (백오피스 구현 완료)
**담당**: 백오피스 팀 → Flutter 팀
**상태**: 🟢 백오피스 완료, Flutter 구현 대기

---

## 📋 개요

백오피스에서 WYSIWYG 에디터를 통해 작성된 마크업을 Flutter 앱에서 렌더링하기 위한 파싱 로직 구현 요청입니다.

**백오피스 구현 상태** (✅ 완료):
- ✅ WYSIWYG 에디터 구현 완료
- ✅ 실시간 모바일 미리보기 구현 완료
- ✅ 6가지 마크업 문법 지원 (Bold, Italic, Underline, Strikethrough, Color, Size)
- ✅ 학습 콘텐츠 및 퀴즈 전체 적용 완료

**Flutter 구현 필요사항**:
- 🚧 색상, 크기, 이탤릭, 밑줄, 취소선 파싱 로직 추가
- ✅ 볼드(`**텍스트**`)는 이미 구현됨

**목표**:
- 백오피스에서 입력한 모든 마크업을 Flutter 앱에서 정확히 렌더링
- 기존 `ContentTextRenderer` 클래스 확장

---

## 🎯 구현 범위

### 1. 볼드 (Bold) - ✅ 이미 구현됨
```
**텍스트**
```
**Flutter 렌더링**: `fontWeight: FontWeight.w700`

---

### 2. 이탤릭 (Italic) - 🆕 신규
```
*텍스트*
```
**Flutter 렌더링**: `fontStyle: FontStyle.italic`

**주의**:
- 단일 `*`만 이탤릭 처리
- `**`는 볼드로 처리 (기존 유지)

---

### 3. 밑줄 (Underline) - 🆕 신규
```
[u]텍스트[/u]
```
**Flutter 렌더링**: `decoration: TextDecoration.underline`

**참고**:
- 표준 마크다운 준수 위해 `__텍스트__` 대신 HTML 스타일 사용
- `__`는 마크다운에서 볼드를 의미하므로 혼동 방지

---

### 4. 취소선 (Strikethrough) - 🆕 신규
```
~~텍스트~~
```
**Flutter 렌더링**: `decoration: TextDecoration.lineThrough`

---

### 5. 색상 (Color) - 🆕 신규
```
[color:#9F7AEA]보라색 텍스트[/color]
[color:#FF0000]빨간색[/color]
```
**Flutter 렌더링**: `color: Color(0xFF9F7AEA)`

**규칙**:
- Hex 코드 6자리 (`#RRGGBB`)
- 대소문자 구분 없음 (`#FF0000` = `#ff0000`)
- 잘못된 색상 코드 → 마크업 무시, 일반 텍스트로 표시

**정규식 예시**:
```dart
final colorPattern = RegExp(r'\[color:(#[0-9A-Fa-f]{6})\](.+?)\[/color\]');
```

---

### 6. 크기 (Size) - 🆕 신규
```
[size:large]큰 글씨[/size]
[size:normal]보통 글씨[/size]
[size:small]작은 글씨[/size]
```

**크기 매핑 (사전 정의)**:
| 키워드 | 픽셀 크기 | 비고 |
|--------|----------|------|
| `large` | 20px | 강조 제목 |
| `normal` | 17px | 기본값 (현재 사용 중) |
| `small` | 14px | 작은 설명 |

**Flutter 렌더링**: `fontSize: 20.0`

**규칙**:
- 허용된 값: `large`, `normal`, `small`만 (대소문자 구분 없음)
- 잘못된 크기 → 마크업 무시, 일반 텍스트로 표시
- 예: `[size:huge]텍스트[/size]` → 그냥 `[size:huge]텍스트[/size]` 표시

**정규식 예시**:
```dart
final sizePattern = RegExp(r'\[size:(large|normal|small)\](.+?)\[/size\]', caseSensitive: false);
```

---

## 🔗 복합 마크업 (중첩 허용)

**허용 예시**:
```
**[color:#FF0000]굵고 빨간색[/color]**
*[size:large]크고 이탤릭[/size]*
[u]**굵은 밑줄**[/u]
~~[color:#999999]회색 취소선[/color]~~
```

**파싱 순서** (권장):
1. 색상 파싱 (`[color:...]`)
2. 크기 파싱 (`[size:...]`)
3. 밑줄 파싱 (`[u]...`)
4. 볼드 파싱 (`**...`)
5. 이탤릭 파싱 (`*...`)
6. 취소선 파싱 (`~~...`)

**구현 방법**:
- 각 패턴을 순차적으로 파싱
- `TextSpan` children으로 중첩 구조 생성

**예시 코드 구조**:
```dart
TextSpan(
  text: '굵고 빨간색',
  style: baseStyle.copyWith(
    fontWeight: FontWeight.w700,  // **에서
    color: Color(0xFFFF0000),     // [color:#FF0000]에서
  ),
)
```

---

## ❌ 잘못된 입력 처리

**정책**: 잘못된 마크업은 무시하고 일반 텍스트로 표시

**예시**:

| 입력 | 출력 | 이유 |
|------|------|------|
| `[color:#ZZZZZZ]텍스트[/color]` | `[color:#ZZZZZZ]텍스트[/color]` | 잘못된 Hex 코드 |
| `[size:huge]텍스트[/size]` | `[size:huge]텍스트[/size]` | 정의되지 않은 크기 |
| `**닫히지 않은 볼드` | `**닫히지 않은 볼드` | 닫는 태그 없음 |
| `[color:#FF0000]닫히지 않음` | `[color:#FF0000]닫히지 않음` | 닫는 태그 없음 |

**구현 팁**:
- 정규식 매칭 실패 시 원본 그대로 반환
- Try-catch로 파싱 에러 방지

---

## 🛠 구현 가이드

### 파일 위치
```
lib/utils/text_renderer.dart
```

### 수정할 메서드
```dart
class ContentTextRenderer {
  // 1. 기존 _parseContent() 확장
  static List<TextSpan> _parseContent(...) {
    // TODO: 색상, 크기, 이탤릭, 밑줄, 취소선 파싱 추가
  }

  // 2. 현재 TODO인 메서드 구현
  static List<TextSpan> _parseWithColors(...) { ... }
  static List<TextSpan> _parseWithSizes(...) { ... }

  // 3. 새 메서드 추가
  static List<TextSpan> _parseWithUnderline(...) { ... }
  static List<TextSpan> _parseWithItalic(...) { ... }
  static List<TextSpan> _parseWithStrikethrough(...) { ... }
  static List<TextSpan> _parseWithAllMarkups(...) { ... } // 통합 파서
}
```

### 파싱 로직 예시 (색상)

```dart
static List<TextSpan> _parseWithColors(
  String content,
  TextStyle baseStyle,
) {
  final List<TextSpan> spans = [];
  final colorPattern = RegExp(r'\[color:(#[0-9A-Fa-f]{6})\](.+?)\[/color\]');

  int lastIndex = 0;

  for (final match in colorPattern.allMatches(content)) {
    // 매칭 전 일반 텍스트
    if (match.start > lastIndex) {
      spans.add(TextSpan(
        text: content.substring(lastIndex, match.start),
        style: baseStyle,
      ));
    }

    // 색상 텍스트
    final hexColor = match.group(1)!; // #9F7AEA
    final text = match.group(2)!;

    try {
      final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
      spans.add(TextSpan(
        text: text,
        style: baseStyle.copyWith(color: color),
      ));
    } catch (e) {
      // 잘못된 색상 → 원본 그대로
      spans.add(TextSpan(
        text: match.group(0)!,
        style: baseStyle,
      ));
    }

    lastIndex = match.end;
  }

  // 마지막 일반 텍스트
  if (lastIndex < content.length) {
    spans.add(TextSpan(
      text: content.substring(lastIndex),
      style: baseStyle,
    ));
  }

  return spans.isEmpty ? [TextSpan(text: content, style: baseStyle)] : spans;
}
```

---

## ✅ 테스트 케이스

### 기본 테스트

```dart
// 1. 볼드
"**예금**은 자유롭게"
→ "예금" (W700), "은 자유롭게" (W500)

// 2. 이탤릭
"*강조*된 텍스트"
→ "강조" (italic), "된 텍스트" (normal)

// 3. 색상
"[color:#FF0000]빨강[/color]입니다"
→ "빨강" (빨간색), "입니다" (기본색)

// 4. 크기
"[size:large]큰 글씨[/size]예요"
→ "큰 글씨" (20px), "예요" (17px)

// 5. 밑줄
"[u]밑줄[/u] 텍스트"
→ "밑줄" (underline), " 텍스트" (normal)

// 6. 취소선
"~~삭제~~된 내용"
→ "삭제" (lineThrough), "된 내용" (normal)
```

### 복합 테스트

```dart
// 7. 볼드 + 색상
"**[color:#9F7AEA]보라색 볼드[/color]**"
→ fontWeight: W700, color: #9F7AEA

// 8. 이탤릭 + 크기
"*[size:large]크고 기울임[/size]*"
→ fontSize: 20, fontStyle: italic

// 9. 3중 중첩
"~~[u]**취소되고 밑줄 치고 굵은**[/u]~~"
→ lineThrough + underline + W700
```

### 에러 처리 테스트

```dart
// 10. 잘못된 색상
"[color:#ZZZZZZ]텍스트[/color]"
→ 원본 그대로 표시

// 11. 잘못된 크기
"[size:huge]텍스트[/size]"
→ 원본 그대로 표시

// 12. 닫히지 않은 태그
"**열렸지만 안 닫힘"
→ 원본 그대로 표시
```

---

## 📱 적용 위치

### 학습 콘텐츠 (필수)
- ✅ 학습 카드 `content` 필드
- ✅ 학습 카드 `tip` 필드

### 퀴즈 (필수)
- ✅ 퀴즈 `question` 필드
- ✅ 퀴즈 `options.text` 필드
- ✅ 퀴즈 `options.explanation` 필드

**확정**: 학습 콘텐츠와 퀴즈 모두 마크업 적용 필수

---

## 🎨 디자인 스펙

### 기본 텍스트 스타일 (변경 없음)
```dart
TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 17,           // normal 크기
  fontWeight: FontWeight.w500,
  height: 1.7,
  color: AppColors.textPrimary,  // #2D3748
)
```

### 마크업 적용 시
```dart
// 볼드
fontWeight: FontWeight.w700

// 이탤릭
fontStyle: FontStyle.italic

// 밑줄
decoration: TextDecoration.underline

// 취소선
decoration: TextDecoration.lineThrough

// 색상 (예: 빨강)
color: Color(0xFFFF0000)

// 크기
fontSize: 20.0   // large
fontSize: 17.0   // normal
fontSize: 14.0   // small
```

---

## 📅 일정

**백오피스 개발**: ✅ 완료 (2026-01-04)
- WYSIWYG 에디터 구현
- 실시간 미리보기 구현
- 학습 콘텐츠 및 퀴즈 통합

**Flutter 구현 요청**: 🚀 지금 시작 가능
**예상 소요**: 2-3일 (파싱 로직 + 테스트)

---

## 🖥️ 백오피스 구현 세부사항

### WYSIWYG 에디터

**위치**: `backoffice/components/editor/MarkupEditor.tsx`

**기능**:
- **툴바 버튼**: Bold, Italic, Underline, Strikethrough
- **색상 선택기**: 3x2 그리드, 앱 컬러 팔레트 6가지
  - 메인 보라 (#9F7AEA)
  - 초록 (#48BB78)
  - 빨강 (#F56565)
  - 주황 (#ED8936)
  - 파랑 (#4299E1)
  - 회색 (#718096)
- **크기 선택기**: 드롭다운 메뉴 (large/normal/small)
- **텍스트 선택 자동 감지**: 드래그 선택 후 버튼 클릭으로 마크업 자동 삽입

### 실시간 미리보기

**학습 콘텐츠 미리보기**: `backoffice/components/preview/MobilePreview.tsx`
- iPhone 14 프레임 (390x700px)
- 카드 네비게이션 (이전/다음 버튼)
- 실제 Flutter 앱 UI 색상 (#1A1625 배경, #B794F6 액센트)
- 콘텐츠 크기에 맞는 자동 카드 높이 조절

**퀴즈 미리보기**: `backoffice/components/preview/QuizPreview.tsx`
- 문제/선택지/해설 실시간 렌더링
- 선택지 클릭 시 정답/오답 표시
- 해설 즉시 표시

### 적용 범위

**학습 콘텐츠**:
- `content` 필드: MarkupEditor 적용
- `tip` 필드: MarkupEditor 적용

**퀴즈**:
- `question` 필드: MarkupEditor 적용
- `options.text` 필드: MarkupEditor 적용
- `options.explanation` 필드: MarkupEditor 적용

**마크업 파서**: `backoffice/lib/markupParser.ts`
- 6가지 마크업 문법을 HTML로 변환
- 미리보기에서 실시간 렌더링

---

## 🔍 참고 자료

### 현재 구현 코드
```
lib/utils/text_renderer.dart (18-95줄)
```

### 기존 볼드 파싱 로직
```dart
final boldPattern = RegExp(r'\*\*(.+?)\*\*');
// non-greedy matching으로 가장 가까운 닫는 태그 찾음
```

### 마크업 가이드 문서
```
docs/CONTENT_MARKUP_GUIDE.md
```

---

## ❓ 질문/이슈 (해결됨)

### 1. 퀴즈 마크업 적용 여부 - ✅ 해결
**질문**: 퀴즈 문제/선택지/해설에도 마크업을 적용할까요?
**결정**: ✅ 퀴즈 전체 적용 확정
- `question` 필드
- `options.text` 필드
- `options.explanation` 필드

### 2. 색상 팔레트 제한 - ✅ 해결
**질문**: 모든 Hex 색상 허용? 아니면 특정 색상만?
**결정**: ✅ 앱 컬러 팔레트 6가지로 제한
- 백오피스 에디터에서 선택 가능한 색상만 사용
- 디자인 일관성 유지
- 임의의 Hex 코드 입력 불가

### 3. Decoration 중첩 - ⚠️ Flutter 구현 필요
**질문**: 밑줄+취소선 동시 사용 시?
**예시**: `[u]~~밑줄과 취소선~~[/u]`
**Flutter 제약**: `TextDecoration.combine([...])`으로 처리 필요
**백오피스**: 중첩 마크업 입력 가능 (에디터에서 막지 않음)

---

## 👤 담당자

**백오피스**: ✅ 완료
**Flutter**: [Flutter 팀 담당자 지정 필요]
**문의**: 백오피스 팀 채널

---

## 🚀 다음 단계

**Flutter 팀 작업 사항**:
1. `lib/utils/text_renderer.dart`에 5가지 마크업 파싱 로직 추가
   - 이탤릭 (`*텍스트*`)
   - 밑줄 (`[u]텍스트[/u]`)
   - 취소선 (`~~텍스트~~`)
   - 색상 (`[color:#HEX]텍스트[/color]`)
   - 크기 (`[size:large|normal|small]텍스트[/size]`)

2. 중첩 마크업 처리
   - `TextDecoration.combine([])` 활용
   - 복합 스타일 적용 테스트

3. 테스트
   - 백오피스에서 생성한 실제 콘텐츠로 테스트
   - 문서의 테스트 케이스 참고

**백오피스는 준비 완료! Flutter 구현만 기다립니다.** 🎉
