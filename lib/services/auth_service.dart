import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Firebase 인증 서비스
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 현재 사용자
  User? get currentUser => _auth.currentUser;

  /// 현재 사용자 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 이메일/비밀번호 회원가입
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('회원가입 에러: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('회원가입 에러: $e');
      rethrow;
    }
  }

  /// 이메일/비밀번호 로그인
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('로그인 에러: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('로그인 에러: $e');
      rethrow;
    }
  }

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 사용자가 취소한 경우
      if (googleUser == null) {
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 자격증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('Google 로그인 에러: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Google 로그인 에러: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('로그아웃 에러: $e');
      rethrow;
    }
  }

  /// Firebase Auth 에러 메시지 변환
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약해요. 6자 이상 입력해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일이에요.';
      case 'invalid-email':
        return '올바른 이메일 형식이 아니에요.';
      case 'user-not-found':
        return '등록되지 않은 이메일이에요.';
      case 'wrong-password':
        return '비밀번호가 틀렸어요.';
      case 'user-disabled':
        return '비활성화된 계정이에요.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었어요. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 로그인 방법은 현재 사용할 수 없어요.';
      case 'account-exists-with-different-credential':
        return '다른 로그인 방법으로 가입된 이메일이에요.';
      case 'invalid-credential':
        return '로그인 정보가 올바르지 않아요.';
      case 'invalid-verification-code':
        return '인증 코드가 올바르지 않아요.';
      case 'invalid-verification-id':
        return '인증 ID가 올바르지 않아요.';
      default:
        return '로그인 중 오류가 발생했어요. 다시 시도해주세요.';
    }
  }
}
