import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'first_learning_intro_screen.dart';

/// 목표 설정 화면
/// 사용자의 투자 목표 선택
class GoalSettingScreen extends StatefulWidget {
  final PersonalityType personalityType;
  final String userName;

  const GoalSettingScreen({
    super.key,
    required this.personalityType,
    required this.userName,
  });

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  String? _selectedGoal;

  final List<GoalOption> _goals = const [
    GoalOption(
      icon: Icons.home_outlined,
      title: '주택 구매',
      description: '내 집 마련을 위해 투자해요',
    ),
    GoalOption(
      icon: Icons.school_outlined,
      title: '자녀 교육',
      description: '아이의 미래를 준비해요',
    ),
    GoalOption(
      icon: Icons.beach_access_outlined,
      title: '은퇴 준비',
      description: '여유로운 노후를 보내요',
    ),
    GoalOption(
      icon: Icons.flight_takeoff_outlined,
      title: '여행',
      description: '꿈꿔왔던 여행을 떠나요',
    ),
    GoalOption(
      icon: Icons.savings_outlined,
      title: '자산 증식',
      description: '안정적으로 자산을 키워요',
    ),
    GoalOption(
      icon: Icons.favorite_outline,
      title: '기타',
      description: '나만의 특별한 목표가 있어요',
    ),
  ];

  void _onGoalSelected(String goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  void _onNext() {
    if (_selectedGoal == null) return;

    // 첫 학습 소개 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirstLearningIntroScreen(
          personalityType: widget.personalityType,
          userName: widget.userName,
          userGoal: _selectedGoal!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ScreenSize.paddingHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 인사말
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.displayMedium,
                        children: [
                          TextSpan(text: '${widget.userName}님,\n'),
                          const TextSpan(text: '반가워요!'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 부제
                    Text(
                      '투자를 통해 이루고 싶은\n목표를 알려주세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 목표 선택지
                    ..._goals.map((goal) => _buildGoalOption(goal, theme)),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// 목표 선택 옵션
  Widget _buildGoalOption(GoalOption goal, ThemeData theme) {
    final isSelected = _selectedGoal == goal.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? widget.personalityType.color.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: isSelected
              ? widget.personalityType.color
              : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onGoalSelected(goal.title),
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.personalityType.color.withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    goal.icon,
                    color: isSelected
                        ? widget.personalityType.color
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? widget.personalityType.color
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 선택 표시
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: widget.personalityType.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
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
        onPressed: _selectedGoal != null ? _onNext : null,
        child: const Text('다음'),
      ),
    );
  }
}

/// 목표 옵션 데이터 모델
class GoalOption {
  final IconData icon;
  final String title;
  final String description;

  const GoalOption({
    required this.icon,
    required this.title,
    required this.description,
  });
}
