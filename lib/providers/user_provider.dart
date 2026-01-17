import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

/// 사용자 상태 관리 Provider
class UserProvider with ChangeNotifier {
  UserModel? _user;
  final UserService _userService = UserService();

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  /// Firebase 로그인 여부 (firebaseUid가 있으면 Firebase 로그인)
  bool get isFirebaseUser => _user?.firebaseUid != null;

  /// SharedPreferences 키
  static const String _userKey = 'user_data';

  /// 온보딩 완료 시 사용자 생성
  Future<void> createUser({
    required String name,
    required PersonalityType personalityType,
    required String goal,
  }) async {
    _user = UserModel.create(
      name: name,
      personalityType: personalityType,
      goal: goal,
    );

    // TODO: Firebase에 저장
    await _saveToStorage();

    notifyListeners();
  }

  /// Firebase 로그인 시 사용자 데이터 동기화
  ///
  /// [firebaseUid]: Firebase Authentication UID
  /// 1. Firestore에 프로필이 있으면 로드
  /// 2. 없으면 로컬 데이터를 Firestore로 이동
  /// 3. 로컬 데이터도 없으면 null 반환 (온보딩 필요)
  Future<void> loginWithFirebase(String firebaseUid) async {
    try {
      // 1. Firestore에서 프로필 로드 시도
      final firestoreUser = await _userService.loadUserProfile(firebaseUid);

      if (firestoreUser != null) {
        // Firestore에 프로필이 있음 → 로드
        _user = firestoreUser;
        await _saveToStorage(); // SharedPreferences에도 캐시
        debugPrint('User synced from Firestore: ${_user!.name}');
      } else {
        // Firestore에 프로필 없음 → 로컬 데이터 확인
        await loadUser();

        if (_user != null) {
          // 로컬 데이터가 있음 → Firestore로 이동
          _user = _user!.copyWith(firebaseUid: firebaseUid);
          await _userService.createUserProfile(
            firebaseUid: firebaseUid,
            user: _user!,
          );
          await _saveToStorage();
          debugPrint('Local user moved to Firestore: ${_user!.name}');
        } else {
          // 로컬 데이터도 없음 → 온보딩 필요
          debugPrint('No user data found. Onboarding required.');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing user with Firebase: $e');
      rethrow;
    }
  }

  /// 사용자 데이터 로드 (SharedPreferences)
  Future<void> loadUser() async {
    // 이미 메모리에 사용자가 있으면 그대로 유지
    if (_user != null) {
      debugPrint('User already loaded: ${_user!.name}');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        _user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        debugPrint('User loaded from SharedPreferences: ${_user!.name}');
        notifyListeners();
      } else {
        debugPrint('No user data found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  /// 이름 변경
  Future<void> updateName(String newName) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: newName);
    await _saveToStorage();
    notifyListeners();
  }

  /// 성향 변경
  Future<void> updatePersonality(PersonalityType newType) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      personalityType: newType,
      currentDay: 1, // Day 1부터 재시작
    );
    await _saveToStorage();
    notifyListeners();
  }

  /// 목표 변경
  Future<void> updateGoal(String newGoal) async {
    if (_user == null) return;
    _user = _user!.copyWith(goal: newGoal);
    await _saveToStorage();
    notifyListeners();
  }

  /// Day 완료 시 호출
  Future<void> completeLearningDay({
    required int earnedPoints,
  }) async {
    if (_user == null) return;

    final now = DateTime.now();
    final lastLearning = _user!.lastLearningDate;
    int newStreak = _user!.currentStreak;

    // 연속 학습 계산
    if (lastLearning != null) {
      final daysDifference = _daysBetween(lastLearning, now);

      if (daysDifference == 1) {
        // 연속 학습
        newStreak += 1;
      } else if (daysDifference > 1) {
        // 연속 끊김
        newStreak = 1;
      }
      // daysDifference == 0 (오늘 이미 학습): 변경 없음
    } else {
      // 첫 학습
      newStreak = 1;
    }

    _user = _user!.copyWith(
      currentDay: _user!.currentDay + 1,
      totalPoints: _user!.totalPoints + earnedPoints,
      currentStreak: newStreak,
      maxStreak: newStreak > _user!.maxStreak ? newStreak : _user!.maxStreak,
      lastLearningDate: now,
    );

    await _saveToStorage();
    notifyListeners();
  }

  /// 포인트 추가 (보너스 등)
  Future<void> addPoints(int points) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      totalPoints: _user!.totalPoints + points,
    );
    await _saveToStorage();
    notifyListeners();
  }

  /// 로그아웃 (데이터 초기화)
  Future<void> logout() async {
    _user = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      debugPrint('User data cleared from storage');
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }

    notifyListeners();
  }

  /// 저장 (SharedPreferences + Firestore)
  ///
  /// Firebase 사용자인 경우 Firestore에도 저장
  Future<void> _saveToStorage() async {
    if (_user == null) return;

    try {
      // 1. SharedPreferences에 저장 (로컬 캐시)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
      debugPrint('User saved to SharedPreferences: ${_user!.name}');

      // 2. Firebase 사용자면 Firestore에도 저장
      if (_user!.firebaseUid != null) {
        await _userService.updateUserProfile(
          firebaseUid: _user!.firebaseUid!,
          user: _user!,
        );
        debugPrint('User saved to Firestore: ${_user!.name}');
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  /// 두 날짜 사이의 일수 계산
  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }
}
