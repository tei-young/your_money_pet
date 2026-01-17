import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Firestore 사용자 데이터 관리 서비스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore 컬렉션 이름
  static const String _usersCollection = 'users';

  /// 사용자 프로필 생성 (회원가입 시)
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// [user]: 저장할 사용자 데이터
  Future<void> createUserProfile({
    required String firebaseUid,
    required UserModel user,
  }) async {
    try {
      // firebaseUid를 추가한 UserModel 생성
      final userWithUid = user.copyWith(firebaseUid: firebaseUid);

      await _firestore
          .collection(_usersCollection)
          .doc(firebaseUid)
          .set(userWithUid.toJson());

      debugPrint('User profile created in Firestore: $firebaseUid');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 로드
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// Returns: UserModel 또는 null (프로필이 없을 경우)
  Future<UserModel?> loadUserProfile(String firebaseUid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUid)
          .get();

      if (doc.exists && doc.data() != null) {
        debugPrint('User profile loaded from Firestore: $firebaseUid');
        return UserModel.fromJson(doc.data()!);
      } else {
        debugPrint('No user profile found in Firestore: $firebaseUid');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// [user]: 업데이트할 사용자 데이터
  Future<void> updateUserProfile({
    required String firebaseUid,
    required UserModel user,
  }) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(firebaseUid)
          .update(user.toJson());

      debugPrint('User profile updated in Firestore: $firebaseUid');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 삭제
  ///
  /// [firebaseUid]: Firebase Authentication UID
  Future<void> deleteUserProfile(String firebaseUid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(firebaseUid)
          .delete();

      debugPrint('User profile deleted from Firestore: $firebaseUid');
    } catch (e) {
      debugPrint('Error deleting user profile: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 실시간 스트림
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// Returns: UserModel 스트림 (프로필 변경 시 자동 업데이트)
  Stream<UserModel?> watchUserProfile(String firebaseUid) {
    return _firestore
        .collection(_usersCollection)
        .doc(firebaseUid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Firestore에 사용자가 존재하는지 확인
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// Returns: true (존재함) / false (없음)
  Future<bool> userExists(String firebaseUid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUid)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }
}
