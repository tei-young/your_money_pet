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

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardHeader>
              <CardTitle>학습 콘텐츠</CardTitle>
              <CardDescription>Day별/성향별 학습 자료 관리</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="w-full" disabled>
                관리하기 (준비 중)
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>퀴즈 관리</CardTitle>
              <CardDescription>퀴즈 문제 및 정답 관리</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="w-full" disabled>
                관리하기 (준비 중)
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>사용자 통계</CardTitle>
              <CardDescription>앱 사용자 데이터 및 분석</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="w-full" disabled>
                보기 (준비 중)
              </Button>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>🎉 로그인 성공!</CardTitle>
            <CardDescription>관리자 권한으로 로그인되었습니다</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2 text-sm">
              <p>✅ Firebase Auth 로그인 완료</p>
              <p>✅ Admin custom claim 확인 완료</p>
              <p>✅ Firestore 연결 준비 완료</p>
              <p className="mt-4 text-muted-foreground">
                다음 단계: 학습 콘텐츠 및 퀴즈 관리 페이지 구현
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
