import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'name_setting_screen.dart';

/// 성향 진단 결과 화면
/// 진단된 성향과 캐릭터 표시
/// 모든 성향별 점수 표시
/// 다른 성향 보기 가능
class PersonalityResultScreen extends StatelessWidget {
  final PersonalityType resultType;
  final Map<PersonalityType, int> allScores;

  const PersonalityResultScreen({
    super.key,
    required this.resultType,
    required this.allScores,
  });

  void _onStartWithPersonality(BuildContext context) {
    // 이름 설정 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NameSettingScreen(personalityType: resultType),
      ),
    );
  }

  void _onViewOtherPersonalities(BuildContext context) {
    // 다른 성향 보기 바텀시트
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OtherPersonalitiesSheet(
        currentType: resultType,
        allScores: allScores,
        onSelectPersonality: (selectedType) {
          // 성향 선택 확인 다이얼로그
          _showConfirmDialog(context, selectedType);
        },
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, PersonalityType selectedType) {
    final shortName = selectedType.characterName.split(' ').last; // "머니베어", "세이브쉽" 등

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 메인 컨텐츠
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  // 제목
                  Text(
                    '성향 변경',
                    style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 선택한 캐릭터
                  Text(
                    '${selectedType.characterName}을 선택하셨네요!',
                    style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 커리큘럼 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📚 $shortName은 ${selectedType.curriculum} 알아볼 수 있어요!',
                      style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 선택하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // 다이얼로그 닫기
                        Navigator.pop(context); // 바텀시트 닫기
                        // 선택된 성향으로 이름 설정 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NameSettingScreen(personalityType: selectedType),
                          ),
                        );
                      },
                      child: const Text('선택하기'),
                    ),
                  ),
                ],
              ),
            ),

            // X 버튼 (오른쪽 위)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
                  children: [
                    const SizedBox(height: 16),

                    // 제목
                    Text(
                      '당신의 투자 성향은',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 성향 이름
                    Text(
                      resultType.displayName,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: resultType.color,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 캐릭터 (임시: 원형 아이콘)
                    _buildCharacter(),

                    const SizedBox(height: 32),

                    // 캐릭터 이름
                    Text(
                      resultType.characterName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 성향 설명
                    Text(
                      resultType.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // 점수 분포
                    _buildScoreDistribution(context),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  /// 캐릭터 표시
  Widget _buildCharacter() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: resultType.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: resultType.color.withOpacity(0.3),
          width: 4,
        ),
      ),
      child: Icon(
        Icons.pets,
        size: 100,
        color: resultType.color,
      ),
    );
  }

  /// 점수 분포 표시
  Widget _buildScoreDistribution(BuildContext context) {
    final theme = Theme.of(context);
    final maxScore = allScores.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '성향별 점수',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...PersonalityType.values.map((type) {
            final score = allScores[type] ?? 0;
            final percentage = maxScore > 0 ? score / maxScore : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 성향 이름 + 점수
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: type == resultType
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: type == resultType
                              ? type.color
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$score점',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: type == resultType
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: type == resultType
                              ? type.color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 프로그레스 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(type.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButtons(BuildContext context) {
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
          // 시작하기 버튼
          ElevatedButton(
            onPressed: () => _onStartWithPersonality(context),
            child: const Text('이 성향으로 시작'),
          ),

          const SizedBox(height: 12),

          // 다른 성향 보기 버튼
          OutlinedButton(
            onPressed: () => _onViewOtherPersonalities(context),
            child: const Text('다른 성향 보기'),
          ),
        ],
      ),
    );
  }
}

/// 다른 성향 보기 바텀시트
class _OtherPersonalitiesSheet extends StatefulWidget {
  final PersonalityType currentType;
  final Map<PersonalityType, int> allScores;
  final Function(PersonalityType) onSelectPersonality;

  const _OtherPersonalitiesSheet({
    required this.currentType,
    required this.allScores,
    required this.onSelectPersonality,
  });

  @override
  State<_OtherPersonalitiesSheet> createState() =>
      _OtherPersonalitiesSheetState();
}

class _OtherPersonalitiesSheetState extends State<_OtherPersonalitiesSheet> {
  PersonalityType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ScreenSize.paddingHorizontal,
                vertical: 8,
              ),
              child: Text(
                '다른 성향 살펴보기',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // 성향 리스트
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: ScreenSize.paddingHorizontal,
                  vertical: 16,
                ),
                children: PersonalityType.values.map((type) {
                  final score = widget.allScores[type] ?? 0;
                  final isCurrent = type == widget.currentType;
                  final isSelected = type == _selectedType;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : isCurrent
                              ? type.color.withOpacity(0.1)
                              : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(ScreenSize.borderRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isCurrent
                                ? type.color
                                : AppColors.border,
                        width: isSelected ? 2 : isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        borderRadius:
                            BorderRadius.circular(ScreenSize.borderRadius),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: type.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: type.color,
                              size: 28,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                type.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent ? type.color : null,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: type.color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '진단 결과',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                type.characterName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Text(
                            '$score점',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? type.color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 선택하기 버튼
            if (_selectedType != null)
              Container(
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
                  onPressed: () {
                    widget.onSelectPersonality(_selectedType!);
                  },
                  child: const Text('선택하기'),
                ),
              ),

            if (_selectedType == null) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
