import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import 'constants.dart';

/// SNS 공유 헬퍼 클래스
class ShareHelper {
  /// 학습 성과 공유
  static Future<void> shareProgress({
    required UserModel user,
  }) async {
    final text = '''
🎓 ${user.name}님의 투자 학습 현황

📚 학습 Day: ${user.currentDay - 1}일
⭐ 누적 포인트: ${user.totalPoints}P
🔥 현재 연속: ${user.currentStreak}일
🏆 최대 연속: ${user.maxStreak}일

${user.personalityType.characterName}와 함께 매일 5분 투자 공부!
#머니펫 #투자공부 #금융교육
    ''';

    await Share.share(
      text,
      subject: '${user.name}님의 투자 학습 현황',
    );
  }

  /// 퀴즈 결과 공유
  static Future<void> shareQuizResult({
    required UserModel user,
    required int dayNumber,
    required int score,
    required int totalQuestions,
  }) async {
    final percentage = (score / totalQuestions * 100).toStringAsFixed(0);
    final grade = _getGrade(score / totalQuestions);

    final text = '''
🎯 Day $dayNumber 퀴즈 완료!

성적: $grade ($score/$totalQuestions 정답)
정답률: $percentage%

${user.personalityType.characterName}와 함께 한 걸음씩 성장 중! 💪
#머니펫 #투자공부 #금융교육
    ''';

    await Share.share(
      text,
      subject: 'Day $dayNumber 퀴즈 결과',
    );
  }

  /// Day 완료 공유
  static Future<void> shareDayCompletion({
    required UserModel user,
    required int dayNumber,
  }) async {
    final text = '''
✨ Day $dayNumber 학습 완료!

${user.name}님의 학습 현황:
📚 ${user.currentDay - 1}일 완료
⭐ ${user.totalPoints}P 획득
🔥 ${user.currentStreak}일 연속 학습

${user.personalityType.characterName}와 함께 꾸준히!
#머니펫 #투자공부 #금융교육
    ''';

    await Share.share(
      text,
      subject: 'Day $dayNumber 학습 완료',
    );
  }

  /// 연속 학습 기록 공유
  static Future<void> shareStreak({
    required UserModel user,
  }) async {
    final text = '''
🔥 ${user.currentStreak}일 연속 학습 달성!

${user.name}님의 학습 기록:
📚 총 ${user.currentDay - 1}일 학습
⭐ ${user.totalPoints}P 획득
🏆 최대 연속: ${user.maxStreak}일

${user.personalityType.characterName}와 함께 매일 성장 중! 💪
#머니펫 #투자공부 #금융교육 #연속학습
    ''';

    await Share.share(
      text,
      subject: '${user.currentStreak}일 연속 학습 달성',
    );
  }

  /// 성적 등급 계산
  static String _getGrade(double ratio) {
    if (ratio >= 0.9) return 'A+';
    if (ratio >= 0.8) return 'A';
    if (ratio >= 0.7) return 'B';
    if (ratio >= 0.6) return 'C';
    return 'D';
  }
}
