"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { collection, query, where, getDocs, deleteDoc, doc, orderBy } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Plus, Pencil, Trash2 } from "lucide-react";

interface LearningCard {
  order: number;
  type: "text" | "image" | "tip" | "quiz_link";
  content: string;
  imageUrl?: string;
}

interface LearningContent {
  id: string;
  day: number;
  personality: string;
  title: string;
  estimatedMinutes: number;
  points: number;
  cards: LearningCard[];
  createdAt: any;
  updatedAt: any;
}

interface LearningContentListProps {
  personality: string;
}

export default function LearningContentList({ personality }: LearningContentListProps) {
  const router = useRouter();
  const [contents, setContents] = useState<LearningContent[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedDay, setSelectedDay] = useState<string>("all");
  const [sortOrder, setSortOrder] = useState<"asc" | "desc">("asc");
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  // Firestore에서 데이터 로드
  useEffect(() => {
    fetchContents();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [personality]);

  const fetchContents = async () => {
    try {
      setLoading(true);
      const q = query(
        collection(db, "learning_contents"),
        where("personality", "==", personality),
        orderBy("day", "asc")
      );

      const querySnapshot = await getDocs(q);
      const fetchedContents: LearningContent[] = [];

      querySnapshot.forEach((doc) => {
        fetchedContents.push({
          id: doc.id,
          ...doc.data(),
        } as LearningContent);
      });

      setContents(fetchedContents);
    } catch (error) {
      console.error("Error fetching contents:", error);
    } finally {
      setLoading(false);
    }
  };

  // 삭제 핸들러
  const handleDelete = async (id: string) => {
    try {
      await deleteDoc(doc(db, "learning_contents", id));
      // 목록 새로고침
      fetchContents();
      setDeleteConfirm(null);
    } catch (error) {
      console.error("Error deleting content:", error);
      alert("삭제 중 오류가 발생했습니다.");
    }
  };

  // 필터링 및 정렬된 콘텐츠
  const filteredContents = contents
    .filter((content) => {
      if (selectedDay === "all") return true;
      return content.day === parseInt(selectedDay);
    })
    .sort((a, b) => {
      if (sortOrder === "asc") {
        return a.day - b.day;
      } else {
        return b.day - a.day;
      }
    });

  // 날짜 포맷팅
  const formatDate = (timestamp: any) => {
    if (!timestamp) return "-";
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString("ko-KR", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
  };

  if (loading) {
    return (
      <Card>
        <CardContent className="p-6">
          <p className="text-center text-gray-500">로딩 중...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      {/* 필터 및 액션 바 */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <CardTitle>학습 콘텐츠 목록</CardTitle>
            <Button
              onClick={() => router.push(`/dashboard/${personality}/learning/new`)}
            >
              <Plus className="mr-2 h-4 w-4" />
              새 학습 콘텐츠 추가
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex gap-4 items-center">
            {/* Day 필터 */}
            <div className="flex items-center gap-2">
              <label className="text-sm font-medium">Day:</label>
              <select
                value={selectedDay}
                onChange={(e) => setSelectedDay(e.target.value)}
                className="border rounded-md px-3 py-2 text-sm"
              >
                <option value="all">전체</option>
                {Array.from({ length: 365 }, (_, i) => i + 1).map((day) => (
                  <option key={day} value={day}>
                    Day {day}
                  </option>
                ))}
              </select>
            </div>

            {/* 정렬 */}
            <div className="flex items-center gap-2">
              <label className="text-sm font-medium">정렬:</label>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value as "asc" | "desc")}
                className="border rounded-md px-3 py-2 text-sm"
              >
                <option value="asc">Day 오름차순</option>
                <option value="desc">Day 내림차순</option>
              </select>
            </div>

            <div className="ml-auto text-sm text-gray-600">
              총 {filteredContents.length}개
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 콘텐츠 테이블 */}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Day
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    제목
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    카드 개수
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    작성일
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    수정일
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    액션
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredContents.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center text-gray-500">
                      학습 콘텐츠가 없습니다.
                      <br />
                      <span className="text-sm">
                        우측 상단의 &quot;새 학습 콘텐츠 추가&quot; 버튼을 클릭하여 추가하세요.
                      </span>
                    </td>
                  </tr>
                ) : (
                  filteredContents.map((content) => (
                    <tr key={content.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        Day {content.day}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {content.title}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {content.cards?.length || 0}개
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(content.createdAt)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(content.updatedAt)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() =>
                              router.push(`/dashboard/${personality}/learning/${content.id}`)
                            }
                          >
                            <Pencil className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setDeleteConfirm(content.id)}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      {/* 삭제 확인 모달 */}
      {deleteConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="w-full max-w-md">
            <CardHeader>
              <CardTitle>삭제 확인</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="mb-4">정말 이 학습 콘텐츠를 삭제하시겠습니까?</p>
              <p className="text-sm text-red-600 mb-6">
                ⚠️ 이 작업은 되돌릴 수 없습니다.
              </p>
              <div className="flex justify-end gap-2">
                <Button
                  variant="outline"
                  onClick={() => setDeleteConfirm(null)}
                >
                  취소
                </Button>
                <Button
                  variant="destructive"
                  onClick={() => handleDelete(deleteConfirm)}
                >
                  삭제
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
