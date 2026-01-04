"use client";

import { useRef, useState } from "react";
import { Bold, Italic, Underline, Strikethrough, Palette, Type } from "lucide-react";
import { Button } from "@/components/ui/button";

interface MarkupEditorProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  minHeight?: string;
}

/**
 * WYSIWYG 마크업 에디터
 * 텍스트 선택 후 버튼 클릭으로 마크업 자동 삽입
 */
export default function MarkupEditor({
  value,
  onChange,
  placeholder = "내용을 입력하세요",
  minHeight = "200px",
}: MarkupEditorProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [showColorPicker, setShowColorPicker] = useState(false);
  const [showSizePicker, setShowSizePicker] = useState(false);

  /**
   * 선택된 텍스트를 마크업으로 감싸기
   */
  const wrapSelection = (prefix: string, suffix: string) => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = value.substring(start, end);

    // 선택된 텍스트가 없으면 커서 위치에 마크업만 삽입
    if (selectedText === "") {
      const newValue = value.substring(0, start) + prefix + suffix + value.substring(end);
      onChange(newValue);

      // 커서를 마크업 사이로 이동
      setTimeout(() => {
        textarea.focus();
        textarea.setSelectionRange(start + prefix.length, start + prefix.length);
      }, 0);
      return;
    }

    // 선택된 텍스트를 마크업으로 감싸기
    const newValue =
      value.substring(0, start) +
      prefix +
      selectedText +
      suffix +
      value.substring(end);

    onChange(newValue);

    // 선택 영역 유지 (마크업 포함)
    setTimeout(() => {
      textarea.focus();
      textarea.setSelectionRange(start, start + prefix.length + selectedText.length + suffix.length);
    }, 0);
  };

  const insertBold = () => wrapSelection("**", "**");
  const insertItalic = () => wrapSelection("*", "*");
  const insertUnderline = () => wrapSelection("[u]", "[/u]");
  const insertStrikethrough = () => wrapSelection("~~", "~~");

  const insertColor = (color: string) => {
    wrapSelection(`[color:${color}]`, "[/color]");
    setShowColorPicker(false);
  };

  const insertSize = (size: "large" | "normal" | "small") => {
    wrapSelection(`[size:${size}]`, "[/size]");
    setShowSizePicker(false);
  };

  // 앱 컬러 팔레트
  const colors = [
    { name: "메인 보라", value: "#9F7AEA" },
    { name: "초록", value: "#48BB78" },
    { name: "빨강", value: "#F56565" },
    { name: "주황", value: "#ED8936" },
    { name: "파랑", value: "#4299E1" },
    { name: "회색", value: "#718096" },
  ];

  return (
    <div className="border rounded-lg overflow-hidden">
      {/* 툴바 */}
      <div className="bg-gray-50 border-b px-3 py-2 flex items-center gap-1 flex-wrap">
        {/* 텍스트 스타일 */}
        <div className="flex items-center gap-1 pr-2 border-r">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={insertBold}
            title="굵게 (**텍스트**)"
            className="h-8 w-8 p-0"
          >
            <Bold className="h-4 w-4" />
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={insertItalic}
            title="기울임 (*텍스트*)"
            className="h-8 w-8 p-0"
          >
            <Italic className="h-4 w-4" />
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={insertUnderline}
            title="밑줄 ([u]텍스트[/u])"
            className="h-8 w-8 p-0"
          >
            <Underline className="h-4 w-4" />
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={insertStrikethrough}
            title="취소선 (~~텍스트~~)"
            className="h-8 w-8 p-0"
          >
            <Strikethrough className="h-4 w-4" />
          </Button>
        </div>

        {/* 색상 */}
        <div className="relative">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => {
              setShowColorPicker(!showColorPicker);
              setShowSizePicker(false);
            }}
            title="색상 ([color:#HEX]텍스트[/color])"
            className="h-8 w-8 p-0"
          >
            <Palette className="h-4 w-4" />
          </Button>

          {/* 색상 선택기 */}
          {showColorPicker && (
            <div className="absolute top-full left-0 mt-1 bg-white border rounded-lg shadow-lg p-1.5 z-10">
              <div className="flex gap-1">
                {colors.map((color) => (
                  <button
                    key={color.value}
                    type="button"
                    onClick={() => insertColor(color.value)}
                    className="p-1 rounded hover:bg-gray-100 transition-colors"
                    title={color.name}
                  >
                    <div
                      className="w-6 h-6 rounded border border-gray-300"
                      style={{ backgroundColor: color.value }}
                    />
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* 크기 */}
        <div className="relative">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => {
              setShowSizePicker(!showSizePicker);
              setShowColorPicker(false);
            }}
            title="크기 ([size:large|normal|small]텍스트[/size])"
            className="h-8 w-8 p-0"
          >
            <Type className="h-4 w-4" />
          </Button>

          {/* 크기 선택기 */}
          {showSizePicker && (
            <div className="absolute top-full left-0 mt-1 bg-white border rounded-lg shadow-lg p-1 z-10 min-w-[120px]">
              <button
                type="button"
                onClick={() => insertSize("large")}
                className="w-full text-left px-3 py-2 rounded hover:bg-gray-50 transition-colors text-lg font-semibold"
              >
                큰 글씨
              </button>
              <button
                type="button"
                onClick={() => insertSize("normal")}
                className="w-full text-left px-3 py-2 rounded hover:bg-gray-50 transition-colors text-base"
              >
                보통 글씨
              </button>
              <button
                type="button"
                onClick={() => insertSize("small")}
                className="w-full text-left px-3 py-2 rounded hover:bg-gray-50 transition-colors text-sm"
              >
                작은 글씨
              </button>
            </div>
          )}
        </div>

        {/* 가이드 */}
        <div className="ml-auto text-xs text-gray-500">
          텍스트를 선택하고 버튼을 클릭하세요
        </div>
      </div>

      {/* 텍스트 입력 영역 */}
      <textarea
        ref={textareaRef}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full px-4 py-3 focus:outline-none resize-none font-['Pretendard']"
        style={{ minHeight }}
        onClick={() => {
          setShowColorPicker(false);
          setShowSizePicker(false);
        }}
      />
    </div>
  );
}
