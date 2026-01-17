import 'package:flutter/material.dart';

/// 백오피스에서 입력된 마크다운 스타일 텍스트를 RichText로 렌더링
///
/// 지원하는 문법:
/// - **텍스트**: 볼드 (굵은 글씨)
/// - *텍스트*: 이탤릭 (기울임)
/// - __텍스트__: 밑줄
/// - ~~텍스트~~: 취소선
/// - [color:#FF0000]텍스트[/color]: 색상
/// - [size:20]텍스트[/size]: 크기
class ContentTextRenderer {
  /// 마크다운 텍스트를 RichText 위젯으로 변환
  ///
  /// [content]: 백오피스에서 입력된 원본 텍스트
  /// [baseStyle]: 기본 텍스트 스타일
  /// [boldWeight]: 볼드 텍스트의 fontWeight (기본: FontWeight.w600)
  static Widget render(
    String content, {
    required TextStyle baseStyle,
    FontWeight boldWeight = FontWeight.w600,
    Color? boldColor,
  }) {
    final spans = _parseContent(
      content,
      baseStyle: baseStyle,
      boldWeight: boldWeight,
      boldColor: boldColor,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }

  /// 텍스트를 파싱하여 TextSpan 리스트로 변환
  ///
  /// 모든 마크업을 하나의 정규식으로 처리하여 순차적으로 적용
  static List<TextSpan> _parseContent(
    String content, {
    required TextStyle baseStyle,
    required FontWeight boldWeight,
    Color? boldColor,
  }) {
    final List<TextSpan> spans = [];

    // 모든 마크업 패턴을 결합 (순서 중요: 긴 패턴 먼저)
    // 그룹 순서:
    // 1: 볼드 (**text**)
    // 2: 이탤릭 (*text*)
    // 3: 밑줄 (__text__)
    // 4: 취소선 (~~text~~)
    // 5: 색상 헥스값, 6: 색상 텍스트
    // 7: 크기 값, 8: 크기 텍스트
    final pattern = RegExp(
      r'\*\*(.+?)\*\*|' // 볼드
      r'(?<!\*)\*(?!\*)(.+?)\*(?!\*)|' // 이탤릭 (볼드 제외)
      r'__(.+?)__|' // 밑줄
      r'~~(.+?)~~|' // 취소선
      r'\[color:(#[0-9A-Fa-f]{6})\](.+?)\[/color\]|' // 색상
      r'\[size:(\d+)\](.+?)\[/size\]', // 크기
    );

    int lastIndex = 0;

    for (final match in pattern.allMatches(content)) {
      // 매칭 전의 일반 텍스트
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      // 어떤 마크업인지 판별하여 적용
      if (match.group(1) != null) {
        // 볼드
        spans.add(TextSpan(
          text: match.group(1)!,
          style: baseStyle.copyWith(
            fontWeight: boldWeight,
            color: boldColor ?? baseStyle.color,
          ),
        ));
      } else if (match.group(2) != null) {
        // 이탤릭
        spans.add(TextSpan(
          text: match.group(2)!,
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (match.group(3) != null) {
        // 밑줄
        spans.add(TextSpan(
          text: match.group(3)!,
          style: baseStyle.copyWith(
            decoration: TextDecoration.underline,
          ),
        ));
      } else if (match.group(4) != null) {
        // 취소선
        spans.add(TextSpan(
          text: match.group(4)!,
          style: baseStyle.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ));
      } else if (match.group(5) != null && match.group(6) != null) {
        // 색상
        final colorHex = match.group(5)!;
        final colorText = match.group(6)!;
        final color = _parseColor(colorHex);
        spans.add(TextSpan(
          text: colorText,
          style: baseStyle.copyWith(
            color: color,
          ),
        ));
      } else if (match.group(7) != null && match.group(8) != null) {
        // 크기
        final sizeStr = match.group(7)!;
        final sizeText = match.group(8)!;
        final fontSize = double.tryParse(sizeStr) ?? baseStyle.fontSize ?? 14;
        spans.add(TextSpan(
          text: sizeText,
          style: baseStyle.copyWith(
            fontSize: fontSize,
          ),
        ));
      }

      lastIndex = match.end;
    }

    // 마지막 매칭 이후의 일반 텍스트
    if (lastIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastIndex),
        style: baseStyle,
      ));
    }

    // 매칭이 하나도 없으면 전체를 일반 텍스트로 반환
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: content,
        style: baseStyle,
      ));
    }

    return spans;
  }

  /// 헥스 색상 코드를 Color로 변환
  ///
  /// [hex]: #RRGGBB 형식 (예: #FF0000)
  static Color _parseColor(String hex) {
    // #FF0000 → 0xFFFF0000
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  }

}

/// 백오피스 콘텐츠 입력을 위한 헬퍼 클래스
///
/// 백오피스 웹 에디터에서 사용할 문법 가이드
class ContentMarkupGuide {
  static const String guide = '''
# MoneyPet 콘텐츠 마크업 가이드

## 지원하는 문법 (6가지)

### 1. 볼드 (굵게)
**굵은 텍스트**

예시:
**예금**은 자유롭게 입출금이 가능하고, **적금**은 정해진 기간 동안 저축해요.

---

### 2. 이탤릭 (기울임)
*기울임 텍스트*

예시:
*중요한 개념*을 기억해주세요!

---

### 3. 밑줄
__밑줄 텍스트__

예시:
__핵심 포인트__를 확인해보세요.

---

### 4. 취소선
~~취소선 텍스트~~

예시:
~~잘못된 정보~~ → 올바른 정보

---

### 5. 색상
[color:#9F7AEA]보라색 텍스트[/color]
[color:#48BB78]초록색 텍스트[/color]
[color:#F56565]빨간색 텍스트[/color]

예시:
[color:#48BB78]수익률 상승[/color]했어요!

---

### 6. 크기
[size:20]큰 텍스트[/size]
[size:14]작은 텍스트[/size]

예시:
[size:18]중요한 숫자: 5%[/size]

---

## 주의사항

1. 마크업은 한 줄 내에서만 적용됩니다
2. 여는 태그와 닫는 태그는 반드시 쌍을 이루어야 합니다
3. 색상 코드는 #RRGGBB 형식 (6자리 헥스)만 지원합니다
4. 크기는 숫자만 입력 가능합니다 (단위 없음)
5. 현재 중첩 마크업은 제한적으로 지원됩니다

## 테스트 예시

일반 텍스트와 **굵은 텍스트**, *기울임*, __밑줄__, ~~취소선~~을 섞어서 사용할 수 있어요.

[color:#9F7AEA]보라색으로 강조[/color]하거나 [size:18]크게 표시[/size]할 수도 있습니다.
''';
}
