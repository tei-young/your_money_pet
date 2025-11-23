import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../main/main_screen.dart';

/// 첫 학습 소개 화면
/// 온보딩 마지막 단계
/// Day 1 학습 시작 전 안내
class FirstLearningIntroScreen extends StatelessWidget {
  final PersonalityType personalityType;
  final String userName;
  final String userGoal;

  const FirstLearningIntroScreen({
    super.key,
    required this.personalityType,
    required this.userName,
    required this.userGoal,
  });

  void _onStartLearning(BuildContext context) async {
    // 사용자 데이터 저장
    final userProvider = context.read<UserProvider>();
    await userProvider.createUser(
      name: userName,
      personalityType: personalityType,
      goal: userGoal,
    );

    // 메인 화면으로 이동 (온보딩 스택 모두 제거)
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white, // 온보딩과 일관된 흰색 배경
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

                    // 캐릭터
                    _buildCharacter(),

                    const SizedBox(height: 32),

                    // 환영 메시지
                    Text(
                      '준비 완료!',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: personalityType.color,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 부제
                    Text(
                      '이제 ${personalityType.characterName}와 함께\n투자 공부를 시작해볼까요?',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // 학습 안내 카드
                    _buildInfoCards(theme),

                    const SizedBox(height: 32),

                    // Day 1 미리보기
                    _buildDayPreview(theme),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  /// 캐릭터 표시
  Widget _buildCharacter() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(90),
        border: Border.all(
          color: personalityType.color.withOpacity(0.3),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: personalityType.color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.pets,
        size: 90,
        color: personalityType.color,
      ),
    );
  }

  /// 학습 안내 카드들
  Widget _buildInfoCards(ThemeData theme) {
    final infoItems = [
      _InfoItem(
        icon: Icons.menu_book,
        title: '하루 3분 학습',
        description: '부담 없이 카드로 읽어요',
      ),
      _InfoItem(
        icon: Icons.quiz_outlined,
        title: '2분 퀴즈',
        description: '배운 내용을 바로 확인해요',
      ),
      _InfoItem(
        icon: Icons.stars_outlined,
        title: '포인트 적립',
        description: '학습할 때마다 보상을 받아요',
      ),
    ];

    return Column(
      children: infoItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: personalityType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  item.icon,
                  color: personalityType.color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Day 1 미리보기
  Widget _buildDayPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            personalityType.color.withOpacity(0.1),
            personalityType.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: personalityType.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: personalityType.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Day 1',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 제목
          Text(
            '투자가 뭐예요?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 설명
          Text(
            '투자의 기본 개념과\n왜 투자를 해야 하는지 알아봐요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton(BuildContext context) {
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
          ElevatedButton(
            onPressed: () => _onStartLearning(context),
            child: const Text('학습 시작하기'),
          ),
          const SizedBox(height: 12),
          Text(
            '매일 5분, 365일 함께 성장해요 🚀',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// 안내 항목 데이터 모델
class _InfoItem {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
