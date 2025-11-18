# 머니펫 개발 가이드 📱

> Flutter 환경 세팅부터 앱 스토어 출시까지 완벽 가이드

---

## 📋 목차

1. [환경 세팅](#1-환경-세팅)
2. [테스트 방법](#2-테스트-방법)
3. [빌드 방법](#3-빌드-방법)
4. [배포 프로세스](#4-배포-프로세스)
5. [출시 체크리스트](#5-출시-체크리스트)
6. [비용 정리](#6-비용-정리)

---

## 1. 환경 세팅

### ✅ 필수 소프트웨어 설치

| 도구 | 용도 | 다운로드 | 필수 여부 |
|------|------|----------|-----------|
| **Flutter SDK** | 앱 개발 | [다운로드](https://docs.flutter.dev/get-started/install) | ✅ 필수 |
| **VS Code** | 코드 에디터 | [다운로드](https://code.visualstudio.com) | ✅ 추천 |
| **Android Studio** | Android 개발 | [다운로드](https://developer.android.com/studio) | ✅ 필수 |
| **Xcode** | iOS 개발 | Mac App Store | ⚠️ Mac + iOS 개발 시 |
| **Git** | 버전 관리 | [다운로드](https://git-scm.com) | ✅ 필수 |

---

### 🔧 설치 순서

#### Step 1: Flutter SDK

**macOS**:
```bash
brew install flutter
flutter --version
```

**Windows**:
1. https://docs.flutter.dev/get-started/install/windows 에서 zip 다운로드
2. `C:\src\flutter` 에 압축 해제
3. PATH 환경변수 추가: `C:\src\flutter\bin`

**설치 확인**:
```bash
flutter doctor
```

---

#### Step 2: Android Studio

```bash
# 1. Android Studio 설치
https://developer.android.com/studio

# 2. SDK Manager 실행
# More Actions → SDK Manager

# 3. 설치 항목:
✅ Android 13.0 (API 33)
✅ Android 12.0 (API 31)
✅ Android SDK Command-line Tools
✅ Android Emulator
✅ Android SDK Platform-Tools

# 4. 라이선스 동의
flutter doctor --android-licenses
# → 모든 질문에 'y' 입력
```

---

#### Step 3: Xcode (Mac 사용자만)

```bash
# 1. Mac App Store에서 Xcode 설치 (무료, 약 10GB)

# 2. Command Line Tools 설치
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# 3. CocoaPods 설치
sudo gem install cocoapods
```

---

#### Step 4: VS Code 확장

VS Code 실행 → Extensions (Ctrl+Shift+X):
- **Flutter**
- **Dart**
- **Awesome Flutter Snippets** (선택)

---

#### Step 5: 최종 확인

```bash
flutter doctor -v
```

**목표 출력**:
```
[✓] Flutter
[✓] Android toolchain
[✓] Xcode (Mac인 경우)
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

---

## 2. 테스트 방법

### 📱 실기기 테스트 (추천) ⭐

#### Android 폰 설정

```
1. 설정 → 휴대전화 정보 → 빌드 번호 7번 탭
2. 개발자 옵션 → USB 디버깅 ON
3. USB 연결 → 파일 전송 모드
```

**실행**:
```bash
# 연결 확인
flutter devices

# 앱 실행
flutter run

# 특정 기기 지정
flutter run -d <device-id>
```

---

#### iPhone 설정 (Mac 필요)

```
1. 설정 → 개인정보 보호 및 보안 → 개발자 모드 ON
2. iPhone 연결
3. 신뢰 여부 확인
```

**실행**:
```bash
flutter run
```

---

### 💻 에뮬레이터/시뮬레이터

#### Android Emulator

```bash
# 1. Android Studio → Tools → Device Manager
# 2. Create Device → Pixel 6 → API 33
# 3. Finish

# 에뮬레이터 목록
flutter emulators

# 실행
flutter emulators --launch <emulator-id>
```

#### iOS Simulator (Mac)

```bash
# Simulator 실행
open -a Simulator

# 앱 실행
flutter run
```

---

### 🔥 Hot Reload (개발 중)

코드 수정 후 즉시 확인:

```
r 키: Hot Reload (상태 유지)
R 키: Hot Restart (앱 재시작)
q 키: 종료
```

**매일 개발 루틴**:
1. 코드 작성
2. 저장 (Ctrl+S)
3. 실기기에서 `r` 키
4. 즉시 반영 확인!

---

## 3. 빌드 방법

### 🔨 Debug 빌드 (개발용)

```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug
```

---

### 🚀 Release 빌드 (배포용)

#### Android

```bash
# App Bundle (Play Store 업로드용) - 추천
flutter build appbundle --release

# APK (직접 배포용)
flutter build apk --release
```

**빌드 위치**:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

---

#### iOS (Mac 필요)

```bash
flutter build ipa --release
```

**Xcode에서 업로드**:
1. Xcode → Window → Organizer
2. Archives 탭
3. Distribute App → TestFlight
4. Upload

---

## 4. 배포 프로세스

### 📦 내부 테스트 (Week 9-10)

#### Android - APK 직접 배포

```bash
# 1. 빌드
flutter build apk --release

# 2. APK 위치
build/app/outputs/flutter-apk/app-release.apk

# 3. 배포
- Google Drive/Dropbox에 업로드
- 다운로드 링크 공유
- 팀원: APK 다운로드 → 설치 (알 수 없는 출처 허용)
```

---

#### iOS - TestFlight

```bash
# 1. 빌드
flutter build ipa

# 2. Xcode Organizer 업로드
# 3. App Store Connect → TestFlight
# 4. 내부 테스터 이메일로 초대 (최대 100명)
```

---

### 🧪 베타 테스트 (Week 11)

#### Google Play 내부 테스트

**초기 설정** (1회만):
```
1. https://play.google.com/console 계정 생성 ($25)
2. 앱 만들기
   - 이름: 머니펫
   - 언어: 한국어
3. 스토어 등록정보 작성 (간단히)
```

**빌드 업로드**:
```bash
# 1. App Bundle 빌드
flutter build appbundle --release

# 2. Play Console → 내부 테스트 → 새 버전
# 3. AAB 업로드
build/app/outputs/bundle/release/app-release.aab

# 4. 테스터 이메일 추가 (최대 100명)
# 5. 검토 → 출시 (즉시 배포)
```

**테스터 초대**:
```
Play Console → 내부 테스트 → 테스터
→ 공유 링크 복사
→ 테스터에게 전달
```

---

### 🌍 정식 출시 (Week 12)

#### Google Play Store

```
1. Play Console → 프로덕션 → 새 버전 만들기

2. AAB 업로드 (동일)

3. 스토어 등록정보 작성:
   - 간단한 설명 (80자)
   - 전체 설명 (4,000자)
   - 스크린샷 (1080×1920, 최소 2장)
   - 아이콘 (512×512)

4. 콘텐츠 등급 설정 (설문지 작성)

5. 가격 및 배포: 무료

6. 개인정보처리방침 URL 입력

7. 검토를 위해 제출

심사 기간: 평균 1-3일
```

---

#### App Store

```
1. App Store Connect → 앱 → 새 버전

2. TestFlight 빌드 선택

3. 앱 정보:
   - 이름: 머니펫
   - 부제 (30자)
   - 설명 (4,000자)
   - 스크린샷 (1290×2796, 최소 3장)
   - 미리보기 비디오 (선택)

4. 연령 등급 설정

5. 가격: 무료

6. 개인정보처리방침 URL

7. 심사를 위해 제출

심사 기간: 평균 1-7일
```

---

## 5. 출시 체크리스트

### ✅ 사전 준비

#### 계정 & 결제

- [ ] Apple Developer Program 가입 ($99/년)
- [ ] Google Play Console 계정 ($25)
- [ ] Firebase 프로젝트 생성 (무료)

---

#### 필수 에셋

**앱 아이콘**:
- [ ] 1024×1024 PNG (투명 배경 없음)

**스크린샷** (각 플랫폼별):
- [ ] Android: 1080×1920 (최소 2장)
- [ ] iOS: 1290×2796 (최소 3장)

**텍스트**:
- [ ] 앱 설명 (한국어, 4,000자)
- [ ] 간단한 설명 (80자)
- [ ] 개인정보처리방침 (URL 또는 텍스트)
- [ ] 서비스 이용약관 (선택)

---

### 📅 타임라인별 체크리스트

#### Week 0: 환경 세팅
- [ ] Flutter SDK 설치
- [ ] Android Studio 설치
- [ ] Xcode 설치 (Mac, iOS 개발 시)
- [ ] VS Code + 확장 설치
- [ ] flutter doctor 모두 ✓

---

#### Week 1-8: 개발 & 테스트
- [ ] 실기기 연결 (Android + iPhone)
- [ ] `flutter run` 매일 테스트
- [ ] Hot Reload로 즉시 확인
- [ ] Git에 코드 푸시

---

#### Week 9: 내부 테스트 준비
- [ ] Release 빌드 성공
- [ ] APK 직접 배포 (팀원 5-10명)
- [ ] TestFlight 업로드 (iOS)
- [ ] 버그 수정

---

#### Week 10: 베타 테스트 준비
- [ ] Play Console 계정 생성 ($25)
- [ ] Apple Developer 가입 ($99)
- [ ] 내부 테스트 트랙 생성
- [ ] 베타 테스터 50-100명 모집

---

#### Week 11: 베타 테스트
- [ ] Play 내부 테스트 배포
- [ ] TestFlight 외부 테스터 초대
- [ ] 피드백 수집
- [ ] 버그 수정

---

#### Week 12: 정식 출시
- [ ] 앱 아이콘 준비 (1024×1024)
- [ ] 스크린샷 준비 (각 플랫폼)
- [ ] 앱 설명 작성
- [ ] 개인정보처리방침 URL
- [ ] Play Store 제출
- [ ] App Store 제출
- [ ] 심사 대기 (1-7일)
- [ ] 🎉 출시!

---

## 6. 비용 정리

### 💰 초기 비용 (1년)

| 항목 | 비용 | 시점 |
|------|------|------|
| Flutter SDK | **무료** | 즉시 |
| Firebase (Spark) | **무료** | 즉시 |
| Google Play Console | $25 (평생) | Week 10 |
| Apple Developer | $99/년 | Week 10 |
| **총합** | **$124** | - |

---

### 📊 운영 비용 (월)

| 항목 | MVP (MAU 1,000) | 성장기 (MAU 10,000) |
|------|------------------|---------------------|
| Firebase | 무료 | ~$25-50 |
| Apple Developer | $8.25 | $8.25 |
| **총합** | **~$8/월** | **~$40/월** |

---

## 🚀 빠른 참고

### 자주 쓰는 명령어

```bash
# 환경 확인
flutter doctor

# 연결된 기기 확인
flutter devices

# 앱 실행 (Hot Reload)
flutter run

# Release 빌드
flutter build appbundle --release  # Android
flutter build ipa --release        # iOS

# 패키지 설치
flutter pub get

# 프로젝트 정리
flutter clean
```

---

### 문제 해결

#### "flutter: command not found"
```bash
# PATH 확인
echo $PATH

# PATH 추가 (macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"
```

#### "Gradle build failed"
```bash
# Android 디렉토리에서
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### "CocoaPods not installed"
```bash
sudo gem install cocoapods
pod setup
```

---

## 📞 지원

### 공식 문서
- Flutter: https://docs.flutter.dev
- Firebase: https://firebase.google.com/docs
- Play Console: https://support.google.com/googleplay/android-developer
- App Store Connect: https://developer.apple.com/app-store-connect

### 커뮤니티
- Flutter Korea: https://flutter-ko.dev
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**마지막 업데이트**: 2025년 11월
**문서 버전**: v1.0
