import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'app_intro_screen.dart';

/// 캐릭터 프리뷰 화면
/// 4개 캐릭터 바운스 애니메이션으로 등장
class CharacterPreviewScreen extends StatefulWidget {
  const CharacterPreviewScreen({super.key});

  @override
  State<CharacterPreviewScreen> createState() => _CharacterPreviewScreenState();
}

class _CharacterPreviewScreenState extends State<CharacterPreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 4개 캐릭터 각각 약간씩 딜레이를 주고 바운스
    _bounceAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1, // 0.0, 0.1, 0.2, 0.3
            0.6 + (index * 0.1), // 0.6, 0.7, 0.8, 0.9
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _controller.forward();

    // ❌ 자동 전환 제거 - 사용자 동작만으로 전환
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToIntro() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppIntroScreen(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // 제목
            Text(
              '어떤 머니펫과\n함께하게 될까요?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            // 캐릭터 4개 그리드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      // 상단 2개
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCharacter(
                            0,
                            PersonalityType.safe,
                            '🐻',
                          ),
                          _buildCharacter(
                            1,
                            PersonalityType.aggressive,
                            '🐱',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // 하단 2개
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCharacter(
                            2,
                            PersonalityType.balanced,
                            '🐑',
                          ),
                          _buildCharacter(
                            3,
                            PersonalityType.challenger,
                            '🦊',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const Spacer(flex: 3),

            // 시작하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ScreenSize.paddingHorizontal,
              ),
              child: ElevatedButton(
                onPressed: _navigateToIntro,
                child: const Text('시작하기'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 캐릭터 위젯
  Widget _buildCharacter(int index, PersonalityType type, String emoji) {
    final scale = _bounceAnimations[index].value;

    return Transform.scale(
      scale: scale,
      child: Column(
        children: [
          // 이모지 원형 배경
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: type.color.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 캐릭터 이름
          Text(
            type.characterName.split(' ').last, // "머니베어", "세이브쉽" 등
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: type.color,
            ),
          ),
        ],
      ),
    );
  }
}
