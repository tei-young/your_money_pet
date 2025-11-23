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
      backgroundColor: Colors.white,
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
              style: theme.textTheme.titleSmall?.copyWith(
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

          // 카드 영역
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _learningDay!.cards.length,
              itemBuilder: (context, index) {
                return _buildLearningCard(
                  _learningDay!.cards[index],
                  theme,
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

  /// 학습 카드
  Widget _buildLearningCard(LearningCard card, ThemeData theme) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 카드 내용
          Text(
            card.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.8,
              fontSize: 17,
            ),
          ),

          // 이미지 (있으면)
          if (card.imageUrl != null) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
              child: Image.network(
                card.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            ),
          ],

          // 팁 (있으면)
          if (card.tip != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Tip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.tip!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
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
