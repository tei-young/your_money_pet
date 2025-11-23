import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'personality_test_screen.dart';

/// 앱 소개 화면
/// 3개 문장이 페이드 인/아웃으로 전환 (사용자 동작 필요)
class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({super.key});

  @override
  State<AppIntroScreen> createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
  int _currentIndex = 0;

  final List<String> _messages = [
    '귀여운 친구와 함께',
    '투자 여행을 시작해요',
    '매일 조금씩 성장해요 🌱',
  ];

  void _onTap() {
    if (_currentIndex < _messages.length - 1) {
      // 다음 문장으로
      setState(() {
        _currentIndex++;
      });
    } else {
      // 마지막 문장이면 성향 진단으로
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: _onTap,
          onHorizontalDragEnd: (details) {
            // 스와이프 제스처 지원
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                // 왼쪽으로 스와이프 (다음)
                _onTap();
              }
            }
          },
          child: Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    _messages[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
