# Pretendard 폰트 설치 안내

## 다운로드

1. [Pretendard GitHub Releases](https://github.com/orioncactus/pretendard/releases/latest) 페이지 방문
2. `Pretendard-X.X.X.zip` 다운로드
3. 압축 해제 후 `/public/static/woff2/` 또는 `/public/static/otf/` 폴더에서 아래 파일들을 이 디렉토리에 복사:

## 필요한 파일

```
assets/fonts/
├── Pretendard-Regular.otf
├── Pretendard-Medium.otf
├── Pretendard-SemiBold.otf
└── Pretendard-Bold.otf
```

또는 TTF 형식:
```
assets/fonts/
├── Pretendard-Regular.ttf
├── Pretendard-Medium.ttf
├── Pretendard-SemiBold.ttf
└── Pretendard-Bold.ttf
```

## 빠른 다운로드 (직접 링크)

OTF 버전 사용을 권장합니다:
- [다운로드 페이지](https://github.com/orioncactus/pretendard/releases/latest)

## 설치 후

폰트 파일을 이 디렉토리에 추가한 후:
```bash
flutter clean
flutter pub get
flutter run
```
