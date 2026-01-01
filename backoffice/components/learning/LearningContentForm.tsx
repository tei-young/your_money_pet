"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { collection, addDoc, doc, getDoc, updateDoc, serverTimestamp } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { db } from "@/lib/firebase";
import { getStorage } from "firebase/storage";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Plus, Trash2, Upload, ArrowLeft } from "lucide-react";

interface LearningCard {
  order: number;
  type: "text" | "image" | "quiz_link";
  content: string;
  imageUrl?: string;
  tip?: string;
}

interface LearningContentData {
  day: number;
  personality: string;
  title: string;
  estimatedMinutes: number;
  points: number;
  cards: LearningCard[];
}

interface LearningContentFormProps {
  personality: string;
  contentId?: string; // 수정 모드일 때 사용
}

export default function LearningContentForm({ personality, contentId }: LearningContentFormProps) {
  const router = useRouter();
  const storage = getStorage();

  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<LearningContentData>({
    day: 1,
    personality: personality,
    title: "",
    estimatedMinutes: 3,
    points: 50,
    cards: [
      { order: 1, type: "text", content: "" }
    ],
  });

  const [uploadingImages, setUploadingImages] = useState<{ [key: number]: boolean }>({});

  // 수정 모드일 때 기존 데이터 불러오기
  useEffect(() => {
    if (contentId) {
      loadExistingContent();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [contentId]);

  const loadExistingContent = async () => {
    try {
      setLoading(true);
      const docRef = doc(db, "learning_contents", contentId!);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const data = docSnap.data();
        setFormData({
          day: data.day,
          personality: data.personality,
          title: data.title,
          estimatedMinutes: data.estimatedMinutes,
          points: data.points,
          cards: data.cards || [],
        });
      } else {
        alert("콘텐츠를 찾을 수 없습니다.");
        router.push(`/dashboard/${personality}`);
      }
    } catch (error) {
      console.error("Error loading content:", error);
      alert("데이터를 불러오는 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // 카드 추가
  const addCard = () => {
    const newOrder = formData.cards.length + 1;
    setFormData({
      ...formData,
      cards: [
        ...formData.cards,
        { order: newOrder, type: "text", content: "" }
      ],
    });
  };

  // 카드 삭제
  const removeCard = (index: number) => {
    const newCards = formData.cards.filter((_, i) => i !== index);
    // order 재정렬
    const reorderedCards = newCards.map((card, i) => ({
      ...card,
      order: i + 1,
    }));
    setFormData({ ...formData, cards: reorderedCards });
  };

  // 카드 타입 변경
  const updateCardType = (index: number, type: LearningCard["type"]) => {
    const newCards = [...formData.cards];
    newCards[index] = { ...newCards[index], type };
    setFormData({ ...formData, cards: newCards });
  };

  // 카드 내용 변경
  const updateCardContent = (index: number, content: string) => {
    const newCards = [...formData.cards];
    newCards[index] = { ...newCards[index], content };
    setFormData({ ...formData, cards: newCards });
  };

  // 카드 팁 변경
  const updateCardTip = (index: number, tip: string) => {
    const newCards = [...formData.cards];
    newCards[index] = { ...newCards[index], tip };
    setFormData({ ...formData, cards: newCards });
  };

  // 이미지 업로드
  const handleImageUpload = async (index: number, file: File) => {
    try {
      setUploadingImages(prev => ({ ...prev, [index]: true }));

      // Firebase Storage에 업로드
      const timestamp = Date.now();
      const fileName = `learning/${personality}/${timestamp}_${file.name}`;
      const storageRef = ref(storage, fileName);

      await uploadBytes(storageRef, file);
      const downloadURL = await getDownloadURL(storageRef);

      // 카드에 이미지 URL 저장 (함수형 업데이트)
      setFormData(prev => {
        const newCards = [...prev.cards];
        newCards[index] = {
          ...newCards[index],
          imageUrl: downloadURL,
          content: newCards[index].content || file.name, // content가 비어있으면 파일명 사용
        };
        return { ...prev, cards: newCards };
      });

      setUploadingImages(prev => ({ ...prev, [index]: false }));

      // 업로드 성공 피드백
      console.log(`✅ 이미지 업로드 완료 (카드 ${index + 1}):`, downloadURL);
    } catch (error) {
      console.error("Error uploading image:", error);
      alert("이미지 업로드 중 오류가 발생했습니다.");
      setUploadingImages(prev => ({ ...prev, [index]: false }));
    }
  };

  // 폼 검증
  const validateForm = (): boolean => {
    if (!formData.title.trim()) {
      alert("제목을 입력해주세요.");
      return false;
    }

    if (formData.day < 1 || formData.day > 365) {
      alert("Day는 1~365 사이의 값이어야 합니다.");
      return false;
    }

    if (formData.cards.length === 0) {
      alert("최소 1개의 카드를 추가해주세요.");
      return false;
    }

    for (let i = 0; i < formData.cards.length; i++) {
      const card = formData.cards[i];
      if (!card.content.trim() && card.type !== "image") {
        alert(`카드 ${i + 1}의 내용을 입력해주세요.`);
        return false;
      }
      if (card.type === "image" && !card.imageUrl) {
        alert(`카드 ${i + 1}의 이미지를 업로드해주세요.`);
        return false;
      }
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

      if (contentId) {
        // 수정 모드
        const docRef = doc(db, "learning_contents", contentId);
        await updateDoc(docRef, {
          ...formData,
          updatedAt: serverTimestamp(),
        });
        alert("학습 콘텐츠가 수정되었습니다.");
      } else {
        // 신규 작성 모드
        await addDoc(collection(db, "learning_contents"), {
          ...formData,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
        });
        alert("학습 콘텐츠가 추가되었습니다.");
      }

      router.push(`/dashboard/${personality}`);
    } catch (error) {
      console.error("Error saving content:", error);
      alert("저장 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  if (loading && contentId) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>로딩 중...</p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* 기본 정보 */}
      <Card>
        <CardHeader>
          <CardTitle>기본 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Day */}
            <div>
              <label className="block text-sm font-medium mb-2">Day *</label>
              <Input
                type="number"
                min={1}
                max={365}
                value={formData.day}
                onChange={(e) => setFormData({ ...formData, day: parseInt(e.target.value) })}
                required
              />
            </div>

            {/* 제목 */}
            <div>
              <label className="block text-sm font-medium mb-2">제목 *</label>
              <Input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="예: 예적금의 기본"
                required
              />
            </div>

            {/* 예상 소요 시간 */}
            <div>
              <label className="block text-sm font-medium mb-2">예상 소요 시간 (분) *</label>
              <Input
                type="number"
                min={1}
                value={formData.estimatedMinutes}
                onChange={(e) => setFormData({ ...formData, estimatedMinutes: parseInt(e.target.value) })}
                required
              />
            </div>

            {/* 포인트 */}
            <div>
              <label className="block text-sm font-medium mb-2">포인트 *</label>
              <Input
                type="number"
                min={0}
                value={formData.points}
                onChange={(e) => setFormData({ ...formData, points: parseInt(e.target.value) })}
                required
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 카드 목록 */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <CardTitle>학습 카드 ({formData.cards.length}개)</CardTitle>
            <Button type="button" onClick={addCard} size="sm">
              <Plus className="mr-2 h-4 w-4" />
              카드 추가
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {formData.cards.map((card, index) => (
            <Card key={index} className="border-2">
              <CardHeader>
                <div className="flex justify-between items-center">
                  <h4 className="font-semibold">카드 {card.order}</h4>
                  {formData.cards.length > 1 && (
                    <Button
                      type="button"
                      variant="destructive"
                      size="sm"
                      onClick={() => removeCard(index)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                {/* 카드 타입 선택 */}
                <div>
                  <label className="block text-sm font-medium mb-2">카드 타입 *</label>
                  <select
                    value={card.type}
                    onChange={(e) => updateCardType(index, e.target.value as LearningCard["type"])}
                    className="w-full border rounded-md px-3 py-2"
                  >
                    <option value="text">텍스트</option>
                    <option value="image">이미지</option>
                    <option value="quiz_link">퀴즈 링크</option>
                  </select>
                </div>

                {/* 카드 타입별 입력 필드 */}
                {card.type === "image" ? (
                  <div className="space-y-2">
                    <label className="block text-sm font-medium">이미지 업로드 *</label>
                    <Input
                      type="file"
                      accept="image/*"
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) handleImageUpload(index, file);
                      }}
                      disabled={uploadingImages[index]}
                    />
                    {uploadingImages[index] && (
                      <p className="text-sm text-gray-500">업로드 중...</p>
                    )}
                    {card.imageUrl && (
                      <div className="mt-2">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={card.imageUrl}
                          alt={`Card ${index + 1}`}
                          className="max-w-xs rounded border"
                        />
                      </div>
                    )}
                    <Input
                      type="text"
                      value={card.content}
                      onChange={(e) => updateCardContent(index, e.target.value)}
                      placeholder="이미지 설명 (선택사항)"
                    />
                  </div>
                ) : (
                  <div>
                    <label className="block text-sm font-medium mb-2">내용 *</label>
                    <textarea
                      value={card.content}
                      onChange={(e) => updateCardContent(index, e.target.value)}
                      className="w-full border rounded-md px-3 py-2 min-h-[100px]"
                      placeholder={
                        card.type === "quiz_link"
                          ? "퀴즈 ID 또는 링크를 입력하세요"
                          : "학습 내용을 입력하세요"
                      }
                      required
                    />
                  </div>
                )}

                {/* 팁 추가 섹션 (선택사항) */}
                <details className="mt-3">
                  <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900">
                    💡 팁 추가하기 (선택사항)
                  </summary>
                  <div className="mt-2">
                    <textarea
                      value={card.tip || ""}
                      onChange={(e) => updateCardTip(index, e.target.value)}
                      className="w-full border rounded-md px-3 py-2 min-h-[80px]"
                      placeholder="이 카드와 관련된 팁이나 추가 정보를 입력하세요"
                    />
                  </div>
                </details>
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
          {loading ? "저장 중..." : contentId ? "수정하기" : "저장하기"}
        </Button>
      </div>
    </form>
  );
}
