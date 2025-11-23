import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/learning_day_model.dart';
import '../../providers/learning_provider.dart';
import '../../providers/user_provider.dart';
import 'quiz_result_screen.dart';

/// 퀴즈 화면
/// 5문항 객관식 퀴즈
class QuizScreen extends StatefulWidget {
  final int dayNumber;
  final LearningDayModel learningDay;

  const QuizScreen({
    super.key,
    required this.dayNumber,
    required this.learningDay,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  QuizQuestion get _currentQuestion =>
      widget.learningDay.quizQuestions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.learningDay.quizQuestions.length - 1;

  void _onAnswerSelected(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;

      // 정답 체크
      if (index == _currentQuestion.correctAnswerIndex) {
        _correctCount++;
      }
    });
  }

  void _onNext() {
    if (!_hasAnswered) return;

    if (_isLastQuestion) {
      _onQuizComplete();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    }
  }

  Future<void> _onQuizComplete() async {
    final learningProvider = context.read<LearningProvider>();
    final userProvider = context.read<UserProvider>();

    // 퀴즈 완료 처리
    await learningProvider.completeQuiz(
      dayNumber: widget.dayNumber,
      score: _correctCount,
    );

    // 포인트 획득
    await userProvider.completeLearningDay(
      earnedPoints: widget.learningDay.points,
    );

    // 결과 화면으로 이동
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            dayNumber: widget.dayNumber,
            totalQuestions: widget.learningDay.quizQuestions.length,
            correctCount: _correctCount,
            earnedPoints: widget.learningDay.points,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user!;
    final personalityColor = user.personalityType.color;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitDialog(context);
          },
        ),
        title: Text(
          '퀴즈',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${widget.learningDay.quizQuestions.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행 바
          _buildProgressBar(personalityColor),

          // 퀴즈 내용
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // 질문
                  Text(
                    _currentQuestion.question,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 선택지
                  ..._currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return _buildOptionCard(
                      index: index,
                      option: option,
                      theme: theme,
                      personalityColor: personalityColor,
                    );
                  }),

                  // 해설 (답변 후)
                  if (_hasAnswered) ...[
                    const SizedBox(height: 24),
                    _buildExplanation(theme, personalityColor),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 하단 버튼
          if (_hasAnswered) _buildBottomButton(personalityColor),
        ],
      ),
    );
  }

  /// 진행 바
  Widget _buildProgressBar(Color color) {
    final progress =
        (_currentQuestionIndex + 1) / widget.learningDay.quizQuestions.length;

    return Container(
      height: 4,
      color: AppColors.background,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          color: color,
        ),
      ),
    );
  }

  /// 선택지 카드
  Widget _buildOptionCard({
    required int index,
    required String option,
    required ThemeData theme,
    required Color personalityColor,
  }) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == _currentQuestion.correctAnswerIndex;
    final showResult = _hasAnswered;

    Color borderColor;
    Color backgroundColor;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
      } else if (isSelected) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
      } else {
        borderColor = AppColors.border;
        backgroundColor = Colors.white;
      }
    } else {
      borderColor = isSelected ? personalityColor : AppColors.border;
      backgroundColor = isSelected
          ? personalityColor.withOpacity(0.1)
          : Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onAnswerSelected(index),
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 번호
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: showResult
                        ? (isCorrect
                            ? AppColors.success
                            : isSelected
                                ? AppColors.error
                                : AppColors.background)
                        : (isSelected
                            ? personalityColor
                            : AppColors.background),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: showResult && isCorrect
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : showResult && isSelected
                            ? const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                  ),
                ),

                const SizedBox(width: 16),

                // 선택지 텍스트
                Expanded(
                  child: Text(
                    option,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 해설
  Widget _buildExplanation(ThemeData theme, Color personalityColor) {
    final isCorrect =
        _selectedAnswerIndex == _currentQuestion.correctAnswerIndex;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '정답입니다!' : '아쉬워요!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton(Color color) {
    return Container(
      padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: Text(_isLastQuestion ? '결과 보기' : '다음 문제'),
      ),
    );
  }

  /// 종료 확인 다이얼로그
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈 종료'),
        content: const Text('퀴즈를 종료하시겠어요?\n진행 상황은 저장되지 않아요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 퀴즈 화면 닫기
            },
            child: const Text(
              '종료',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
