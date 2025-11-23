import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_character.dart';
import '../../providers/character_provider.dart';
import '../../models/character_animation_config.dart';
import 'personality_test_screen.dart';

/// 캐릭터 프리뷰 화면
/// 4개 캐릭터 선택 → 선택한 캐릭터와 함께 성향 퀴즈로 이동
class CharacterPreviewScreen extends StatefulWidget {
  const CharacterPreviewScreen({super.key});

  @override
  State<CharacterPreviewScreen> createState() => _CharacterPreviewScreenState();
}

class _CharacterPreviewScreenState extends State<CharacterPreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _bounceAnimations;
  PersonalityType? _selectedCharacter;
  bool _showButton = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCharacterTap(PersonalityType character) {
    setState(() {
      _selectedCharacter = character;
      _showButton = true;
    });
  }

  void _navigateToPersonalityTest() {
    if (_selectedCharacter == null) return;

    // CharacterProvider에 선택된 캐릭터 저장
    context.read<CharacterProvider>().selectCharacter(_selectedCharacter!);

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
        child: Stack(
          children: [
            // 메인 컨텐츠
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // 제목
                  Text(
                    '어떤 머니펫과\n함께하게 될까요?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 80),

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
                                _buildCharacter(0, PersonalityType.safe),
                                _buildCharacter(1, PersonalityType.aggressive),
                              ],
                            ),
                            const SizedBox(height: 40),
                            // 하단 2개
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCharacter(2, PersonalityType.balanced),
                                _buildCharacter(3, PersonalityType.challenger),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 150), // 버튼 공간 확보
                ],
              ),
            ),

            // 하단 버튼 (선택된 경우에만 표시)
            if (_showButton)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: AnimationDuration.medium,
                  offset: _showButton ? Offset.zero : const Offset(0, 1),
                  curve: Curves.easeOut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SafeArea(
                      top: false,
                      child: ElevatedButton(
                        onPressed: _navigateToPersonalityTest,
                        child: const Text('같이 시작하기'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 캐릭터 위젯
  Widget _buildCharacter(int index, PersonalityType type) {
    final scale = _bounceAnimations[index].value;
    final isSelected = _selectedCharacter == type;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: _selectedCharacter != null && !isSelected ? 0.4 : 1.0,
        child: AnimatedCharacter(
          character: type,
          state: isSelected
              ? CharacterAnimationState.selected
              : CharacterAnimationState.idle,
          onTap: () => _onCharacterTap(type),
          size: 100,
        ),
      ),
    );
  }
}
