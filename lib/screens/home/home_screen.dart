import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/learning_provider.dart';
import '../../utils/share_helper.dart';
import '../learning/learning_screen.dart';
import '../learning/learning_tab_screen.dart';

/// 홈 화면
/// 캐릭터 + 오늘의 학습 카드 + 진행 상황
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userProvider = context.read<UserProvider>();
    final learningProvider = context.read<LearningProvider>();

    // 사용자 데이터와 학습 진행 상태 로드
    await Future.wait([
      userProvider.loadUser(),
      learningProvider.initialize(),
    ]);
  }

  void _onStartLearning() {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    // 학습 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningScreen(dayNumber: user.currentDay),
      ),
    );
  }

  void _onReviewLesson() {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    // 오늘 완료한 Day를 복습 모드로 열기
    final completedDay = user.currentDay - 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningScreen(
          dayNumber: completedDay,
          isReview: true, // 복습 모드
        ),
      ),
    );
  }

  void _onViewAllLessons() {
    // 학습 탭으로 전환 (MainScreen의 탭 변경)
    // MainScreen이 부모이므로 직접 접근할 수 없음
    // 대신 DefaultTabController를 사용하거나, MainScreen에 전역 키를 사용해야 함
    // 간단하게: 학습 탭 화면으로 직접 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningTabScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<UserProvider, LearningProvider>(
          builder: (context, userProvider, learningProvider, _) {
            final user = userProvider.user;

            // 사용자 데이터가 없으면 로딩 표시
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final hasLearnedToday = user.hasLearnedToday;

            return CustomScrollView(
              slivers: [
                // 상단 앱바
                _buildAppBar(context, user),

                // 컨텐츠
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ScreenSize.paddingHorizontal,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),

                      // 캐릭터 영역
                      _buildCharacterSection(user),

                      const SizedBox(height: 32),

                      // 오늘의 학습 카드
                      _buildTodayLearningCard(user, hasLearnedToday),

                      const SizedBox(height: 24),

                      // 통계 영역
                      _buildStatsSection(user),

                      const SizedBox(height: 24),

                      // 공유 버튼
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ShareHelper.shareProgress(user: user);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('학습 현황 공유하기'),
                      ),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // 하단 네비게이션 바 (TODO: 나중에 구현)
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 상단 앱바
  Widget _buildAppBar(BuildContext context, user) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false, // 백버튼 제거
      title: Row(
        children: [
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
      actions: [
        // 포인트 표시
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryPale,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.stars,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${user.totalPoints}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 캐릭터 영역
  Widget _buildCharacterSection(user) {
    final theme = Theme.of(context);
    final personalityType = user.personalityType;

    return Container(
      padding: const EdgeInsets.all(24),
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
          color: personalityType.color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // 인사말
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요, ${user.name}님!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘도 함께 배워볼까요?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 연속 학습 배지
              if (user.currentStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.currentStreak}일',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // 캐릭터
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: personalityType.color.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: personalityType.color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.pets,
              size: 70,
              color: personalityType.color,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 오늘의 학습 카드
  Widget _buildTodayLearningCard(user, bool hasLearnedToday) {
    final theme = Theme.of(context);
    final currentDay = user.currentDay;
    final completedDay = currentDay - 1; // 오늘 완료한 Day

    // 오늘 학습 완료한 경우
    if (hasLearnedToday) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.success.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 완료 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: 20),

              // 완료 메시지
              Text(
                '🎉 오늘의 학습 완료!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Day $completedDay을 완료했어요!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                '내일은 Day $currentDay로 함께해요 🌟',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 복습하기 버튼
              ElevatedButton.icon(
                onPressed: _onReviewLesson,
                icon: const Icon(Icons.refresh),
                label: Text('Day $completedDay 복습하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 12),

              // 이전 학습 보기 버튼
              TextButton.icon(
                onPressed: _onViewAllLessons,
                icon: const Icon(Icons.list),
                label: const Text('이전 학습 보기'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 아직 학습 안 한 경우 (기존 UI)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onStartLearning,
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Day 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user.personalityType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Day $currentDay',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: user.personalityType.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 제목
                Text(
                  currentDay == 1 ? '투자가 뭐예요?' : 'Day $currentDay 학습 내용',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // 설명
                Text(
                  currentDay == 1
                      ? '투자의 기본 개념과 왜 투자를 해야 하는지 알아봐요'
                      : '오늘의 학습 내용을 확인해보세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // 시작 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onStartLearning,
                        child: const Text('학습 시작하기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 통계 영역
  Widget _buildStatsSection(user) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 학습 현황',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 진행 Day
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                iconColor: AppColors.primary,
                label: '학습 일수',
                value: '${user.currentDay - 1}일',
              ),
            ),
            const SizedBox(width: 12),
            // 누적 포인트
            Expanded(
              child: _buildStatCard(
                icon: Icons.stars,
                iconColor: Colors.amber,
                label: '누적 포인트',
                value: '${user.totalPoints}P',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 현재 연속
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                iconColor: AppColors.success,
                label: '현재 연속',
                value: '${user.currentStreak}일',
              ),
            ),
            const SizedBox(width: 12),
            // 최대 연속
            Expanded(
              child: _buildStatCard(
                icon: Icons.military_tech,
                iconColor: Colors.orange,
                label: '최대 연속',
                value: '${user.maxStreak}일',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
