"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "@/lib/firebase";
import QuizContentForm from "@/components/quiz/QuizContentForm";

type PersonalityType = "safe" | "balanced" | "aggressive" | "challenger";

const personalities: Record<PersonalityType, { name: string; nameKo: string; emoji: string; color: string }> = {
  safe: { name: "머니베어", nameKo: "안전형", emoji: "🐻", color: "text-safe" },
  balanced: { name: "세이브쉽", nameKo: "균형형", emoji: "🐑", color: "text-balanced" },
  aggressive: { name: "헌터캣", nameKo: "공격형", emoji: "🐱", color: "text-aggressive" },
  challenger: { name: "체이서폭스", nameKo: "도전형", emoji: "🦊", color: "text-challenger" },
};

export default function EditQuizPage({ params }: { params: Promise<{ personality: string; id: string }> }) {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [personality, setPersonality] = useState<PersonalityType | null>(null);
  const [quizId, setQuizId] = useState<string | null>(null);
  const personalityInfo = personality ? personalities[personality] : null;

  useEffect(() => {
    params.then(p => {
      setPersonality(p.personality as PersonalityType);
      setQuizId(p.id);
    });
  }, [params]);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (!user) {
        router.push("/login");
        return;
      }

      // Admin 권한 확인
      const tokenResult = await user.getIdTokenResult();
      if (!tokenResult.claims.admin) {
        alert("관리자 권한이 필요합니다.");
        router.push("/");
        return;
      }

      setLoading(false);
    });

    return () => unsubscribe();
  }, [router]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-lg">로딩 중...</div>
      </div>
    );
  }

  if (!personalityInfo) {
    return <div>잘못된 성향입니다.</div>;
  }

  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">
          {personalityInfo.emoji} {personalityInfo.name} 퀴즈 수정
        </h1>
        <p className="text-gray-600">{personalityInfo.nameKo} 성향의 퀴즈를 수정합니다.</p>
      </div>

      {personality && quizId && <QuizContentForm personality={personality} quizId={quizId} />}
    </div>
  );
}
