# Release Checklist

앱 릴리즈 전 반드시 확인해야 할 체크리스트입니다.

---

## 1. API 키 보안 설정

### Android API 키
- [ ] Google Cloud Console에서 애플리케이션 제한 설정
- [ ] 제한 유형: **Android 앱**
- [ ] 패키지 이름: `com.moneypet.app`
- [ ] SHA-1 인증서 지문 추가 (Debug + Release)

**SHA-1 추출 방법:**
```bash
# Debug 키
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep SHA1

# Release 키
keytool -list -v -keystore [release-keystore-path] -alias [alias-name] | grep SHA1
```

### iOS API 키
- [ ] Google Cloud Console에서 애플리케이션 제한 설정
- [ ] 제한 유형: **iOS 앱**
- [ ] 번들 ID: `com.moneypet.app`

### Web API 키 (Backoffice)
- [ ] Google Cloud Console에서 애플리케이션 제한 설정
- [ ] 제한 유형: **HTTP 리퍼러**
- [ ] 허용 리퍼러에 배포 도메인 추가
- [ ] localhost 제거 (또는 유지 - 개발 필요시)

---

## 2. Firebase Security Rules

### Firestore Rules
- [ ] 인증된 사용자만 접근 가능하도록 설정
- [ ] 사용자별 데이터 격리 확인 (uid 기반)
- [ ] Admin 권한 분리 확인

### Storage Rules
- [ ] 업로드 파일 크기 제한
- [ ] 허용 파일 타입 제한
- [ ] 인증 필수 설정

---

## 3. 환경 설정

### 설정 파일 확인
- [ ] `google-services.json` - git에서 제외 확인
- [ ] `GoogleService-Info.plist` - git에서 제외 확인
- [ ] `.env` 파일들 - git에서 제외 확인

### 디버그 코드 제거
- [ ] `print()` / `debugPrint()` 정리
- [ ] 테스트용 하드코딩 값 제거
- [ ] API endpoint가 production 환경인지 확인

---

## 4. 빌드 설정

### Android
- [ ] `android/app/build.gradle`에서 `minSdkVersion` 확인
- [ ] Release signing 설정 완료
- [ ] ProGuard/R8 난독화 설정 (선택)

### iOS
- [ ] Bundle ID 확인
- [ ] Provisioning Profile 설정
- [ ] App Store Connect 앱 정보 입력

---

## 5. 스토어 제출 전

- [ ] 앱 아이콘 설정
- [ ] 스플래시 스크린 설정
- [ ] 버전 번호 업데이트 (`pubspec.yaml`)
- [ ] 개인정보처리방침 URL 준비
- [ ] 스크린샷 준비

---

## 6. 백오피스 배포

### 배포 플랫폼 설정
- [ ] 배포 플랫폼 선택 (Vercel / Firebase Hosting / Netlify 등)
- [ ] 배포 도메인 확정
- [ ] 환경 변수 설정 (Firebase API Key 등)

### API 키 리퍼러 업데이트
- [ ] Google Cloud Console → Web API 키 → HTTP 리퍼러 설정
- [ ] 배포 도메인 추가: `https://your-backoffice-domain.com/*`
- [ ] (선택) localhost 제거 또는 유지

### 배포 후 확인
- [ ] Firebase 인증 동작 확인
- [ ] Firestore 데이터 접근 확인
- [ ] Admin 기능 정상 동작 확인

---

## 참고: API 키가 노출되었을 때

1. Google Cloud Console에서 기존 키 **즉시 폐기/재생성**
2. Firebase Console에서 새 설정 파일 다운로드
3. git history에서 제거 필요시: `git filter-branch` 또는 `BFG Repo-Cleaner` 사용
4. 새 키에 적절한 제한 설정
