"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ArrowLeft } from "lucide-react";
import LearningContentList from "@/components/learning/LearningContentList";
import QuizContentList from "@/components/quiz/QuizContentList";

// 성향 정보 타입
type PersonalityType = "safe" | "balanced" | "aggressive" | "challenger";

interface PersonalityInfo {
  id: PersonalityType;
  name: string;
  nameKo: string;
  emoji: string;
  color: string;
}

// 성향별 정보
const personalities: Record<PersonalityType, PersonalityInfo> = {
  safe: {
    id: "safe",
    name: "머니베어",
    nameKo: "안전형",
    emoji: "🐻",
    color: "text-safe",
  },
  balanced: {
    id: "balanced",
    name: "세이브쉽",
    nameKo: "균형형",
    emoji: "🐑",
    color: "text-balanced",
  },
  aggressive: {
    id: "aggressive",
    name: "헌터캣",
    nameKo: "공격형",
    emoji: "🐱",
    color: "text-aggressive",
  },
  challenger: {
    id: "challenger",
    name: "체이서폭스",
    nameKo: "도전형",
    emoji: "🦊",
    color: "text-challenger",
  },
};

export default function PersonalityPage() {
  const router = useRouter();
  const params = useParams();
  const personality = params.personality as PersonalityType;

  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // 유효한 성향인지 확인
  const personalityInfo = personalities[personality];

  useEffect(() => {
    // 유효하지 않은 성향이면 대시보드로 리다이렉트
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
      <div className="max-w-7xl mx-auto">
        {/* 헤더 */}
        <div className="flex justify-between items-center mb-8">
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              size="icon"
              onClick={() => router.push("/dashboard")}
            >
              <ArrowLeft className="h-4 w-4" />
            </Button>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                <span className="mr-2">{personalityInfo.emoji}</span>
                <span className={personalityInfo.color}>
                  {personalityInfo.name}
                </span>
                <span className="text-gray-600 ml-2 text-2xl">
                  ({personalityInfo.nameKo})
                </span>
              </h1>
              <p className="text-gray-600 mt-1">
                {personalityInfo.name} 콘텐츠 관리
              </p>
            </div>
          </div>
          <Button onClick={handleLogout} variant="outline">
            로그아웃
          </Button>
        </div>

        {/* 탭 */}
        <Tabs defaultValue="learning" className="space-y-4">
          <TabsList>
            <TabsTrigger value="learning">학습 콘텐츠</TabsTrigger>
            <TabsTrigger value="quiz">퀴즈</TabsTrigger>
          </TabsList>

          <TabsContent value="learning" className="space-y-4">
            <LearningContentList personality={personality} />
          </TabsContent>

          <TabsContent value="quiz" className="space-y-4">
            <QuizContentList personality={personality} />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
