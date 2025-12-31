"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function DashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (!currentUser) {
        // 로그인하지 않은 경우
        router.push("/login");
        return;
      }

      // Admin claim 확인
      const idTokenResult = await currentUser.getIdTokenResult();
      if (!idTokenResult.claims.admin) {
        // Admin이 아닌 경우
        await signOut(auth);
        router.push("/login");
        return;
      }

      setUser(currentUser);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [router]);

  const handleLogout = async () => {
    await signOut(auth);
    router.push("/login");
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>로딩 중...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">MoneyPet 백오피스</h1>
            <p className="text-gray-600 mt-1">환영합니다, {user?.email}</p>
          </div>
          <Button onClick={handleLogout} variant="outline">
            로그아웃
          </Button>
        </div>

        <div className="mb-8">
          <h2 className="text-2xl font-semibold text-gray-800 mb-4">성향별 콘텐츠 관리</h2>
          <p className="text-gray-600 mb-6">관리할 캐릭터 성향을 선택하세요</p>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <Card
              className="cursor-pointer hover:shadow-lg transition-shadow border-2 hover:border-safe"
              onClick={() => router.push("/dashboard/safe")}
            >
              <CardHeader>
                <div className="text-4xl mb-2">🐻</div>
                <CardTitle className="text-safe">머니베어</CardTitle>
                <CardDescription>(안전형)</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">
                  안정적이고 신중한 투자 성향
                </p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-lg transition-shadow border-2 hover:border-balanced"
              onClick={() => router.push("/dashboard/balanced")}
            >
              <CardHeader>
                <div className="text-4xl mb-2">🐑</div>
                <CardTitle className="text-balanced">세이브쉽</CardTitle>
                <CardDescription>(균형형)</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">
                  안정과 수익의 균형을 추구
                </p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-lg transition-shadow border-2 hover:border-aggressive"
              onClick={() => router.push("/dashboard/aggressive")}
            >
              <CardHeader>
                <div className="text-4xl mb-2">🐱</div>
                <CardTitle className="text-aggressive">헌터캣</CardTitle>
                <CardDescription>(공격형)</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">
                  적극적이고 공격적인 투자 성향
                </p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-lg transition-shadow border-2 hover:border-challenger"
              onClick={() => router.push("/dashboard/challenger")}
            >
              <CardHeader>
                <div className="text-4xl mb-2">🦊</div>
                <CardTitle className="text-challenger">체이서폭스</CardTitle>
                <CardDescription>(도전형)</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">
                  고위험 고수익을 추구하는 도전적 성향
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
