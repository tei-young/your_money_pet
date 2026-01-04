"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { collection, addDoc, doc, getDoc, updateDoc, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Plus, Trash2, ArrowLeft } from "lucide-react";
import QuizPreview from "@/components/preview/QuizPreview";
import MarkupEditor from "@/components/editor/MarkupEditor";

interface QuizOption {
  text: string;
  isCorrect: boolean;
  explanation: string;
}

interface QuizQuestion {
  order: number;
  question: string;
  options: QuizOption[];
  points: number;
}

interface QuizContentData {
  day: number;
  personality: string;
  questions: QuizQuestion[];
  totalPoints: number;
  passingScore: number;
}

interface QuizContentFormProps {
  personality: string;
  quizId?: string; // 수정 모드일 때 사용
}

export default function QuizContentForm({ personality, quizId }: QuizContentFormProps) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<QuizContentData>({
    day: 1,
    personality: personality,
    questions: [
      {
        order: 1,
        question: "",
        options: [
          { text: "", isCorrect: false, explanation: "" },
          { text: "", isCorrect: false, explanation: "" },
        ],
        points: 20,
      }
    ],
    totalPoints: 100,
    passingScore: 60,
  });

  // 수정 모드일 때 기존 데이터 불러오기
  useEffect(() => {
    if (quizId) {
      loadExistingQuiz();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [quizId]);

  const loadExistingQuiz = async () => {
    try {
      setLoading(true);
      const docRef = doc(db, "quiz_contents", quizId!);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const data = docSnap.data();
        setFormData({
          day: data.day,
          personality: data.personality,
          questions: data.questions || [],
          totalPoints: data.totalPoints,
          passingScore: data.passingScore,
        });
      } else {
        alert("퀴즈를 찾을 수 없습니다.");
        router.push(`/dashboard/${personality}`);
      }
    } catch (error) {
      console.error("Error loading quiz:", error);
      alert("데이터를 불러오는 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // 질문 추가
  const addQuestion = () => {
    const newOrder = formData.questions.length + 1;
    setFormData({
      ...formData,
      questions: [
        ...formData.questions,
        {
          order: newOrder,
          question: "",
          options: [
            { text: "", isCorrect: false, explanation: "" },
            { text: "", isCorrect: false, explanation: "" },
          ],
          points: 20,
        }
      ],
    });
  };

  // 질문 삭제
  const removeQuestion = (index: number) => {
    const newQuestions = formData.questions.filter((_, i) => i !== index);
    // order 재정렬
    const reorderedQuestions = newQuestions.map((q, i) => ({ ...q, order: i + 1 }));
    setFormData({ ...formData, questions: reorderedQuestions });
  };

  // 질문 텍스트 변경
  const updateQuestion = (index: number, question: string) => {
    const newQuestions = [...formData.questions];
    newQuestions[index] = { ...newQuestions[index], question };
    setFormData({ ...formData, questions: newQuestions });
  };

  // 질문 배점 변경
  const updateQuestionPoints = (index: number, points: number) => {
    const newQuestions = [...formData.questions];
    newQuestions[index] = { ...newQuestions[index], points };
    setFormData({ ...formData, questions: newQuestions });
  };

  // 선택지 추가
  const addOption = (questionIndex: number) => {
    const newQuestions = [...formData.questions];
    newQuestions[questionIndex].options.push({
      text: "",
      isCorrect: false,
      explanation: "",
    });
    setFormData({ ...formData, questions: newQuestions });
  };

  // 선택지 삭제
  const removeOption = (questionIndex: number, optionIndex: number) => {
    const newQuestions = [...formData.questions];
    newQuestions[questionIndex].options = newQuestions[questionIndex].options.filter(
      (_, i) => i !== optionIndex
    );
    setFormData({ ...formData, questions: newQuestions });
  };

  // 선택지 텍스트 변경
  const updateOptionText = (questionIndex: number, optionIndex: number, text: string) => {
    const newQuestions = [...formData.questions];
    newQuestions[questionIndex].options[optionIndex].text = text;
    setFormData({ ...formData, questions: newQuestions });
  };

  // 선택지 해설 변경
  const updateOptionExplanation = (questionIndex: number, optionIndex: number, explanation: string) => {
    const newQuestions = [...formData.questions];
    newQuestions[questionIndex].options[optionIndex].explanation = explanation;
    setFormData({ ...formData, questions: newQuestions });
  };

  // 정답 선택 (라디오 버튼)
  const setCorrectAnswer = (questionIndex: number, optionIndex: number) => {
    const newQuestions = [...formData.questions];
    // 모든 선택지를 오답으로 설정
    newQuestions[questionIndex].options.forEach((opt, i) => {
      opt.isCorrect = i === optionIndex;
    });
    setFormData({ ...formData, questions: newQuestions });
  };

  // 폼 검증
  const validateForm = (): boolean => {
    if (formData.day < 1 || formData.day > 365) {
      alert("Day는 1에서 365 사이여야 합니다.");
      return false;
    }

    if (formData.questions.length === 0) {
      alert("최소 1개의 문제를 추가해주세요.");
      return false;
    }

    for (let i = 0; i < formData.questions.length; i++) {
      const q = formData.questions[i];

      if (!q.question.trim()) {
        alert(`문제 ${i + 1}의 질문을 입력해주세요.`);
        return false;
      }

      if (q.options.length < 2) {
        alert(`문제 ${i + 1}은 최소 2개의 선택지가 필요합니다.`);
        return false;
      }

      const hasCorrectAnswer = q.options.some(opt => opt.isCorrect);
      if (!hasCorrectAnswer) {
        alert(`문제 ${i + 1}의 정답을 선택해주세요.`);
        return false;
      }

      for (let j = 0; j < q.options.length; j++) {
        const opt = q.options[j];
        if (!opt.text.trim()) {
          alert(`문제 ${i + 1}의 선택지 ${j + 1}의 텍스트를 입력해주세요.`);
          return false;
        }
        if (!opt.explanation.trim()) {
          alert(`문제 ${i + 1}의 선택지 ${j + 1}의 해설을 입력해주세요.`);
          return false;
        }
      }

      if (q.points <= 0) {
        alert(`문제 ${i + 1}의 배점은 0보다 커야 합니다.`);
        return false;
      }
    }

    if (formData.totalPoints <= 0) {
      alert("총점은 0보다 커야 합니다.");
      return false;
    }

    if (formData.passingScore <= 0 || formData.passingScore > formData.totalPoints) {
      alert("통과점수는 0보다 크고 총점 이하여야 합니다.");
      return false;
    }

    return true;
  };

  // 저장/수정
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      setLoading(true);

      if (quizId) {
        // 수정 모드
        const docRef = doc(db, "quiz_contents", quizId);
        await updateDoc(docRef, {
          ...formData,
          updatedAt: serverTimestamp(),
        });
        alert("퀴즈가 수정되었습니다.");
      } else {
        // 신규 작성 모드
        await addDoc(collection(db, "quiz_contents"), {
          ...formData,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
        });
        alert("퀴즈가 추가되었습니다.");
      }

      router.push(`/dashboard/${personality}`);
    } catch (error) {
      console.error("Error saving quiz:", error);
      alert("저장 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // 미리보기용 질문 배열
  const previewQuestions = formData.questions.map(q => ({
    question: q.question || "",
    options: q.options.map(opt => ({
      text: opt.text || "",
      isCorrect: opt.isCorrect,
      explanation: opt.explanation || "",
    })),
    points: q.points,
  }));

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* 왼쪽: 폼 */}
      <div className="w-full">
        <form onSubmit={handleSubmit} className="space-y-6">
      {/* 기본 정보 */}
      <Card>
        <CardHeader>
          <CardTitle>기본 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Day *</label>
              <Input
                type="number"
                min="1"
                max="365"
                value={formData.day}
                onChange={(e) => setFormData({ ...formData, day: parseInt(e.target.value) })}
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">성향</label>
              <Input value={personality} disabled className="bg-gray-100" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">총점 *</label>
              <Input
                type="number"
                min="1"
                value={formData.totalPoints}
                onChange={(e) => setFormData({ ...formData, totalPoints: parseInt(e.target.value) })}
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">통과점수 *</label>
              <Input
                type="number"
                min="1"
                value={formData.passingScore}
                onChange={(e) => setFormData({ ...formData, passingScore: parseInt(e.target.value) })}
                required
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 문제 목록 */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>문제 목록</CardTitle>
          <Button type="button" variant="outline" onClick={addQuestion}>
            <Plus className="mr-2 h-4 w-4" />
            문제 추가
          </Button>
        </CardHeader>
        <CardContent className="space-y-6">
          {formData.questions.map((question, qIndex) => (
            <Card key={qIndex} className="border-2">
              <CardHeader className="flex flex-row items-center justify-between pb-3">
                <CardTitle className="text-lg">문제 {qIndex + 1}</CardTitle>
                {formData.questions.length > 1 && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeQuestion(qIndex)}
                  >
                    <Trash2 className="h-4 w-4 text-red-500" />
                  </Button>
                )}
              </CardHeader>
              <CardContent className="space-y-4">
                {/* 질문 텍스트 */}
                <div>
                  <label className="block text-sm font-medium mb-2">질문 *</label>
                  <MarkupEditor
                    value={question.question}
                    onChange={(value) => updateQuestion(qIndex, value)}
                    placeholder="질문을 입력하세요"
                    minHeight="120px"
                  />
                </div>

                {/* 배점 */}
                <div>
                  <label className="block text-sm font-medium mb-2">배점 *</label>
                  <Input
                    type="number"
                    min="1"
                    value={question.points}
                    onChange={(e) => updateQuestionPoints(qIndex, parseInt(e.target.value))}
                    required
                  />
                </div>

                {/* 선택지 목록 */}
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <label className="block text-sm font-medium">선택지 (최소 2개)</label>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() => addOption(qIndex)}
                    >
                      <Plus className="mr-2 h-3 w-3" />
                      선택지 추가
                    </Button>
                  </div>

                  {question.options.map((option, oIndex) => (
                    <div key={oIndex} className="border rounded-lg p-4 space-y-3">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <input
                            type="radio"
                            name={`question_${qIndex}_correct`}
                            checked={option.isCorrect}
                            onChange={() => setCorrectAnswer(qIndex, oIndex)}
                            className="h-4 w-4"
                          />
                          <label className="text-sm font-medium">
                            선택지 {oIndex + 1} {option.isCorrect && "(정답)"}
                          </label>
                        </div>
                        {question.options.length > 2 && (
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={() => removeOption(qIndex, oIndex)}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        )}
                      </div>

                      <div>
                        <label className="block text-sm font-medium mb-1">선택지 텍스트 *</label>
                        <MarkupEditor
                          value={option.text}
                          onChange={(value) => updateOptionText(qIndex, oIndex, value)}
                          placeholder="선택지 텍스트"
                          minHeight="80px"
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium mb-1">해설 (정답/오답 모두 입력) *</label>
                        <MarkupEditor
                          value={option.explanation}
                          onChange={(value) => updateOptionExplanation(qIndex, oIndex, value)}
                          placeholder="해설을 입력하세요"
                          minHeight="100px"
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </CardContent>
      </Card>

      {/* 액션 버튼 */}
      <div className="flex justify-between">
        <Button
          type="button"
          variant="outline"
          onClick={() => router.push(`/dashboard/${personality}`)}
          disabled={loading}
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          취소
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? "저장 중..." : quizId ? "수정" : "저장"}
        </Button>
      </div>
        </form>
      </div>

      {/* 오른쪽: 실시간 미리보기 */}
      <div className="hidden lg:block">
        <QuizPreview
          questions={previewQuestions}
          title="퀴즈"
        />
      </div>
    </div>
  );
}
