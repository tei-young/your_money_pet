import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'personality_test_screen.dart';

/// 앱 소개 화면
/// 3개 문장이 스와이프로 자연스럽게 전환
class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({super.key});

  @override
  State<AppIntroScreen> createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _messages = [
    '귀여운 친구와 함께',
    '투자 여행을 시작해요',
    '매일 조금씩 성장 🌱',
  ];

  @override
  void initState() {
    super.initState();

    // 각 페이지를 2초씩 자동으로 전환
    _autoAdvance();
  }

  void _autoAdvance() async {
    for (int i = 0; i < _messages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted && i < _messages.length - 1) {
        _pageController.animateToPage(
          i + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    // 마지막 문장 2초 후 성향 진단으로
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      _navigateToTest();
    }
  }

  void _navigateToTest() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PersonalityTestScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // 탭하면 바로 성향 진단으로
            if (_currentPage == _messages.length - 1) {
              _navigateToTest();
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _messages[index],
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
