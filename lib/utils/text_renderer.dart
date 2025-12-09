import 'package:flutter/material.dart';

/// 백오피스에서 입력된 마크다운 스타일 텍스트를 RichText로 렌더링
///
/// 현재 지원하는 문법:
/// - **텍스트**: 볼드 (굵은 글씨)
///
/// 향후 확장 예정:
/// - *텍스트*: 이탤릭
/// - __텍스트__: 밑줄
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
  static List<TextSpan> _parseContent(
    String content, {
    required TextStyle baseStyle,
    required FontWeight boldWeight,
    Color? boldColor,
  }) {
    final List<TextSpan> spans = [];

    // **텍스트** 패턴 매칭을 위한 정규식
    // 탐욕적이지 않은 매칭 (non-greedy)을 사용하여 가장 가까운 닫는 태그를 찾음
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');

    int lastIndex = 0;

    for (final match in boldPattern.allMatches(content)) {
      // 매칭 전의 일반 텍스트
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      // 볼드 텍스트 (** 제거)
      final boldText = match.group(1) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: baseStyle.copyWith(
          fontWeight: boldWeight,
          color: boldColor ?? baseStyle.color,
        ),
      ));

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

  /// 향후 확장을 위한 색상 파싱 (예시)
  ///
  /// 사용 예: [color:#FF0000]빨간 텍스트[/color]
  static List<TextSpan> _parseWithColors(
    String content,
    TextStyle baseStyle,
  ) {
    // TODO: 백오피스 구축 시 구현
    // final colorPattern = RegExp(r'\[color:(#[0-9A-Fa-f]{6})\](.+?)\[/color\]');
    return [TextSpan(text: content, style: baseStyle)];
  }

  /// 향후 확장을 위한 크기 파싱 (예시)
  ///
  /// 사용 예: [size:20]큰 텍스트[/size]
  static List<TextSpan> _parseWithSizes(
    String content,
    TextStyle baseStyle,
  ) {
    // TODO: 백오피스 구축 시 구현
    // final sizePattern = RegExp(r'\[size:(\d+)\](.+?)\[/size\]');
    return [TextSpan(text: content, style: baseStyle)];
  }

  /// 복합 마크업 파싱 (볼드 + 색상 + 크기 등)
  ///
  /// 백오피스 구축 시 이 메서드를 확장하여 모든 마크업을 처리
  static List<TextSpan> _parseWithAllMarkups(
    String content,
    TextStyle baseStyle,
  ) {
    // TODO: 백오피스 구축 시 구현
    // 1. 색상 파싱
    // 2. 크기 파싱
    // 3. 볼드/이탤릭/밑줄 파싱
    // 4. 중첩 처리
    return [TextSpan(text: content, style: baseStyle)];
  }
}

/// 백오피스 콘텐츠 입력을 위한 헬퍼 클래스
///
/// 백오피스 웹 에디터에서 사용할 문법 가이드
class ContentMarkupGuide {
  static const String guide = '''
# MoneyPet 콘텐츠 마크업 가이드

## 현재 지원 문법

### 볼드 (굵게)
**굵은 텍스트**

예시:
**예금**은 자유롭게 입출금이 가능하고, **적금**은 정해진 기간 동안 저축해요.

---

## 향후 지원 예정

### 이탤릭 (기울임)
*기울임 텍스트*

### 밑줄
__밑줄 텍스트__

### 색상
[color:#9F7AEA]보라색 텍스트[/color]
[color:#48BB78]초록색 텍스트[/color]

### 크기
[size:20]큰 텍스트[/size]
[size:14]작은 텍스트[/size]

### 복합 사용
**[color:#9F7AEA]굵고 보라색 텍스트[/color]**

---

## 주의사항

1. 마크업은 한 줄 내에서만 적용됩니다
2. 여는 태그와 닫는 태그는 반드시 쌍을 이루어야 합니다
3. 중첩 사용 시 순서를 지켜주세요
4. 특수문자는 이스케이프 처리가 필요할 수 있습니다
''';
}
