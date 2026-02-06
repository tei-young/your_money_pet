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

interface QuizJsonImportProps {
  personality: string;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface ValidationResult {
  success: boolean;
  data?: QuizContentData;
  error?: string;
}

export default function QuizJsonImport({
  personality,
  isOpen,
  onClose,
  onSuccess,
}: QuizJsonImportProps) {
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
      const requiredFields = ["day", "personality", "totalPoints", "passingScore", "questions"];
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
      if (typeof data.totalPoints !== "number") {
        throw new Error(`'totalPoints'는 숫자여야 합니다. (현재: ${typeof data.totalPoints})`);
      }
      if (typeof data.passingScore !== "number") {
        throw new Error(`'passingScore'는 숫자여야 합니다. (현재: ${typeof data.passingScore})`);
      }
      if (!Array.isArray(data.questions)) {
        throw new Error("'questions'는 배열이어야 합니다.");
      }

      // 4. 값 범위 검증
      if (data.day <= 0) {
        throw new Error(`'day'는 양수여야 합니다. (현재: ${data.day})`);
      }
      if (!["safe", "balanced", "aggressive", "challenger"].includes(data.personality)) {
        throw new Error(`'personality'는 'safe', 'balanced', 'aggressive', 'challenger' 중 하나여야 합니다. (현재: ${data.personality})`);
      }
      if (data.totalPoints <= 0) {
        throw new Error(`'totalPoints'는 양수여야 합니다. (현재: ${data.totalPoints})`);
      }
      if (data.passingScore < 0 || data.passingScore > 100) {
        throw new Error(`'passingScore'는 0~100 사이여야 합니다. (현재: ${data.passingScore})`);
      }

      // 5. 배열 검증
      if (data.questions.length === 0) {
        throw new Error("questions 배열이 비어있습니다. 최소 1개 이상의 질문이 필요합니다.");
      }

      // 6. 질문 필드 검증
      const orders = new Set<number>();
      let sumPoints = 0;

      for (let i = 0; i < data.questions.length; i++) {
        const question = data.questions[i];

        // 필수 필드
        if (!("order" in question)) {
          throw new Error(`questions[${i}]에 'order' 필드가 없습니다.`);
        }
        if (!("question" in question)) {
          throw new Error(`questions[${i}]에 'question' 필드가 없습니다.`);
        }
        if (!("points" in question)) {
          throw new Error(`questions[${i}]에 'points' 필드가 없습니다.`);
        }
        if (!("options" in question)) {
          throw new Error(`questions[${i}]에 'options' 필드가 없습니다.`);
        }

        // 타입 검증
        if (typeof question.order !== "number") {
          throw new Error(`questions[${i}].order는 숫자여야 합니다. (현재: ${typeof question.order})`);
        }
        if (typeof question.question !== "string") {
          throw new Error(`questions[${i}].question은 문자열이어야 합니다. (현재: ${typeof question.question})`);
        }
        if (typeof question.points !== "number") {
          throw new Error(`questions[${i}].points는 숫자여야 합니다. (현재: ${typeof question.points})`);
        }
        if (!Array.isArray(question.options)) {
          throw new Error(`questions[${i}].options는 배열이어야 합니다.`);
        }

        // 값 검증
        if (question.order <= 0) {
          throw new Error(`questions[${i}].order는 양수여야 합니다. (현재: ${question.order})`);
        }
        if (question.question.trim() === "") {
          throw new Error(`questions[${i}].question은 비어있지 않아야 합니다.`);
        }
        if (question.points <= 0) {
          throw new Error(`questions[${i}].points는 양수여야 합니다. (현재: ${question.points})`);
        }

        // 선택지 검증
        if (question.options.length < 2) {
          throw new Error(`questions[${i}].options는 최소 2개 이상이어야 합니다.`);
        }

        let hasCorrectAnswer = false;
        for (let j = 0; j < question.options.length; j++) {
          const option = question.options[j];

          // 필수 필드
          if (!("text" in option)) {
            throw new Error(`questions[${i}].options[${j}]에 'text' 필드가 없습니다.`);
          }
          if (!("isCorrect" in option)) {
            throw new Error(`questions[${i}].options[${j}]에 'isCorrect' 필드가 없습니다.`);
          }
          if (!("explanation" in option)) {
            throw new Error(`questions[${i}].options[${j}]에 'explanation' 필드가 없습니다.`);
          }

          // 타입 검증
          if (typeof option.text !== "string") {
            throw new Error(`questions[${i}].options[${j}].text는 문자열이어야 합니다. (현재: ${typeof option.text})`);
          }
          if (typeof option.isCorrect !== "boolean") {
            throw new Error(`questions[${i}].options[${j}].isCorrect는 boolean이어야 합니다. (현재: ${typeof option.isCorrect})`);
          }
          if (typeof option.explanation !== "string") {
            throw new Error(`questions[${i}].options[${j}].explanation은 문자열이어야 합니다. (현재: ${typeof option.explanation})`);
          }

          // 값 검증
          if (option.text.trim() === "") {
            throw new Error(`questions[${i}].options[${j}].text는 비어있지 않아야 합니다.`);
          }
          if (option.explanation.trim() === "") {
            throw new Error(`questions[${i}].options[${j}].explanation은 비어있지 않아야 합니다.`);
          }

          if (option.isCorrect) {
            hasCorrectAnswer = true;
          }
        }

        // 정답 존재 여부
        if (!hasCorrectAnswer) {
          throw new Error(`questions[${i}]에 정답(isCorrect: true)이 없습니다.`);
        }

        // order 중복 체크
        if (orders.has(question.order)) {
          throw new Error(`questions[${i}].order가 중복되었습니다. (order: ${question.order})`);
        }
        orders.add(question.order);

        // 점수 합산
        sumPoints += question.points;
      }

      // 7. order 연속성 검증
      const sortedOrders = Array.from(orders).sort((a, b) => a - b);
      for (let i = 0; i < sortedOrders.length; i++) {
        if (sortedOrders[i] !== i + 1) {
          throw new Error(`questions의 order가 연속적이지 않습니다. (기대: ${i + 1}, 실제: ${sortedOrders[i]})`);
        }
      }

      // 8. totalPoints 합계 검증
      if (sumPoints !== data.totalPoints) {
        throw new Error(`totalPoints가 일치하지 않습니다. (기대: ${sumPoints}, 현재: ${data.totalPoints})`);
      }

      // personality 덮어쓰기 (현재 선택된 성향으로)
      data.personality = personality;

      setValidationResult({
        success: true,
        data: data as QuizContentData,
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
      collection(db, "quiz_contents"),
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
        await updateDoc(doc(db, "quiz_contents", docId), saveData);
        alert("퀴즈가 성공적으로 업데이트되었습니다!");
      } else {
        // 새로 생성
        await addDoc(collection(db, "quiz_contents"), {
          ...saveData,
          createdAt: serverTimestamp(),
        });
        alert("퀴즈가 성공적으로 저장되었습니다!");
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
            <DialogTitle>JSON Import - 퀴즈</DialogTitle>
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
                  placeholder='{"day": 1, "personality": "safe", "totalPoints": 100, ...}'
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
                      <p>Day {validationResult.data.day} 퀴즈</p>
                      <p>{validationResult.data.questions.length}개 문제, 총 {validationResult.data.totalPoints}점 (합격: {validationResult.data.passingScore}점)</p>
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
              중복 퀴즈 발견
            </AlertDialogTitle>
            <AlertDialogDescription>
              Day {validationResult?.data?.day} 퀴즈가 이미 존재합니다. 덮어쓰시겠습니까?
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
