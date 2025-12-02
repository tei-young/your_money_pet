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

    return Scaffold(
      // 배경: 통일된 진한 다크 퍼플
      backgroundColor: AppColors.learningBackground,
      body: Column(
        children: [
          // 미니멀 헤더
          _buildMinimalHeader(theme),

          // 진행 바 + 카운트 통합
          _buildProgressBarWithCount(),

          // 2단계: 캐릭터 영역
          _buildCharacterSection(user, theme),

          // 퀴즈 내용 (애니메이션 효과)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: SingleChildScrollView(
                key: ValueKey(_currentQuestionIndex),
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 질문 카드 (하얀 바탕 + 그림자)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.learningAccent.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 질문
                          Text(
                            _currentQuestion.question,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              fontSize: 20,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 선택지
                          ..._currentQuestion.options
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            return _buildOptionCard(
                              index: index,
                              option: option,
                              theme: theme,
                            );
                          }),
                        ],
                      ),
                    ),

                    // 해설 (답변 후) - 피드백 제거, 해설만 표시
                    if (_hasAnswered) ...[
                      const SizedBox(height: 16),
                      _buildExplanation(theme),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 하단 버튼
          if (_hasAnswered) _buildBottomButton(),
        ],
      ),
    );
  }

  /// 미니멀 헤더
  Widget _buildMinimalHeader(ThemeData theme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.learningBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.learningAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 닫기 버튼
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.learningAccentLight,
            onPressed: () => _showExitDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
          const SizedBox(width: 8),
          // 퀴즈 타이틀
          Expanded(
            child: Text(
              '퀴즈',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.learningAccentLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 진행 바 + 카운트 통합
  Widget _buildProgressBarWithCount() {
    final progress =
        (_currentQuestionIndex + 1) / widget.learningDay.quizQuestions.length;
    final percentage = (progress * 100).toInt();

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.learningBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.learningAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 진행바
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.learningAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.learningAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 진행 표시
          Text(
            '$percentage%',
            style: TextStyle(
              color: AppColors.learningAccentLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${_currentQuestionIndex + 1}/${widget.learningDay.quizQuestions.length}',
            style: TextStyle(
              color: AppColors.learningAccent.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 2단계: 캐릭터 영역 - 정답/오답 피드백은 여기서만 표시
  Widget _buildCharacterSection(dynamic user, ThemeData theme) {
    // 정답/오답에 따른 메시지
    String message = "신중하게 생각해봐요! 🤔";
    if (_hasAnswered) {
      final isCorrect =
          _selectedAnswerIndex == _currentQuestion.correctAnswerIndex;
      if (isCorrect) {
        message = "정답이에요! 👏";
      } else {
        message = "아쉬워요! 다시 도전해봐요 💪";
      }
    } else if (_currentQuestionIndex > 0) {
      message = "잘하고 있어요! 👍";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.learningBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.learningAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 캐릭터 Placeholder (Rive 대기) - 약간 축소
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.learningAccent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.learningAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.pets,
              color: AppColors.learningAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 말풍선 - 피드백은 여기서만 표시
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.learningAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.learningAccent.withOpacity(0.3),
                ),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.learningAccentLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 선택지 카드
  Widget _buildOptionCard({
    required int index,
    required String option,
    required ThemeData theme,
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
      borderColor = isSelected ? AppColors.learningAccent : AppColors.border;
      backgroundColor = isSelected
          ? AppColors.learningAccent.withOpacity(0.1)
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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 번호
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: showResult
                        ? (isCorrect
                            ? AppColors.success
                            : isSelected
                                ? AppColors.error
                                : AppColors.background)
                        : (isSelected
                            ? AppColors.learningAccent
                            : AppColors.background),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: showResult && isCorrect
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : showResult && isSelected
                            ? const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                  ),
                ),

                const SizedBox(width: 12),

                // 선택지 텍스트
                Expanded(
                  child: Text(
                    option,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
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

  /// 해설 (피드백 제거, 해설만 표시)
  Widget _buildExplanation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.learningAccent.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.learningAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '해설',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.learningAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.learningBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.learningAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: _onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.learningAccent,
          foregroundColor: Colors.white,
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
