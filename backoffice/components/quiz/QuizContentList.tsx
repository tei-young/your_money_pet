"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { collection, query, where, orderBy, getDocs, deleteDoc, doc, Timestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Plus, Pencil, Trash2, FileJson } from "lucide-react";
import QuizJsonImport from "@/components/import/QuizJsonImport";

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
  id: string;
  day: number;
  personality: string;
  questions: QuizQuestion[];
  totalPoints: number;
  passingScore: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface QuizContentListProps {
  personality: string;
}

export default function QuizContentList({ personality }: QuizContentListProps) {
  const router = useRouter();
  const [quizzes, setQuizzes] = useState<QuizContentData[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [selectedQuizId, setSelectedQuizId] = useState<string | null>(null);
  const [dayFilter, setDayFilter] = useState<string>("");
  const [sortOrder, setSortOrder] = useState<"asc" | "desc">("asc");
  const [isJsonImportOpen, setIsJsonImportOpen] = useState(false);

  useEffect(() => {
    loadQuizzes();
  }, [personality]);

  const loadQuizzes = async () => {
    try {
      setLoading(true);
      const q = query(
        collection(db, "quiz_contents"),
        where("personality", "==", personality),
        orderBy("day", sortOrder)
      );
      const querySnapshot = await getDocs(q);
      const quizData: QuizContentData[] = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as QuizContentData));
      setQuizzes(quizData);
    } catch (error) {
      console.error("Error loading quizzes:", error);
      alert("퀴즈 목록을 불러오는 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedQuizId) return;

    try {
      await deleteDoc(doc(db, "quiz_contents", selectedQuizId));
      alert("퀴즈가 삭제되었습니다.");
      setDeleteModalOpen(false);
      setSelectedQuizId(null);
      loadQuizzes();
    } catch (error) {
      console.error("Error deleting quiz:", error);
      alert("퀴즈 삭제 중 오류가 발생했습니다.");
    }
  };

  const openDeleteModal = (quizId: string) => {
    setSelectedQuizId(quizId);
    setDeleteModalOpen(true);
  };

  const filteredQuizzes = dayFilter
    ? quizzes.filter(quiz => quiz.day === parseInt(dayFilter))
    : quizzes;

  const toggleSortOrder = () => {
    setSortOrder(prev => prev === "asc" ? "desc" : "asc");
    loadQuizzes();
  };

  return (
    <div className="space-y-4">
      {/* 상단 액션 바 */}
      <div className="flex justify-between items-center">
        <div className="flex gap-2">
          <input
            type="number"
            min="1"
            max="365"
            placeholder="Day 필터"
            value={dayFilter}
            onChange={(e) => setDayFilter(e.target.value)}
            className="border rounded-md px-3 py-2 w-32"
          />
          <Button variant="outline" onClick={toggleSortOrder}>
            정렬: {sortOrder === "asc" ? "오름차순" : "내림차순"}
          </Button>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={() => setIsJsonImportOpen(true)}
          >
            <FileJson className="mr-2 h-4 w-4" />
            JSON Import
          </Button>
          <Button
            onClick={() => router.push(`/dashboard/${personality}/quiz/new`)}
          >
            <Plus className="mr-2 h-4 w-4" />
            퀴즈 추가
          </Button>
        </div>
      </div>

      {/* 퀴즈 목록 */}
      {loading ? (
        <div className="text-center py-8">로딩 중...</div>
      ) : filteredQuizzes.length === 0 ? (
        <Card>
          <CardContent className="py-8 text-center text-gray-500">
            {dayFilter ? `Day ${dayFilter}의 퀴즈가 없습니다.` : "퀴즈가 없습니다. 새 퀴즈를 추가해주세요."}
          </CardContent>
        </Card>
      ) : (
        <div className="border rounded-lg overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Day</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">문제 개수</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">총점</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">통과점수</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">작성일</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">수정일</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">액션</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredQuizzes.map((quiz) => (
                <tr key={quiz.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    Day {quiz.day}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {quiz.questions.length}문제
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {quiz.totalPoints}점
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {quiz.passingScore}점
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {quiz.createdAt?.toDate().toLocaleDateString("ko-KR")}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {quiz.updatedAt?.toDate().toLocaleDateString("ko-KR")}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <div className="flex gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() =>
                          router.push(`/dashboard/${personality}/quiz/${quiz.id}`)
                        }
                      >
                        <Pencil className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openDeleteModal(quiz.id)}
                      >
                        <Trash2 className="h-4 w-4 text-red-500" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* 삭제 확인 모달 */}
      {deleteModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="w-full max-w-md">
            <CardHeader>
              <CardTitle>퀴즈 삭제</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="mb-4">정말로 이 퀴즈를 삭제하시겠습니까?</p>
              <div className="flex justify-end gap-2">
                <Button
                  variant="outline"
                  onClick={() => {
                    setDeleteModalOpen(false);
                    setSelectedQuizId(null);
                  }}
                >
                  취소
                </Button>
                <Button variant="destructive" onClick={handleDelete}>
                  삭제
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* JSON Import 모달 */}
      <QuizJsonImport
        personality={personality}
        isOpen={isJsonImportOpen}
        onClose={() => setIsJsonImportOpen(false)}
        onSuccess={() => {
          loadQuizzes();
          setIsJsonImportOpen(false);
        }}
      />
    </div>
  );
}
