import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'personality_test_screen.dart';

/// Welcome 화면 (3개 슬라이드)
/// 슬라이드 1: 캐릭터 소개
/// 슬라이드 2: 학습 방식
/// 슬라이드 3: 실전 가치
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomeSlide> _slides = const [
    WelcomeSlide(
      icon: Icons.pets,
      title: '귀여운 친구가\n함께해요',
      features: [
        '🐻 머니베어: 안전한 투자',
        '🐱 코인캣: 공격적 투자',
        '🦆 세이빙덕: 절약 투자',
        '🐰 밸런스토끼: 균형 투자',
      ],
    ),
    WelcomeSlide(
      icon: Icons.school,
      title: '매일 5분,\n1일 1학습',
      features: [
        '📚 하루 3분 학습',
        '✍️ 2분 퀴즈',
        '🔥 연속 학습 보상',
      ],
    ),
    WelcomeSlide(
      icon: Icons.trending_up,
      title: '진짜 도움이 되는\n내용',
      features: [
        '💰 실제 계산 예시',
        '📊 구체적 금액',
        '✅ 바로 실천 가능',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AnimationDuration.medium,
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지: 성향 진단으로 이동
      _navigateToPersonalityTest();
    }
  }

  void _skip() {
    // 건너뛰기: 바로 성향 진단으로
    _navigateToPersonalityTest();
  }

  void _navigateToPersonalityTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonalityTestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 건너뛰기 버튼
            _buildTopBar(),

            // 중간: 슬라이드
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // 하단: 페이지 인디케이터 + 버튼
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  /// 상단 바 (건너뛰기 버튼)
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ScreenSize.paddingHorizontal,
        vertical: ScreenSize.paddingVertical,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _skip,
            child: const Text('건너뛰기'),
          ),
        ],
      ),
    );
  }

  /// 슬라이드 위젯
  Widget _buildSlide(WelcomeSlide slide) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ScreenSize.paddingHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 (임시: Material Icon 사용)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryPale,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              slide.icon,
              size: 100,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 48),

          // 제목
          Text(
            slide.title,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // 특징 리스트
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slide.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 하단 섹션 (페이지 인디케이터 + 버튼)
  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.only(
        left: ScreenSize.paddingHorizontal,
        right: ScreenSize.paddingHorizontal,
        bottom: 40,
      ),
      child: Column(
        children: [
          // 페이지 인디케이터
          _buildPageIndicator(),

          const SizedBox(height: 32),

          // 다음/시작하기 버튼
          ElevatedButton(
            onPressed: _nextPage,
            child: Text(isLastPage ? '시작하기' : '다음'),
          ),
        ],
      ),
    );
  }

  /// 페이지 인디케이터 (●●○)
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
      ),
    );
  }
}

/// Welcome 슬라이드 데이터 모델
class WelcomeSlide {
  final IconData icon;
  final String title;
  final List<String> features;

  const WelcomeSlide({
    required this.icon,
    required this.title,
    required this.features,
  });
}
