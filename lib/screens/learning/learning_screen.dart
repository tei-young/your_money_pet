import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/learning_day_model.dart';
import '../../providers/learning_provider.dart';
import '../../providers/user_provider.dart';
import 'quiz_screen.dart';

/// 학습 화면
/// 카드 스와이프 방식으로 학습 진행
class LearningScreen extends StatefulWidget {
  final int dayNumber;

  const LearningScreen({
    super.key,
    required this.dayNumber,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final PageController _pageController = PageController();
  int _currentCardIndex = 0;
  bool _isLoading = true;
  LearningDayModel? _learningDay;

  @override
  void initState() {
    super.initState();
    _loadLearningContent();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLearningContent() async {
    final learningProvider = context.read<LearningProvider>();
    await learningProvider.loadLearningDay(widget.dayNumber);

    setState(() {
      _learningDay = learningProvider.currentLearningDay;
      _isLoading = false;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentCardIndex = index;
    });
  }

  void _onNextCard() {
    if (_currentCardIndex < _learningDay!.cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onLearningComplete();
    }
  }

  void _onPreviousCard() {
    if (_currentCardIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onLearningComplete() async {
    final learningProvider = context.read<LearningProvider>();
    await learningProvider.completeLearning(widget.dayNumber);

    // 퀴즈 화면으로 이동
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            dayNumber: widget.dayNumber,
            learningDay: _learningDay!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _learningDay == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user!;
    final personalityColor = user.personalityType.color;

    return Scaffold(
      // 1단계: 배경에 연한 성향 컬러 그라데이션
      backgroundColor: personalityColor.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Day ${widget.dayNumber}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: personalityColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _learningDay!.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // 진행 표시
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentCardIndex + 1}/${_learningDay!.cards.length}',
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

          // 2단계: 캐릭터 영역
          _buildCharacterSection(user, personalityColor, theme),

          // 카드 영역 (애니메이션 효과 추가)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _learningDay!.cards.length,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildLearningCard(
                    _learningDay!.cards[index],
                    theme,
                    personalityColor,
                    key: ValueKey(index),
                  ),
                );
              },
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(personalityColor),
        ],
      ),
    );
  }

  /// 진행 바
  Widget _buildProgressBar(Color color) {
    final progress = (_currentCardIndex + 1) / _learningDay!.cards.length;

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

  /// 2단계: 캐릭터 영역 (상단 고정)
  Widget _buildCharacterSection(
      dynamic user, Color personalityColor, ThemeData theme) {
    // 카드 진행에 따른 메시지
    String message = "함께 배워볼까요? 😊";
    if (_currentCardIndex == _learningDay!.cards.length - 1) {
      message = "거의 다 왔어요! 💪";
    } else if (_currentCardIndex > _learningDay!.cards.length ~/ 2) {
      message = "잘하고 있어요! 👍";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 캐릭터 Placeholder (Rive 대기)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: personalityColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: personalityColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.pets,
              color: personalityColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // 말풍선
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: personalityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: personalityColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: personalityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 학습 카드 (1단계: 카드 그림자, 3단계: 타이포그래피)
  Widget _buildLearningCard(
    LearningCard card,
    ThemeData theme,
    Color personalityColor, {
    Key? key,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 1단계: 카드 컨테이너 (하얀 바탕 + 그림자)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: personalityColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3단계: 카드 내용 (타이포그래피 개선)
                Text(
                  card.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    fontSize: 18, // 17 → 18
                    color: AppColors.textPrimary,
                  ),
                ),

                // 이미지 (있으면)
                if (card.imageUrl != null) ...[
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      card.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: personalityColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: personalityColor.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // 팁 (있으면) - 1단계: 성향 컬러 활용
                if (card.tip != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: personalityColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: personalityColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: personalityColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡 Tip',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: personalityColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                card.tip!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButtons(Color color) {
    final isFirstCard = _currentCardIndex == 0;
    final isLastCard = _currentCardIndex == _learningDay!.cards.length - 1;

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
      child: Row(
        children: [
          // 이전 버튼
          if (!isFirstCard)
            Expanded(
              child: OutlinedButton(
                onPressed: _onPreviousCard,
                child: const Text('이전'),
              ),
            ),

          if (!isFirstCard) const SizedBox(width: 12),

          // 다음/완료 버튼
          Expanded(
            flex: isFirstCard ? 1 : 2,
            child: ElevatedButton(
              onPressed: _onNextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
              ),
              child: Text(isLastCard ? '학습 완료' : '다음'),
            ),
          ),
        ],
      ),
    );
  }
}
