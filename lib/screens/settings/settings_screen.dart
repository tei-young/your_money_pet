import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../onboarding/splash_screen.dart';

/// 설정 화면
/// 프로필 정보, 설정 변경
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                // 상단 앱바
                _buildAppBar(context),

                // 프로필 카드
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ScreenSize.paddingHorizontal,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildProfileCard(context, user),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // 설정 섹션
                _buildSettingsList(context, user, userProvider),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 상단 앱바
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: Text(
        '설정',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  /// 프로필 카드
  Widget _buildProfileCard(BuildContext context, user) {
    final theme = Theme.of(context);
    final personalityColor = user.personalityType.color;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            personalityColor.withOpacity(0.1),
            personalityColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: personalityColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 캐릭터
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: personalityColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Icon(
              Icons.pets,
              size: 40,
              color: personalityColor,
            ),
          ),

          const SizedBox(width: 20),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.personalityType.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: personalityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.goal,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 설정 리스트
  Widget _buildSettingsList(
    BuildContext context,
    user,
    UserProvider userProvider,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: ScreenSize.paddingHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 프로필 설정
          _buildSectionHeader(context, '프로필'),
          _buildSettingTile(
            context: context,
            icon: Icons.person_outline,
            title: '이름 변경',
            onTap: () => _showNameChangeDialog(context, user.name, userProvider),
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.psychology_outlined,
            title: '투자 성향 변경',
            subtitle: user.personalityType.displayName,
            onTap: () => _showPersonalityChangeDialog(context, userProvider),
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.flag_outlined,
            title: '투자 목표 변경',
            subtitle: user.goal,
            onTap: () => _showGoalChangeDialog(context, user.goal, userProvider),
          ),

          const SizedBox(height: 24),

          // 앱 설정
          _buildSectionHeader(context, '앱 설정'),
          _buildSettingTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            subtitle: '준비 중',
            onTap: null, // TODO: 알림 설정 구현
          ),

          const SizedBox(height: 24),

          // 기타
          _buildSectionHeader(context, '기타'),
          _buildSettingTile(
            context: context,
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.logout,
            title: '로그아웃',
            titleColor: AppColors.error,
            onTap: () => _showLogoutDialog(context, userProvider),
          ),
        ]),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  /// 설정 타일
  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: titleColor ?? AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 이름 변경 다이얼로그
  void _showNameChangeDialog(
    BuildContext context,
    String currentName,
    UserProvider userProvider,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이름 변경'),
        content: TextField(
          controller: controller,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: '새 이름 입력',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                await userProvider.updateName(newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름이 변경되었어요')),
                  );
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  /// 성향 변경 다이얼로그
  void _showPersonalityChangeDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('투자 성향 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('투자 성향을 변경하면 Day 1부터 다시 시작해요.'),
            const SizedBox(height: 16),
            ...PersonalityType.values.map((type) {
              return RadioListTile<PersonalityType>(
                title: Text(type.displayName),
                subtitle: Text(
                  type.characterName,
                  style: const TextStyle(fontSize: 12),
                ),
                value: type,
                groupValue: userProvider.user!.personalityType,
                onChanged: (value) async {
                  if (value != null) {
                    await userProvider.updatePersonality(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('성향이 변경되었어요. Day 1부터 시작해요.'),
                        ),
                      );
                    }
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 목표 변경 다이얼로그
  void _showGoalChangeDialog(
    BuildContext context,
    String currentGoal,
    UserProvider userProvider,
  ) {
    final goals = [
      '주택 구매',
      '자녀 교육',
      '은퇴 준비',
      '여행',
      '자산 증식',
      '기타',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('투자 목표 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) {
            return RadioListTile<String>(
              title: Text(goal),
              value: goal,
              groupValue: currentGoal,
              onChanged: (value) async {
                if (value != null) {
                  await userProvider.updateGoal(value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('목표가 변경되었어요')),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 앱 정보 다이얼로그
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 MoneyPet Team',
      children: [
        const SizedBox(height: 16),
        const Text(
          '귀여운 친구와 함께,\n매일 5분으로 금융 문맹 탈출',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 로그아웃 다이얼로그
  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠어요?\n모든 데이터가 삭제돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await userProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
