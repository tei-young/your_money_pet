import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MoneyPet 백오피스",
  description: "MoneyPet 콘텐츠 관리 시스템",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <head>
        <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css"
        />
      </head>
      <body className="antialiased">{children}</body>
    </html>
  );
}
