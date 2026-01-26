"use client";

import { useState, useRef } from "react";
import { collection, addDoc, query, where, getDocs, doc, updateDoc, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { FileUp, CheckCircle, XCircle, AlertTriangle } from "lucide-react";

interface LearningCard {
  order: number;
  type: "text" | "image" | "quiz_link";
  content: string;
  imageUrl?: string;
  tip?: string | null;
}

interface LearningContentData {
  day: number;
  personality: string;
  title: string;
  estimatedMinutes: number;
  points: number;
  cards: LearningCard[];
}

interface LearningJsonImportProps {
  personality: string;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface ValidationResult {
  success: boolean;
  data?: LearningContentData;
  error?: string;
}

export default function LearningJsonImport({
  personality,
  isOpen,
  onClose,
  onSuccess,
}: LearningJsonImportProps) {
  const [activeTab, setActiveTab] = useState<"file" | "text">("file");
  const [jsonInput, setJsonInput] = useState("");
  const [validationResult, setValidationResult] = useState<ValidationResult | null>(null);
  const [isValidating, setIsValidating] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [showOverwriteConfirm, setShowOverwriteConfirm] = useState(false);
  const [existingDocId, setExistingDocId] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // 파일 업로드 처리
  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.name.endsWith(".json")) {
      alert("JSON 파일만 업로드 가능합니다.");
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      const text = e.target?.result as string;
      setJsonInput(text);
      setValidationResult(null);
    };
    reader.readAsText(file);
  };

  // JSON 검증
  const validateJson = () => {
    setIsValidating(true);
    setValidationResult(null);

    try {
      // 1. JSON 파싱
      const data = JSON.parse(jsonInput);

      // 2. 필수 필드 검증
      const requiredFields = ["day", "personality", "title", "estimatedMinutes", "points", "cards"];
      for (const field of requiredFields) {
        if (!(field in data)) {
          throw new Error(`필수 필드 '${field}'이 누락되었습니다.`);
        }
      }

      // 3. 타입 검증
      if (typeof data.day !== "number") {
        throw new Error(`'day'는 숫자여야 합니다. (현재: ${typeof data.day})`);
      }
      if (typeof data.personality !== "string") {
        throw new Error(`'personality'는 문자열이어야 합니다. (현재: ${typeof data.personality})`);
      }
      if (typeof data.title !== "string") {
        throw new Error(`'title'은 문자열이어야 합니다. (현재: ${typeof data.title})`);
      }
      if (typeof data.estimatedMinutes !== "number") {
        throw new Error(`'estimatedMinutes'는 숫자여야 합니다. (현재: ${typeof data.estimatedMinutes})`);
      }
      if (typeof data.points !== "number") {
        throw new Error(`'points'는 숫자여야 합니다. (현재: ${typeof data.points})`);
      }
      if (!Array.isArray(data.cards)) {
        throw new Error("'cards'는 배열이어야 합니다.");
      }

      // 4. 값 범위 검증
      if (data.day <= 0) {
        throw new Error(`'day'는 양수여야 합니다. (현재: ${data.day})`);
      }
      if (!["safe", "aggressive", "hunter_cat"].includes(data.personality)) {
        throw new Error(`'personality'는 'safe', 'aggressive', 'hunter_cat' 중 하나여야 합니다. (현재: ${data.personality})`);
      }
      if (data.title.trim() === "") {
        throw new Error("'title'은 비어있지 않아야 합니다.");
      }
      if (data.estimatedMinutes <= 0) {
        throw new Error(`'estimatedMinutes'는 양수여야 합니다. (현재: ${data.estimatedMinutes})`);
      }
      if (data.points <= 0) {
        throw new Error(`'points'는 양수여야 합니다. (현재: ${data.points})`);
      }

      // 5. 배열 검증
      if (data.cards.length === 0) {
        throw new Error("cards 배열이 비어있습니다. 최소 1개 이상의 카드가 필요합니다.");
      }

      // 6. 카드 필드 검증
      const orders = new Set<number>();
      for (let i = 0; i < data.cards.length; i++) {
        const card = data.cards[i];

        // 필수 필드
        if (!("order" in card)) {
          throw new Error(`cards[${i}]에 'order' 필드가 없습니다.`);
        }
        if (!("type" in card)) {
          throw new Error(`cards[${i}]에 'type' 필드가 없습니다.`);
        }
        if (!("content" in card)) {
          throw new Error(`cards[${i}]에 'content' 필드가 없습니다.`);
        }

        // 타입 검증
        if (typeof card.order !== "number") {
          throw new Error(`cards[${i}].order는 숫자여야 합니다. (현재: ${typeof card.order})`);
        }
        if (!["text", "image", "quiz_link"].includes(card.type)) {
          throw new Error(`cards[${i}].type은 'text', 'image', 'quiz_link' 중 하나여야 합니다. (현재: ${card.type})`);
        }
        if (typeof card.content !== "string") {
          throw new Error(`cards[${i}].content는 문자열이어야 합니다. (현재: ${typeof card.content})`);
        }

        // 값 검증
        if (card.order <= 0) {
          throw new Error(`cards[${i}].order는 양수여야 합니다. (현재: ${card.order})`);
        }
        if (card.content.trim() === "") {
          throw new Error(`cards[${i}].content는 비어있지 않아야 합니다.`);
        }

        // order 중복 체크
        if (orders.has(card.order)) {
          throw new Error(`cards[${i}].order가 중복되었습니다. (order: ${card.order})`);
        }
        orders.add(card.order);
      }

      // 7. order 연속성 검증
      const sortedOrders = Array.from(orders).sort((a, b) => a - b);
      for (let i = 0; i < sortedOrders.length; i++) {
        if (sortedOrders[i] !== i + 1) {
          throw new Error(`cards의 order가 연속적이지 않습니다. (기대: ${i + 1}, 실제: ${sortedOrders[i]})`);
        }
      }

      // personality 덮어쓰기 (현재 선택된 성향으로)
      data.personality = personality;

      setValidationResult({
        success: true,
        data: data as LearningContentData,
      });
    } catch (error: unknown) {
      if (error instanceof SyntaxError) {
        setValidationResult({
          success: false,
          error: "유효하지 않은 JSON 형식입니다. JSON 문법을 확인해주세요.",
        });
      } else if (error instanceof Error) {
        setValidationResult({
          success: false,
          error: error.message,
        });
      } else {
        setValidationResult({
          success: false,
          error: "알 수 없는 오류가 발생했습니다.",
        });
      }
    } finally {
      setIsValidating(false);
    }
  };

  // 중복 체크
  const checkDuplicate = async (day: number): Promise<string | null> => {
    const q = query(
      collection(db, "learning_contents"),
      where("personality", "==", personality),
      where("day", "==", day)
    );
    const querySnapshot = await getDocs(q);

    if (!querySnapshot.empty) {
      return querySnapshot.docs[0].id;
    }
    return null;
  };

  // Firestore에 저장
  const saveToFirestore = async (overwrite: boolean = false) => {
    if (!validationResult?.success || !validationResult.data) return;

    setIsSaving(true);

    try {
      const data = validationResult.data;

      // 중복 체크
      const docId = await checkDuplicate(data.day);

      if (docId && !overwrite) {
        // 중복 발견 - 확인 팝업 표시
        setExistingDocId(docId);
        setShowOverwriteConfirm(true);
        setIsSaving(false);
        return;
      }

      // 저장 데이터 준비
      const saveData = {
        ...data,
        updatedAt: serverTimestamp(),
      };

      if (docId && overwrite) {
        // 덮어쓰기
        await updateDoc(doc(db, "learning_contents", docId), saveData);
        alert("학습 콘텐츠가 성공적으로 업데이트되었습니다!");
      } else {
        // 새로 생성
        await addDoc(collection(db, "learning_contents"), {
          ...saveData,
          createdAt: serverTimestamp(),
        });
        alert("학습 콘텐츠가 성공적으로 저장되었습니다!");
      }

      // 성공 처리
      onSuccess();
      handleClose();
    } catch (error) {
      console.error("저장 실패:", error);
      alert("저장 중 오류가 발생했습니다. 콘솔을 확인해주세요.");
    } finally {
      setIsSaving(false);
    }
  };

  // 덮어쓰기 확인
  const handleOverwrite = () => {
    setShowOverwriteConfirm(false);
    saveToFirestore(true);
  };

  // 모달 닫기
  const handleClose = () => {
    setActiveTab("file");
    setJsonInput("");
    setValidationResult(null);
    setExistingDocId(null);
    setShowOverwriteConfirm(false);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
    onClose();
  };

  return (
    <>
      <Dialog open={isOpen} onOpenChange={(open: boolean) => !open && handleClose()}>
        <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>JSON Import - 학습 콘텐츠</DialogTitle>
          </DialogHeader>

          <Tabs value={activeTab} onValueChange={(value) => setActiveTab(value as "file" | "text")}>
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="file">파일 업로드</TabsTrigger>
              <TabsTrigger value="text">JSON 붙여넣기</TabsTrigger>
            </TabsList>

            <TabsContent value="file" className="space-y-4">
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                <FileUp className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                <input
                  ref={fileInputRef}
                  type="file"
                  accept=".json"
                  onChange={handleFileUpload}
                  className="hidden"
                  id="file-upload"
                />
                <label htmlFor="file-upload">
                  <Button type="button" onClick={() => fileInputRef.current?.click()}>
                    JSON 파일 선택
                  </Button>
                </label>
                <p className="text-sm text-gray-500 mt-2">
                  .json 파일만 업로드 가능합니다
                </p>
              </div>

              {jsonInput && (
                <div className="space-y-2">
                  <p className="text-sm font-medium">파일 내용:</p>
                  <Textarea
                    value={jsonInput}
                    onChange={(e) => setJsonInput(e.target.value)}
                    rows={10}
                    className="font-mono text-sm"
                  />
                </div>
              )}
            </TabsContent>

            <TabsContent value="text" className="space-y-4">
              <div className="space-y-2">
                <p className="text-sm font-medium">JSON 데이터를 붙여넣으세요:</p>
                <Textarea
                  value={jsonInput}
                  onChange={(e) => setJsonInput(e.target.value)}
                  placeholder='{"day": 1, "personality": "safe", "title": "...", ...}'
                  rows={15}
                  className="font-mono text-sm"
                />
              </div>
            </TabsContent>
          </Tabs>

          {/* 검증 버튼 */}
          <div className="flex justify-end">
            <Button
              onClick={validateJson}
              disabled={!jsonInput || isValidating}
              className="w-32"
            >
              {isValidating ? "검증 중..." : "검증하기"}
            </Button>
          </div>

          {/* 검증 결과 */}
          {validationResult && (
            <div
              className={`p-4 rounded-lg border ${
                validationResult.success
                  ? "bg-green-50 border-green-200"
                  : "bg-red-50 border-red-200"
              }`}
            >
              <div className="flex items-start gap-3">
                {validationResult.success ? (
                  <CheckCircle className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                ) : (
                  <XCircle className="h-5 w-5 text-red-600 mt-0.5 flex-shrink-0" />
                )}
                <div className="flex-1">
                  <p className={`font-semibold ${validationResult.success ? "text-green-800" : "text-red-800"}`}>
                    {validationResult.success ? "✅ 검증 성공" : "❌ 검증 실패"}
                  </p>
                  {validationResult.success && validationResult.data && (
                    <div className="mt-2 text-sm text-green-700">
                      <p>Day {validationResult.data.day}: {validationResult.data.title}</p>
                      <p>{validationResult.data.cards.length}개 카드, {validationResult.data.estimatedMinutes}분, {validationResult.data.points}점</p>
                    </div>
                  )}
                  {!validationResult.success && (
                    <p className="mt-1 text-sm text-red-700 whitespace-pre-wrap">{validationResult.error}</p>
                  )}
                </div>
              </div>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={handleClose} disabled={isSaving}>
              취소
            </Button>
            <Button
              onClick={() => saveToFirestore(false)}
              disabled={!validationResult?.success || isSaving}
            >
              {isSaving ? "저장 중..." : "저장"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* 덮어쓰기 확인 다이얼로그 */}
      <AlertDialog open={showOverwriteConfirm} onOpenChange={setShowOverwriteConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-orange-500" />
              중복 콘텐츠 발견
            </AlertDialogTitle>
            <AlertDialogDescription>
              Day {validationResult?.data?.day} 학습 콘텐츠가 이미 존재합니다. 덮어쓰시겠습니까?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setShowOverwriteConfirm(false)}>
              취소
            </AlertDialogCancel>
            <AlertDialogAction onClick={handleOverwrite}>
              덮어쓰기
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
