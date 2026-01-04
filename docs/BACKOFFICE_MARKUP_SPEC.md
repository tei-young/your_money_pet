# 백오피스 텍스트 마크업 시스템 구현 요청서

**작성일**: 2026-01-04
**담당**: 백오피스 팀 → Flutter 팀
**우선순위**: 중간 (백오피스 구현 완료 후)

---

## 📋 개요

백오피스에서 WYSIWYG 에디터를 통해 작성된 마크업을 Flutter 앱에서 렌더링하기 위한 파싱 로직 구현 요청입니다.

**현재 상태**:
- ✅ 볼드(`**텍스트**`) 구현 완료
- 🚧 색상, 크기, 이탤릭, 밑줄, 취소선 파싱 필요

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

### 현재 적용 중
- ✅ 학습 카드 `content` 필드
- ✅ 학습 카드 `tip` 필드

### 추가 적용 (선택)
- ☐ 퀴즈 `question` 필드
- ☐ 퀴즈 `options.text` 필드
- ☐ 퀴즈 `options.explanation` 필드

**결정 필요**: 퀴즈에도 마크업 적용할지 논의 후 결정

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

**백오피스 개발**: 2026-01-04 ~ 2026-01-10 (1주)
**Flutter 구현 요청**: 백오피스 완료 후
**예상 소요**: 2-3일 (파싱 로직 + 테스트)

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

## ❓ 질문/이슈

### 1. 퀴즈 마크업 적용 여부
**질문**: 퀴즈 문제/선택지/해설에도 마크업을 적용할까요?
**현재**: 학습 콘텐츠만 적용
**제안**: 퀴즈도 동일하게 적용하면 일관성 유지

### 2. 색상 팔레트 제한
**질문**: 모든 Hex 색상 허용? 아니면 특정 색상만?
**현재**: 모든 Hex 색상 허용
**대안**: 앱 컬러 팔레트만 허용 (디자인 일관성)

### 3. Decoration 중첩
**질문**: 밑줄+취소선 동시 사용 시?
**예시**: `[u]~~밑줄과 취소선~~[/u]`
**Flutter 제약**: `TextDecoration.combine([...])`으로 처리 필요

---

## 👤 담당자

**백오피스**: [이름]
**Flutter**: [Flutter 팀 담당자 지정 필요]
**문의**: 백오피스 팀 채널

---

**승인 후 Flutter 구현 시작해주세요!** ✅
