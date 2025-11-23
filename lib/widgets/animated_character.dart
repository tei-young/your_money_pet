import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/character_animation_config.dart';
import 'speech_bubble.dart';

class AnimatedCharacter extends StatefulWidget {
  final PersonalityType character;
  final CharacterAnimationState state;
  final String? customDialogue;
  final VoidCallback? onTap;
  final double size;

  const AnimatedCharacter({
    super.key,
    required this.character,
    this.state = CharacterAnimationState.idle,
    this.customDialogue,
    this.onTap,
    this.size = 120,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.character.animationConfig;
    final isSelected = widget.state == CharacterAnimationState.selected;
    final dialogue = widget.customDialogue ?? config.introDialogue;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 애니메이션 (Placeholder)
          _buildCharacterPlaceholder(isSelected),

          // 말풍선 (선택된 경우에만)
          if (isSelected) ...[
            const SizedBox(height: 8),
            SpeechBubble(text: dialogue),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacterPlaceholder(bool isSelected) {
    // TODO: 추후 Rive 애니메이션으로 교체
    // RiveAnimation.asset('assets/animations/characters/${widget.character.name}_complete.riv')

    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: AnimationDuration.medium,
          transform: Matrix4.identity()
            ..scale(
              isSelected ? 1.15 : (widget.state == CharacterAnimationState.idle
                  ? _breathingAnimation.value
                  : 1.0),
            ),
          child: AnimatedOpacity(
            duration: AnimationDuration.medium,
            opacity: isSelected ? 1.0 : 0.85,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.character.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : widget.character.color,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _getCharacterEmoji(),
                  style: TextStyle(fontSize: widget.size * 0.4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCharacterEmoji() {
    switch (widget.character) {
      case PersonalityType.safe:
        return '🐻';
      case PersonalityType.balanced:
        return '🐑';
      case PersonalityType.aggressive:
        return '🐱';
      case PersonalityType.challenger:
        return '🦊';
    }
  }

  String _getReactionEmoji() {
    switch (widget.state) {
      case CharacterAnimationState.reactionPositive:
        return '😊';
      case CharacterAnimationState.reactionNegative:
        return '🤔';
      case CharacterAnimationState.reactionNeutral:
        return '💭';
      default:
        return _getCharacterEmoji();
    }
  }
}
