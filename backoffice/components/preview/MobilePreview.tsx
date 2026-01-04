"use client";

import { markupToHtml } from "@/lib/markupParser";

interface MobilePreviewProps {
  content: string;
  tip?: string;
  imageUrl?: string;
  type?: 'learning' | 'quiz';
}

/**
 * iPhone 14 (390x844) 모바일 프레임 프리뷰
 * 실제 앱 화면처럼 학습 카드를 렌더링
 */
export default function MobilePreview({ content, tip, imageUrl, type = 'learning' }: MobilePreviewProps) {
  return (
    <div className="flex flex-col items-center justify-start p-4 bg-gray-100 rounded-lg sticky top-4">
      {/* 디바이스 라벨 */}
      <div className="text-xs text-gray-500 mb-2">미리보기 (iPhone 14)</div>

      {/* iPhone 14 프레임 */}
      <div
        className="relative bg-black rounded-[40px] shadow-2xl overflow-hidden"
        style={{
          width: '390px',
          height: '844px',
        }}
      >
        {/* 노치 */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[150px] h-[30px] bg-black rounded-b-3xl z-20" />

        {/* 화면 */}
        <div className="absolute inset-0 overflow-y-auto bg-[#5B21B6]">
          {/* 상단 헤더 */}
          <div className="h-12 flex items-center px-3 border-b border-purple-400/20">
            <button className="p-1.5">
              <svg className="w-5 h-5 text-purple-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
            <span className="ml-2 text-sm text-purple-200 font-semibold">Day 1 • 예적금의 기본</span>
          </div>

          {/* 진행 바 */}
          <div className="h-7 px-4 flex items-center border-b border-purple-400/20">
            <div className="flex-1 h-1.5 bg-purple-400/20 rounded-full overflow-hidden">
              <div className="h-full w-1/3 bg-purple-300 rounded-full" />
            </div>
            <span className="ml-3 text-xs text-purple-200 font-semibold">33%</span>
            <span className="ml-1 text-xs text-purple-400">1/3</span>
          </div>

          {/* 캐릭터 영역 (간소화) */}
          <div className="px-5 py-4 border-b border-purple-400/20">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-purple-400/30 rounded-full flex items-center justify-center text-2xl">
                🐻
              </div>
              <div className="flex-1">
                <div className="text-sm text-purple-100 leading-relaxed">
                  함께 배워볼까요?
                </div>
              </div>
            </div>
          </div>

          {/* 학습 카드 영역 */}
          <div className="px-5 py-4 flex-1">
            <div
              className="bg-white rounded-[20px] p-5 shadow-xl"
              style={{
                boxShadow: '0 8px 20px rgba(139, 92, 246, 0.15), 0 4px 10px rgba(0, 0, 0, 0.08)',
              }}
            >
              {/* 이미지 (있는 경우) */}
              {imageUrl && (
                <div className="mb-4">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={imageUrl}
                    alt="Card image"
                    className="w-full rounded-lg"
                  />
                </div>
              )}

              {/* 카드 내용 */}
              <div
                className="learning-card-content"
                dangerouslySetInnerHTML={{ __html: markupToHtml(content) }}
              />

              {/* Tip (있는 경우) */}
              {tip && (
                <div className="mt-4 p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <div className="flex items-start space-x-2">
                    <span className="text-base">💡</span>
                    <div
                      className="flex-1 text-sm text-gray-700 leading-relaxed"
                      dangerouslySetInnerHTML={{ __html: markupToHtml(tip) }}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* 하단 버튼 */}
          <div className="px-5 py-4">
            <button className="w-full py-3.5 bg-purple-400 hover:bg-purple-500 text-white font-semibold rounded-xl shadow-lg transition-colors">
              다음
            </button>
          </div>
        </div>
      </div>

      {/* 스타일 정의 */}
      <style jsx global>{`
        .learning-card-content {
          font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
          font-size: 17px;
          font-weight: 500;
          line-height: 1.7;
          color: #2D3748;
        }

        .learning-card-content strong {
          font-weight: 700;
        }

        .learning-card-content em {
          font-style: italic;
        }

        .learning-card-content u {
          text-decoration: underline;
        }

        .learning-card-content del {
          text-decoration: line-through;
        }
      `}</style>
    </div>
  );
}
