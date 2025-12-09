import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../utils/text_renderer.dart';
import '../../models/learning_day_model.dart';
import '../../providers/learning_provider.dart';
import '../../providers/user_provider.dart';
import 'quiz_screen.dart';

/// 학습 화면
/// 카드 스와이프 방식으로 학습 진행
class LearningScreen extends StatefulWidget {
  final int dayNumber;
  final bool isReview; // 복습 모드 여부

  const LearningScreen({
    super.key,
    required this.dayNumber,
    this.isReview = false, // 기본값: 일반 학습
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
    // 복습 모드가 아닐 때만 학습 완료 처리
    if (!widget.isReview) {
      final learningProvider = context.read<LearningProvider>();
      await learningProvider.completeLearning(widget.dayNumber);
    }

    // 퀴즈 화면으로 이동 (복습 모드 플래그 전달)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            dayNumber: widget.dayNumber,
            learningDay: _learningDay!,
            isReview: widget.isReview, // 복습 모드 전달
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

    return Scaffold(
      // 배경: 통일된 진한 다크 퍼플
      backgroundColor: AppColors.learningBackground,
      body: Column(
        children: [
          // 미니멀 헤더 (Day + 제목 + 닫기)
          _buildMinimalHeader(theme),

          // 진행 바 + 카운트 통합
          _buildProgressBarWithCount(),

          // 2단계: 캐릭터 영역
          _buildCharacterSection(user, theme),

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
                    key: ValueKey(index),
                  ),
                );
              },
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// 미니멀 헤더 (Day + 제목 + 닫기)
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
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
          const SizedBox(width: 8),
          // Day 번호 + 제목 (복습 모드 표시)
          Expanded(
            child: Row(
              children: [
                Text(
                  'Day ${widget.dayNumber} • ${_learningDay!.title}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.learningAccentLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.isReview) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '복습',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 진행 바 + 카운트 통합
  Widget _buildProgressBarWithCount() {
    final progress = (_currentCardIndex + 1) / _learningDay!.cards.length;
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
            '${_currentCardIndex + 1}/${_learningDay!.cards.length}',
            style: TextStyle(
              color: AppColors.learningAccent.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 2단계: 캐릭터 영역 (상단 고정) - 약간 압축
  Widget _buildCharacterSection(dynamic user, ThemeData theme) {
    // 복습 모드와 일반 모드에 따른 메시지
    String message;
    if (widget.isReview) {
      // 복습 모드 메시지
      if (_currentCardIndex == _learningDay!.cards.length - 1) {
        message = "복습 완료! 📚";
      } else if (_currentCardIndex > _learningDay!.cards.length ~/ 2) {
        message = "다시 보니 어때요? 🤔";
      } else {
        message = "다시 복습해봐요! 📖";
      }
    } else {
      // 일반 학습 메시지
      if (_currentCardIndex == _learningDay!.cards.length - 1) {
        message = "거의 다 왔어요! 💪";
      } else if (_currentCardIndex > _learningDay!.cards.length ~/ 2) {
        message = "잘하고 있어요! 👍";
      } else {
        message = "함께 배워볼까요? 😊";
      }
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
          // 말풍선
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

  /// 학습 카드 (통일된 컬러 시스템 적용)
  Widget _buildLearningCard(
    LearningCard card,
    ThemeData theme, {
    Key? key,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 컨테이너 (하얀 바탕 + 그림자)
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
                // 카드 내용 (마크다운 렌더링 + Pretendard 폰트)
                ContentTextRenderer.render(
                  card.content,
                  baseStyle: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ) ?? const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                  boldWeight: FontWeight.w700,
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
                            color: AppColors.learningAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.learningAccent.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // 팁 (있으면)
                if (card.tip != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.learningAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.learningAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.learningAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡 Tip',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.learningAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ContentTextRenderer.render(
                                card.tip!,
                                baseStyle: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                  fontSize: 14,
                                ) ?? const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                  fontSize: 14,
                                ),
                                boldWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  /// 하단 버튼
  Widget _buildBottomButtons() {
    final isFirstCard = _currentCardIndex == 0;
    final isLastCard = _currentCardIndex == _learningDay!.cards.length - 1;

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
      child: Row(
        children: [
          // 이전 버튼
          if (!isFirstCard)
            Expanded(
              child: OutlinedButton(
                onPressed: _onPreviousCard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.learningAccentLight,
                  side: BorderSide(
                    color: AppColors.learningAccent.withOpacity(0.5),
                  ),
                ),
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
                backgroundColor: AppColors.learningAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(isLastCard ? '학습 완료' : '다음'),
            ),
          ),
        ],
      ),
    );
  }
}
