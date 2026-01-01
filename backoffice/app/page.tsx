"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        // 로그인된 경우 - Admin claim 확인
        const idTokenResult = await user.getIdTokenResult();
        if (idTokenResult.claims.admin) {
          router.push("/dashboard");
        } else {
          router.push("/login");
        }
      } else {
        // 로그인 안 된 경우
        router.push("/login");
      }
    });

    return () => unsubscribe();
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 to-purple-100">
      <div className="text-center">
        <p className="text-gray-600">로딩 중...</p>
      </div>
    </div>
  );
}
