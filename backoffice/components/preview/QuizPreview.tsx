"use client";

import { useState } from "react";
import { markupToHtml } from "@/lib/markupParser";
import { ChevronLeft, ChevronRight, X } from "lucide-react";

interface QuizQuestion {
  question: string;
  options: Array<{
    text: string;
    isCorrect: boolean;
    explanation: string;
  }>;
  points: number;
}

interface QuizPreviewProps {
  questions: QuizQuestion[];
  title?: string;
}

/**
 * iPhone 14 (390x844) 퀴즈 미리보기
 * 실제 앱 화면처럼 퀴즈를 렌더링
 */
export default function QuizPreview({ questions, title = "퀴즈" }: QuizPreviewProps) {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [showExplanation, setShowExplanation] = useState(false);

  const currentQuestion = questions[currentQuestionIndex] || questions[0];
  const isFirstQuestion = currentQuestionIndex === 0;
  const isLastQuestion = currentQuestionIndex === questions.length - 1;

  const handlePrevious = () => {
    if (!isFirstQuestion) {
      setCurrentQuestionIndex(prev => prev - 1);
      setSelectedOption(null);
      setShowExplanation(false);
    }
  };

  const handleNext = () => {
    if (!isLastQuestion) {
      setCurrentQuestionIndex(prev => prev + 1);
      setSelectedOption(null);
      setShowExplanation(false);
    }
  };

  const handleSelectOption = (index: number) => {
    setSelectedOption(index);
    setShowExplanation(true);
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
                style={{ width: `${((currentQuestionIndex + 1) / questions.length) * 100}%` }}
              />
            </div>
            <span className="ml-3 text-xs text-[#D6BCFA] font-semibold">
              {Math.round(((currentQuestionIndex + 1) / questions.length) * 100)}%
            </span>
            <span className="ml-1 text-xs text-[#B794F6]">
              {currentQuestionIndex + 1}/{questions.length}
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
                  {showExplanation
                    ? (selectedOption !== null && currentQuestion?.options[selectedOption]?.isCorrect ? "정답이에요!" : "다시 한번 생각해봐요!")
                    : "문제를 풀어볼까요?"}
                </div>
              </div>
            </div>
          </div>

          {/* 퀴즈 영역 (스크롤 가능) */}
          <div className="flex-1 overflow-y-auto px-5 py-4">
            <div
              className="bg-white rounded-[20px] p-5 shadow-xl"
              style={{
                boxShadow: '0 8px 20px rgba(183, 148, 246, 0.15), 0 4px 10px rgba(0, 0, 0, 0.08)',
              }}
            >
              {/* 문제 */}
              {currentQuestion?.question && (
                <>
                  <div className="flex items-center justify-between mb-4">
                    <span className="text-sm font-semibold text-gray-500">
                      문제 {currentQuestionIndex + 1}
                    </span>
                    <span className="text-sm font-semibold text-[#B794F6]">
                      {currentQuestion.points}점
                    </span>
                  </div>

                  <div
                    className="learning-card-content mb-6"
                    dangerouslySetInnerHTML={{ __html: markupToHtml(currentQuestion.question) }}
                  />
                </>
              )}

              {/* 선택지 */}
              <div className="space-y-3">
                {currentQuestion?.options?.map((option, index) => {
                  const isSelected = selectedOption === index;
                  const isCorrect = option.isCorrect;
                  const showResult = showExplanation && isSelected;

                  return (
                    <button
                      key={index}
                      onClick={() => handleSelectOption(index)}
                      className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                        showResult
                          ? isCorrect
                            ? 'border-green-500 bg-green-50'
                            : 'border-red-500 bg-red-50'
                          : isSelected
                          ? 'border-[#B794F6] bg-[#B794F6]/5'
                          : 'border-gray-200 hover:border-[#B794F6]/50 hover:bg-gray-50'
                      }`}
                    >
                      <div className="flex items-center space-x-3">
                        <div
                          className={`w-6 h-6 rounded-full border-2 flex items-center justify-center shrink-0 ${
                            showResult && isCorrect
                              ? 'border-green-500 bg-green-500'
                              : showResult && !isCorrect
                              ? 'border-red-500 bg-red-500'
                              : isSelected
                              ? 'border-[#B794F6] bg-[#B794F6]'
                              : 'border-gray-300'
                          }`}
                        >
                          {showResult && isCorrect && (
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                            </svg>
                          )}
                          {showResult && !isCorrect && (
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          )}
                        </div>
                        <span
                          className={`flex-1 text-sm ${
                            showResult ? (isCorrect ? 'text-green-700' : 'text-red-700') : 'text-gray-700'
                          }`}
                          dangerouslySetInnerHTML={{ __html: markupToHtml(option.text) }}
                        />
                      </div>

                      {/* 해설 */}
                      {showResult && option.explanation && (
                        <div className="mt-3 pt-3 border-t border-gray-200">
                          <div
                            className="text-sm text-gray-600"
                            dangerouslySetInnerHTML={{ __html: markupToHtml(option.explanation) }}
                          />
                        </div>
                      )}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* 하단 버튼 */}
          <div className="px-5 py-5 border-t border-[#B794F6]/20 bg-[#1A1625] shrink-0">
            <div className="flex space-x-3">
              {/* 이전 버튼 */}
              {!isFirstQuestion && (
                <button
                  onClick={handlePrevious}
                  className="flex-1 py-3 px-4 border border-[#B794F6]/50 text-[#D6BCFA] font-semibold rounded-xl hover:bg-[#B794F6]/10 transition-colors flex items-center justify-center"
                >
                  <ChevronLeft className="w-4 h-4 mr-1" />
                  이전
                </button>
              )}

              {/* 다음/제출 버튼 */}
              <button
                onClick={handleNext}
                disabled={isLastQuestion}
                className={`py-3 px-4 bg-[#B794F6] text-white font-semibold rounded-xl shadow-lg transition-colors flex items-center justify-center ${
                  isFirstQuestion ? 'flex-1' : 'flex-[2]'
                } ${isLastQuestion ? 'opacity-50 cursor-not-allowed' : 'hover:bg-[#A67CE5]'}`}
              >
                {isLastQuestion ? '퀴즈 제출' : '다음 문제'}
                {!isLastQuestion && <ChevronRight className="w-4 h-4 ml-1" />}
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
