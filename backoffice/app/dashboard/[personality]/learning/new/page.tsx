"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import LearningContentForm from "@/components/learning/LearningContentForm";

type PersonalityType = "safe" | "balanced" | "aggressive" | "challenger";

const personalities: Record<PersonalityType, { name: string; emoji: string }> = {
  safe: { name: "머니베어 (안전형)", emoji: "🐻" },
  balanced: { name: "세이브쉽 (균형형)", emoji: "🐑" },
  aggressive: { name: "헌터캣 (공격형)", emoji: "🐱" },
  challenger: { name: "체이서폭스 (도전형)", emoji: "🦊" },
};

export default function NewLearningContentPage() {
  const router = useRouter();
  const params = useParams();
  const personality = params.personality as PersonalityType;

  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const personalityInfo = personalities[personality];

  useEffect(() => {
    if (!personalityInfo) {
      router.push("/dashboard");
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (!currentUser) {
        router.push("/login");
        return;
      }

      const idTokenResult = await currentUser.getIdTokenResult();
      if (!idTokenResult.claims.admin) {
        await signOut(auth);
        router.push("/login");
        return;
      }

      setUser(currentUser);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [router, personalityInfo]);

  const handleLogout = async () => {
    await signOut(auth);
    router.push("/login");
  };

  if (loading || !personalityInfo) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>로딩 중...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        {/* 헤더 */}
        <div className="flex justify-between items-center mb-8">
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              size="icon"
              onClick={() => router.push(`/dashboard/${personality}`)}
            >
              <ArrowLeft className="h-4 w-4" />
            </Button>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                <span className="mr-2">{personalityInfo.emoji}</span>
                새 학습 콘텐츠 추가
              </h1>
              <p className="text-gray-600 mt-1">{personalityInfo.name}</p>
            </div>
          </div>
          <Button onClick={handleLogout} variant="outline">
            로그아웃
          </Button>
        </div>

        {/* 폼 */}
        <LearningContentForm personality={personality} />
      </div>
    </div>
  );
}
