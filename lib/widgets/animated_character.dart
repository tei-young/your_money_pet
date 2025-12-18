import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/character_animation_config.dart';
import '../models/character_frame_animation.dart';
import 'speech_bubble.dart';

/// 프레임 기반 캐릭터 애니메이션 위젯
///
/// 사용법:
/// ```dart
/// AnimatedCharacter(
///   characterType: PersonalityType.aggressive,
///   state: CharacterAnimationState.idle,
///   size: 200,
///   onAnimationComplete: () => print('완료!'),
/// )
/// ```
class AnimatedCharacter extends StatefulWidget {
  final PersonalityType characterType;
  final CharacterAnimationState state;
  final String? customDialogue;
  final VoidCallback? onTap;
  final VoidCallback? onAnimationComplete;
  final double size;

  const AnimatedCharacter({
    super.key,
    required this.characterType,
    this.state = CharacterAnimationState.idle,
    this.customDialogue,
    this.onTap,
    this.onAnimationComplete,
    this.size = 120,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CharacterFrameAnimation? _animation;
  int _currentFrame = 0;
  bool _hasFrames = true; // 프레임 파일 존재 여부
  bool _isLoading = true; // JSON 로딩 상태

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  Future<void> _setupAnimation() async {
    final characterId = widget.characterType.animationConfig.characterId;

    // JSON 기반 로딩 시도
    _animation = await CharacterFrameAnimation.forStateAsync(
      characterId,
      widget.state,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _controller = AnimationController(
      duration: _animation!.totalDuration,
      vsync: this,
    );

    _controller.addListener(() {
      final progress = _controller.value;
      final frameIndex = (progress * _animation!.frameCount).floor();

      if (frameIndex != _currentFrame) {
        setState(() {
          _currentFrame = frameIndex.clamp(0, _animation!.frameCount - 1);
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_animation!.loop) {
          _controller.repeat();
        } else {
          // One-shot 애니메이션 완료
          widget.onAnimationComplete?.call();
        }
      }
    });

    // 애니메이션 시작
    if (_animation!.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태가 변경되면 애니메이션 재설정
    if (oldWidget.state != widget.state ||
        oldWidget.characterType != widget.characterType) {
      if (!_isLoading) {
        _controller.dispose();
      }
      _currentFrame = 0;
      setState(() {
        _isLoading = true;
        _hasFrames = true; // 새로운 상태에서 다시 체크
      });
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    if (!_isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.characterType.animationConfig;
    final isSelected = widget.state == CharacterAnimationState.selected;
    final dialogue = widget.customDialogue ?? config.introDialogue;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 애니메이션
          if (_isLoading)
            _buildPlaceholder() // 로딩 중
          else if (_hasFrames)
            _buildFrameAnimation() // 프레임 애니메이션
          else
            _buildPlaceholder(), // 프레임 없음

          // 말풍선 (선택된 경우에만)
          if (isSelected) ...[
            const SizedBox(height: 8),
            SpeechBubble(text: dialogue),
          ],
        ],
      ),
    );
  }

  /// 프레임 기반 애니메이션
  Widget _buildFrameAnimation() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.asset(
        _animation!.getFramePath(_currentFrame),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        gaplessPlayback: true, // 깜빡임 방지
        errorBuilder: (context, error, stackTrace) {
          // 프레임 파일이 없으면 Placeholder로 fallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _hasFrames) {
              setState(() {
                _hasFrames = false;
              });
              // 애니메이션 정지 (불필요한 프레임 로드 시도 방지)
              if (!_isLoading) {
                _controller.stop();
              }
            }
          });
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Placeholder (프레임 파일 없을 때)
  Widget _buildPlaceholder() {
    final isSelected = widget.state == CharacterAnimationState.selected;

    return AnimatedContainer(
      duration: AnimationDuration.medium,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.characterType.color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : widget.characterType.color,
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
    );
  }

  String _getCharacterEmoji() {
    switch (widget.characterType) {
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
}
