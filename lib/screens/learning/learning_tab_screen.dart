import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/learning_provider.dart';
import 'learning_screen.dart';

/// Learning 탭 화면
/// Day 목록과 진행 상황 표시
class LearningTabScreen extends StatelessWidget {
  const LearningTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<UserProvider, LearningProvider>(
          builder: (context, userProvider, learningProvider, _) {
            final user = userProvider.user;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                // 상단 앱바
                _buildAppBar(context, user),

                // 진행 상황 카드
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ScreenSize.paddingHorizontal,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildProgressCard(context, user, learningProvider),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Day 목록 헤더
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ScreenSize.paddingHorizontal,
                    ),
                    child: Text(
                      'Month ${user.currentMonth}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Day 목록
                _buildDayList(context, user, learningProvider),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 상단 앱바
  Widget _buildAppBar(BuildContext context, user) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: Text(
        '학습',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  /// 진행 상황 카드
  Widget _buildProgressCard(
    BuildContext context,
    user,
    LearningProvider learningProvider,
  ) {
    final theme = Theme.of(context);
    final personalityColor = user.personalityType.color;
    final currentMonth = user.currentMonth;
    final currentDayInMonth = user.currentDayInMonth;

    // 현재 월의 완료된 Day 수
    final completedDaysInMonth =
        learningProvider.getCompletedDaysInMonth(currentMonth);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 Day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${user.currentDay}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: personalityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Month $currentMonth의 $currentDayInMonth번째 학습',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: personalityColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.pets,
                  size: 30,
                  color: personalityColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 진행도 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이번 달 진행도',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$completedDaysInMonth/30',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: personalityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completedDaysInMonth / 30,
                  minHeight: 12,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(personalityColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Day 목록
  Widget _buildDayList(
    BuildContext context,
    user,
    LearningProvider learningProvider,
  ) {
    final currentMonth = user.currentMonth;
    final startDay = (currentMonth - 1) * 30 + 1;
    final endDay = currentMonth * 30;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: ScreenSize.paddingHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dayNumber = startDay + index;
            final isCurrentDay = dayNumber == user.currentDay;
            final isCompleted = learningProvider.isDayCompleted(dayNumber);
            final isLocked = dayNumber > user.currentDay;

            return _buildDayCard(
              context: context,
              dayNumber: dayNumber,
              isCurrentDay: isCurrentDay,
              isCompleted: isCompleted,
              isLocked: isLocked,
              personalityColor: user.personalityType.color,
            );
          },
          childCount: 30,
        ),
      ),
    );
  }

  /// Day 카드
  Widget _buildDayCard({
    required BuildContext context,
    required int dayNumber,
    required bool isCurrentDay,
    required bool isCompleted,
    required bool isLocked,
    required Color personalityColor,
  }) {
    final theme = Theme.of(context);

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (isLocked) {
      borderColor = AppColors.border;
      backgroundColor = AppColors.background;
      textColor = AppColors.textSecondary;
    } else if (isCurrentDay) {
      borderColor = personalityColor;
      backgroundColor = personalityColor.withOpacity(0.1);
      textColor = personalityColor;
    } else if (isCompleted) {
      borderColor = AppColors.success;
      backgroundColor = Colors.white;
      textColor = AppColors.textPrimary;
    } else {
      borderColor = AppColors.border;
      backgroundColor = Colors.white;
      textColor = AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(
          color: borderColor,
          width: isCurrentDay ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearningScreen(dayNumber: dayNumber),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day 번호
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppColors.border
                        : isCompleted
                            ? AppColors.success
                            : isCurrentDay
                                ? personalityColor
                                : AppColors.background,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 28,
                          )
                        : isLocked
                            ? const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 24,
                              )
                            : Text(
                                '$dayNumber',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: isCurrentDay
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                  ),
                ),

                const SizedBox(width: 16),

                // Day 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Day $dayNumber',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isCurrentDay) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: personalityColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '오늘',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNumber == 1
                            ? '투자가 뭐예요?'
                            : isLocked
                                ? '잠금'
                                : '학습 내용',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 완료 배지 또는 화살표
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '완료',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (!isLocked)
                  Icon(
                    Icons.chevron_right,
                    color: isCurrentDay ? personalityColor : AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
