import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../../utils/share_helper.dart';
import '../main/main_screen.dart';

/// 퀴즈 결과 화면
/// 점수와 획득 포인트 표시
class QuizResultScreen extends StatelessWidget {
  final int dayNumber;
  final int totalQuestions;
  final int correctCount;
  final int earnedPoints;
  final bool isReview; // 복습 모드 여부

  const QuizResultScreen({
    super.key,
    required this.dayNumber,
    required this.totalQuestions,
    required this.correctCount,
    required this.earnedPoints,
    this.isReview = false, // 기본값: 일반 학습
  });

  double get _score => (correctCount / totalQuestions) * 100;

  String get _grade {
    if (_score >= 90) return 'A+';
    if (_score >= 80) return 'A';
    if (_score >= 70) return 'B';
    if (_score >= 60) return 'C';
    return 'D';
  }

  String get _message {
    if (_score >= 90) return '완벽해요! 🎉';
    if (_score >= 80) return '정말 잘했어요! 👏';
    if (_score >= 70) return '잘했어요! 💪';
    if (_score >= 60) return '조금만 더 힘내요! 😊';
    return '다시 복습해보세요! 📚';
  }

  void _onGoHome(BuildContext context) {
    // 홈 화면으로 돌아가기 (모든 학습 스택 제거하고 MainScreen으로 이동)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user!;
    final personalityColor = user.personalityType.color;

    return Scaffold(
      backgroundColor: personalityColor.withOpacity(0.05),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: ScreenSize.paddingHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Day 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isReview
                            ? Colors.orange.withOpacity(0.2)
                            : personalityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isReview ? 'Day $dayNumber 복습 완료' : 'Day $dayNumber 완료',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isReview ? Colors.orange : personalityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 점수 원형
                    _buildScoreCircle(theme, personalityColor),

                    const SizedBox(height: 32),

                    // 메시지
                    Text(
                      _message,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // 통계 카드들
                    _buildStatsCards(theme, personalityColor, user),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButton(context, personalityColor),
          ],
        ),
      ),
    );
  }

  /// 점수 원형
  Widget _buildScoreCircle(ThemeData theme, Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _grade,
            style: theme.textTheme.displayLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correctCount / $totalQuestions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드들
  Widget _buildStatsCards(ThemeData theme, Color color, user) {
    return Column(
      children: [
        // 정답률
        _buildStatCard(
          theme: theme,
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          label: '정답률',
          value: '${_score.toStringAsFixed(0)}%',
        ),

        const SizedBox(height: 12),

        // 획득 포인트 (복습 모드일 때는 다르게 표시)
        if (!isReview)
          _buildStatCard(
            theme: theme,
            icon: Icons.stars,
            iconColor: Colors.amber,
            label: '획득 포인트',
            value: '+$earnedPoints P',
          ),
        if (isReview)
          _buildStatCard(
            theme: theme,
            icon: Icons.refresh,
            iconColor: Colors.orange,
            label: '복습 모드',
            value: '포인트 없음',
          ),

        const SizedBox(height: 12),

        // 현재 연속 학습
        _buildStatCard(
          theme: theme,
          icon: Icons.local_fire_department,
          iconColor: color,
          label: '현재 연속',
          value: '${user.currentStreak}일',
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton(BuildContext context, Color color) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 공유 버튼
          OutlinedButton.icon(
            onPressed: () async {
              final user = Provider.of<UserProvider>(context, listen: false).user!;
              await ShareHelper.shareQuizResult(
                user: user,
                dayNumber: dayNumber,
                score: correctCount,
                totalQuestions: totalQuestions,
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('결과 공유하기'),
          ),
          const SizedBox(height: 12),
          // 홈으로 버튼
          ElevatedButton(
            onPressed: () => _onGoHome(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }
}
