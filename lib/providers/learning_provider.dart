import 'package:flutter/foundation.dart';
import '../models/learning_day_model.dart';

/// 학습 진행 상태 관리 Provider
class LearningProvider with ChangeNotifier {
  // 모든 학습 진행 상태 (dayNumber -> LearningProgress)
  final Map<int, LearningProgress> _progressMap = {};

  // 현재 로드된 학습 Day
  LearningDayModel? _currentLearningDay;

  LearningDayModel? get currentLearningDay => _currentLearningDay;

  /// 초기화
  Future<void> initialize() async {
    // TODO: SharedPreferences 또는 Firebase에서 진행 상태 로드
    await _loadProgress();
  }

  /// 특정 Day의 진행 상태 가져오기
  LearningProgress? getProgress(int dayNumber) {
    return _progressMap[dayNumber];
  }

  /// 특정 Day가 완료되었는지 확인
  bool isDayCompleted(int dayNumber) {
    final progress = _progressMap[dayNumber];
    return progress?.isFullyCompleted ?? false;
  }

  /// 특정 Day의 학습만 완료되었는지
  bool isLearningCompleted(int dayNumber) {
    final progress = _progressMap[dayNumber];
    return progress?.isLearningCompleted ?? false;
  }

  /// 특정 Day의 퀴즈만 완료되었는지
  bool isQuizCompleted(int dayNumber) {
    final progress = _progressMap[dayNumber];
    return progress?.isQuizCompleted ?? false;
  }

  /// 학습 Day 로드
  Future<void> loadLearningDay(int dayNumber) async {
    // TODO: Firestore에서 학습 데이터 로드
    // 임시 데이터로 Day 1 생성
    if (dayNumber == 1) {
      _currentLearningDay = _createDay1();
    } else {
      _currentLearningDay = _createPlaceholderDay(dayNumber);
    }

    notifyListeners();
  }

  /// 학습 완료 처리
  Future<void> completeLearning(int dayNumber) async {
    final progress = _progressMap[dayNumber] ?? LearningProgress(dayNumber: dayNumber);

    _progressMap[dayNumber] = progress.copyWith(
      isLearningCompleted: true,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 퀴즈 완료 처리
  Future<void> completeQuiz({
    required int dayNumber,
    required int score,
  }) async {
    final progress = _progressMap[dayNumber] ?? LearningProgress(dayNumber: dayNumber);

    final now = DateTime.now();
    _progressMap[dayNumber] = progress.copyWith(
      isQuizCompleted: true,
      quizScore: score,
      completedAt: now,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 완료된 Day 개수
  int get completedDaysCount {
    return _progressMap.values.where((p) => p.isFullyCompleted).length;
  }

  /// 현재 월 완료 Day 개수
  int getCompletedDaysInMonth(int monthNumber) {
    final startDay = (monthNumber - 1) * 30 + 1;
    final endDay = monthNumber * 30;

    return _progressMap.values
        .where((p) =>
            p.dayNumber >= startDay &&
            p.dayNumber <= endDay &&
            p.isFullyCompleted)
        .length;
  }

  /// 진행 상태 저장
  Future<void> _saveProgress() async {
    // TODO: SharedPreferences에 저장
    // final prefs = await SharedPreferences.getInstance();
    // final progressJson = _progressMap.map(
    //   (key, value) => MapEntry(key.toString(), value.toJson()),
    // );
    // await prefs.setString('learningProgress', jsonEncode(progressJson));

    debugPrint('Learning progress saved');
  }

  /// 진행 상태 로드
  Future<void> _loadProgress() async {
    // TODO: SharedPreferences에서 로드
    // final prefs = await SharedPreferences.getInstance();
    // final progressJson = prefs.getString('learningProgress');
    // if (progressJson != null) {
    //   final decoded = jsonDecode(progressJson) as Map<String, dynamic>;
    //   _progressMap.clear();
    //   decoded.forEach((key, value) {
    //     _progressMap[int.parse(key)] = LearningProgress.fromJson(value);
    //   });
    // }

    debugPrint('Learning progress loaded');
  }

  /// 임시: Day 1 데이터 생성
  LearningDayModel _createDay1() {
    return const LearningDayModel(
      dayNumber: 1,
      title: '투자가 뭐예요?',
      cards: [
        LearningCard(
          id: 'day1_card1',
          content: '''
# 투자란?

**투자**는 미래에 더 큰 가치를 얻기 위해 현재의 돈이나 시간을 사용하는 것이에요.

예를 들어:
- 은행에 예금하기
- 주식 사기
- 부동산 구매하기

이 모든 것이 투자랍니다! 🚀
''',
        ),
        LearningCard(
          id: 'day1_card2',
          content: '''
# 왜 투자해야 할까요?

돈을 그냥 두면 **물가 상승** 때문에 가치가 줄어들어요.

**예시:**
- 지금 1만원으로 라면 10개 구매
- 10년 후 1만원으로 라면 7개만 구매 😢

투자를 하면 돈의 가치를 지키고 늘릴 수 있어요!
''',
          tip: '물가 상승률은 보통 연 2-3%예요. 투자 수익률이 이보다 높아야 돈의 가치를 지킬 수 있죠!',
        ),
        LearningCard(
          id: 'day1_card3',
          content: '''
# 투자의 종류

**안전한 투자:**
- 예금, 적금
- 국채

**중간 위험 투자:**
- ETF (상장지수펀드)
- 펀드

**높은 위험 투자:**
- 개별 주식
- 가상자산

위험이 높을수록 수익도 크지만, 손실 위험도 커요! ⚖️
''',
        ),
      ],
      quizQuestions: [
        QuizQuestion(
          id: 'day1_q1',
          question: '투자를 해야 하는 가장 중요한 이유는?',
          options: [
            '부자가 되기 위해',
            '물가 상승으로 인한 돈의 가치 하락을 막기 위해',
            '남들이 하니까',
            '재미있어서',
          ],
          correctAnswerIndex: 1,
          explanation: '투자의 가장 중요한 목적은 물가 상승률보다 높은 수익을 내서 돈의 가치를 지키는 것이에요.',
        ),
        QuizQuestion(
          id: 'day1_q2',
          question: '다음 중 가장 안전한 투자는?',
          options: [
            '개별 주식',
            '가상자산',
            '예금',
            'ETF',
          ],
          correctAnswerIndex: 2,
          explanation: '예금은 원금이 보장되어 가장 안전한 투자 방법이에요. 하지만 수익률은 낮은 편이죠.',
        ),
        QuizQuestion(
          id: 'day1_q3',
          question: '투자에서 위험과 수익의 관계는?',
          options: [
            '위험이 높을수록 수익도 크다',
            '위험과 수익은 관계가 없다',
            '위험이 낮을수록 수익이 크다',
            '항상 일정하다',
          ],
          correctAnswerIndex: 0,
          explanation: '일반적으로 위험이 높을수록 기대 수익도 커요. 이를 "고위험 고수익"이라고 해요!',
        ),
        QuizQuestion(
          id: 'day1_q4',
          question: '물가가 연 3% 상승한다면, 투자 수익률은 최소 얼마여야 돈의 가치를 유지할 수 있을까요?',
          options: [
            '1%',
            '2%',
            '3%',
            '5%',
          ],
          correctAnswerIndex: 2,
          explanation: '물가 상승률과 같은 3% 이상의 수익률을 내야 실질적인 돈의 가치를 유지할 수 있어요.',
        ),
        QuizQuestion(
          id: 'day1_q5',
          question: 'ETF는 어떤 위험도의 투자일까요?',
          options: [
            '매우 안전',
            '중간 위험',
            '매우 위험',
            '위험 없음',
          ],
          correctAnswerIndex: 1,
          explanation: 'ETF는 여러 주식에 분산 투자하기 때문에 개별 주식보다는 안전하지만, 예금보다는 위험해요.',
        ),
      ],
      points: 10,
    );
  }

  /// 임시: 다른 Day용 플레이스홀더 데이터
  LearningDayModel _createPlaceholderDay(int dayNumber) {
    return LearningDayModel(
      dayNumber: dayNumber,
      title: 'Day $dayNumber 학습 내용',
      cards: const [
        LearningCard(
          id: 'placeholder_card',
          content: '이 Day의 학습 내용은 준비 중입니다.',
        ),
      ],
      quizQuestions: const [],
      points: 10,
    );
  }
}
