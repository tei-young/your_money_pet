"use client";

import { useState } from "react";
import { markupToHtml } from "@/lib/markupParser";
import { ChevronLeft, ChevronRight, X } from "lucide-react";

interface MobilePreviewProps {
  cards: Array<{
    content: string;
    tip?: string;
    imageUrl?: string;
    type?: string;
  }>;
  title?: string;
}

/**
 * iPhone 14 (390x844) 모바일 프레임 프리뷰
 * 실제 앱 화면처럼 학습 카드를 렌더링
 */
export default function MobilePreview({ cards, title = "예적금의 기본" }: MobilePreviewProps) {
  const [currentCardIndex, setCurrentCardIndex] = useState(0);

  const currentCard = cards[currentCardIndex] || cards[0];
  const isFirstCard = currentCardIndex === 0;
  const isLastCard = currentCardIndex === cards.length - 1;

  const handlePrevious = () => {
    if (!isFirstCard) {
      setCurrentCardIndex(prev => prev - 1);
    }
  };

  const handleNext = () => {
    if (!isLastCard) {
      setCurrentCardIndex(prev => prev + 1);
    }
  };

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
        <div className="absolute inset-0 overflow-hidden bg-[#1A1625] flex flex-col">
          {/* 상단 헤더 */}
          <div className="h-12 flex items-center px-3 border-b border-[#B794F6]/20 shrink-0">
            <button className="p-1.5">
              <X className="w-5 h-5 text-[#D6BCFA]" />
            </button>
            <span className="ml-2 text-sm text-[#D6BCFA] font-semibold">Day 1 • {title}</span>
          </div>

          {/* 진행 바 */}
          <div className="h-7 px-4 flex items-center border-b border-[#B794F6]/20 shrink-0">
            <div className="flex-1 h-1.5 bg-[#B794F6]/20 rounded-full overflow-hidden">
              <div
                className="h-full bg-[#B794F6] rounded-full transition-all duration-300"
                style={{ width: `${((currentCardIndex + 1) / cards.length) * 100}%` }}
              />
            </div>
            <span className="ml-3 text-xs text-[#D6BCFA] font-semibold">
              {Math.round(((currentCardIndex + 1) / cards.length) * 100)}%
            </span>
            <span className="ml-1 text-xs text-[#B794F6]">
              {currentCardIndex + 1}/{cards.length}
            </span>
          </div>

          {/* 캐릭터 영역 */}
          <div className="px-5 py-4 border-b border-[#B794F6]/20 shrink-0">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-[#B794F6]/30 rounded-full flex items-center justify-center text-2xl shrink-0">
                🐻
              </div>
              <div className="flex-1">
                <div className="text-sm text-[#D6BCFA] leading-relaxed">
                  {isLastCard ? "잘하고 있어요!" : "함께 배워볼까요?"}
                </div>
              </div>
            </div>
          </div>

          {/* 학습 카드 영역 (스크롤 가능) */}
          <div className="flex-1 overflow-y-auto px-5 py-4">
            <div
              className="bg-white rounded-[20px] p-5 shadow-xl min-h-full"
              style={{
                boxShadow: '0 8px 20px rgba(183, 148, 246, 0.15), 0 4px 10px rgba(0, 0, 0, 0.08)',
              }}
            >
              {/* 이미지 (있는 경우) */}
              {currentCard?.imageUrl && (
                <div className="mb-4">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={currentCard.imageUrl}
                    alt="Card image"
                    className="w-full rounded-lg"
                  />
                </div>
              )}

              {/* 카드 내용 */}
              {currentCard?.content && (
                <div
                  className="learning-card-content"
                  dangerouslySetInnerHTML={{ __html: markupToHtml(currentCard.content) }}
                />
              )}

              {/* Tip (있는 경우) */}
              {currentCard?.tip && (
                <div className="mt-4 p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <div className="flex items-start space-x-2">
                    <span className="text-base shrink-0">💡</span>
                    <div
                      className="flex-1 text-sm text-gray-700 leading-relaxed"
                      dangerouslySetInnerHTML={{ __html: markupToHtml(currentCard.tip) }}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* 하단 버튼 */}
          <div className="px-5 py-5 border-t border-[#B794F6]/20 bg-[#1A1625] shrink-0">
            <div className="flex space-x-3">
              {/* 이전 버튼 (첫 카드가 아닐 때만) */}
              {!isFirstCard && (
                <button
                  onClick={handlePrevious}
                  className="flex-1 py-3 px-4 border border-[#B794F6]/50 text-[#D6BCFA] font-semibold rounded-xl hover:bg-[#B794F6]/10 transition-colors flex items-center justify-center"
                >
                  <ChevronLeft className="w-4 h-4 mr-1" />
                  이전
                </button>
              )}

              {/* 다음/완료 버튼 */}
              <button
                onClick={handleNext}
                disabled={isLastCard}
                className={`py-3 px-4 bg-[#B794F6] text-white font-semibold rounded-xl shadow-lg transition-colors flex items-center justify-center ${
                  isFirstCard ? 'flex-1' : 'flex-[2]'
                } ${isLastCard ? 'opacity-50 cursor-not-allowed' : 'hover:bg-[#A67CE5]'}`}
              >
                {isLastCard ? '학습 완료' : '다음'}
                {!isLastCard && <ChevronRight className="w-4 h-4 ml-1" />}
              </button>
            </div>
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
