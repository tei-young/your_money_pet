import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// 사용자 상태 관리 Provider
class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

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

  /// 사용자 데이터 로드
  Future<void> loadUser() async {
    // TODO: SharedPreferences 또는 Firebase에서 로드
    // 임시로 null 유지 (첫 실행 시 온보딩으로 유도)
    _user = null;
    notifyListeners();
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
    // TODO: SharedPreferences 클리어
    notifyListeners();
  }

  /// 저장 (로컬 스토리지)
  Future<void> _saveToStorage() async {
    if (_user == null) return;

    // TODO: SharedPreferences에 저장
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user', jsonEncode(_user!.toJson()));

    debugPrint('User saved: ${_user!.name}');
  }

  /// 두 날짜 사이의 일수 계산
  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }
}
