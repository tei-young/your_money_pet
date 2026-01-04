/**
 * 백오피스 마크업 파서
 * Flutter ContentTextRenderer와 동일한 마크업 문법 지원
 */

export interface ParsedText {
  text: string;
  bold?: boolean;
  italic?: boolean;
  underline?: boolean;
  strikethrough?: boolean;
  color?: string;
  size?: 'large' | 'normal' | 'small';
}

const SIZE_MAP = {
  large: '20px',
  normal: '17px',
  small: '14px',
};

/**
 * 마크업 텍스트를 ParsedText 배열로 변환
 */
export function parseMarkup(content: string): ParsedText[] {
  if (!content) return [{ text: '' }];

  // 1. 색상 파싱
  content = parseColors(content);

  // 2. 크기 파싱
  content = parseSizes(content);

  // 3. 밑줄 파싱
  content = parseUnderline(content);

  // 4. 볼드 파싱
  content = parseBold(content);

  // 5. 이탤릭 파싱
  content = parseItalic(content);

  // 6. 취소선 파싱
  content = parseStrikethrough(content);

  // HTML 문자열을 ParsedText 배열로 변환
  return htmlToParsedText(content);
}

/**
 * 색상 마크업 파싱: [color:#HEX]텍스트[/color]
 */
function parseColors(content: string): string {
  const colorPattern = /\[color:(#[0-9A-Fa-f]{6})\](.+?)\[\/color\]/g;

  return content.replace(colorPattern, (match, hex, text) => {
    // Hex 검증
    if (!/^#[0-9A-Fa-f]{6}$/.test(hex)) {
      return match; // 잘못된 색상은 원본 그대로
    }
    return `<span data-color="${hex}">${text}</span>`;
  });
}

/**
 * 크기 마크업 파싱: [size:large|normal|small]텍스트[/size]
 */
function parseSizes(content: string): string {
  const sizePattern = /\[size:(large|normal|small)\](.+?)\[\/size\]/gi;

  return content.replace(sizePattern, (match, size, text) => {
    const lowerSize = size.toLowerCase();
    if (!SIZE_MAP[lowerSize as keyof typeof SIZE_MAP]) {
      return match; // 잘못된 크기는 원본 그대로
    }
    return `<span data-size="${lowerSize}">${text}</span>`;
  });
}

/**
 * 밑줄 마크업 파싱: [u]텍스트[/u]
 */
function parseUnderline(content: string): string {
  const underlinePattern = /\[u\](.+?)\[\/u\]/g;
  return content.replace(underlinePattern, '<u>$1</u>');
}

/**
 * 볼드 마크업 파싱: **텍스트**
 */
function parseBold(content: string): string {
  const boldPattern = /\*\*(.+?)\*\*/g;
  return content.replace(boldPattern, '<strong>$1</strong>');
}

/**
 * 이탤릭 마크업 파싱: *텍스트* (단, **는 볼드이므로 제외)
 */
function parseItalic(content: string): string {
  // **가 아닌 *만 이탤릭 처리
  // Negative lookahead/lookbehind로 **를 제외
  const italicPattern = /(?<!\*)\*(?!\*)(.+?)\*(?!\*)/g;
  return content.replace(italicPattern, '<em>$1</em>');
}

/**
 * 취소선 마크업 파싱: ~~텍스트~~
 */
function parseStrikethrough(content: string): string {
  const strikePattern = /~~(.+?)~~/g;
  return content.replace(strikePattern, '<del>$1</del>');
}

/**
 * HTML 문자열을 ParsedText 배열로 변환
 */
function htmlToParsedText(html: string): ParsedText[] {
  const result: ParsedText[] = [];
  const div = document.createElement('div');
  div.innerHTML = html;

  function traverse(node: Node): void {
    if (node.nodeType === Node.TEXT_NODE) {
      if (node.textContent) {
        result.push({ text: node.textContent });
      }
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      const element = node as HTMLElement;
      const styles: ParsedText = { text: '' };

      // 스타일 수집
      if (element.tagName === 'STRONG') styles.bold = true;
      if (element.tagName === 'EM') styles.italic = true;
      if (element.tagName === 'U') styles.underline = true;
      if (element.tagName === 'DEL') styles.strikethrough = true;

      if (element.tagName === 'SPAN') {
        const color = element.getAttribute('data-color');
        const size = element.getAttribute('data-size');
        if (color) styles.color = color;
        if (size) styles.size = size as 'large' | 'normal' | 'small';
      }

      // 자식 노드 처리
      if (node.childNodes.length > 0) {
        const childResults: ParsedText[] = [];
        node.childNodes.forEach(child => {
          const beforeLength = result.length;
          traverse(child);
          // 방금 추가된 항목들에 현재 스타일 적용
          for (let i = beforeLength; i < result.length; i++) {
            result[i] = { ...styles, ...result[i], text: result[i].text };
          }
        });
      }
    }
  }

  traverse(div);
  return result;
}

/**
 * ParsedText를 React 스타일 객체로 변환
 */
export function parsedTextToStyle(parsed: ParsedText): React.CSSProperties {
  const style: React.CSSProperties = {};

  if (parsed.bold) style.fontWeight = 700;
  if (parsed.italic) style.fontStyle = 'italic';

  const decorations: string[] = [];
  if (parsed.underline) decorations.push('underline');
  if (parsed.strikethrough) decorations.push('line-through');
  if (decorations.length > 0) {
    style.textDecoration = decorations.join(' ');
  }

  if (parsed.color) style.color = parsed.color;
  if (parsed.size) style.fontSize = SIZE_MAP[parsed.size];

  return style;
}

/**
 * 마크업 텍스트를 HTML로 직접 변환 (간단한 프리뷰용)
 */
export function markupToHtml(content: string): string {
  if (!content) return '';

  let html = content;

  // 1. 색상
  html = html.replace(
    /\[color:(#[0-9A-Fa-f]{6})\](.+?)\[\/color\]/g,
    (match, hex, text) => {
      if (!/^#[0-9A-Fa-f]{6}$/.test(hex)) return match;
      return `<span style="color: ${hex}">${text}</span>`;
    }
  );

  // 2. 크기
  html = html.replace(
    /\[size:(large|normal|small)\](.+?)\[\/size\]/gi,
    (match, size, text) => {
      const lowerSize = size.toLowerCase();
      const fontSize = SIZE_MAP[lowerSize as keyof typeof SIZE_MAP];
      if (!fontSize) return match;
      return `<span style="font-size: ${fontSize}">${text}</span>`;
    }
  );

  // 3. 밑줄
  html = html.replace(/\[u\](.+?)\[\/u\]/g, '<u>$1</u>');

  // 4. 볼드
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

  // 5. 이탤릭 (** 제외)
  html = html.replace(/(?<!\*)\*(?!\*)(.+?)\*(?!\*)/g, '<em>$1</em>');

  // 6. 취소선
  html = html.replace(/~~(.+?)~~/g, '<del>$1</del>');

  // 줄바꿈 처리
  html = html.replace(/\n/g, '<br />');

  return html;
}
