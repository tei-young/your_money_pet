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
    this.state = CharacterAnimationState.homeIdle,
    this.customDialogue,
    this.onTap,
    this.onAnimationComplete,
    this.size = 120,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  CharacterFrameAnimation? _animation;
  final ValueNotifier<int> _frameNotifier = ValueNotifier<int>(0); // 성능 최적화: setState 제거
  bool _hasFrames = true; // 프레임 파일 존재 여부
  bool _isLoading = true; // JSON 로딩 상태

  // 자동 전환을 위한 내부 상태
  CharacterAnimationState? _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.state; // 초기 상태 설정
    _setupAnimation();
  }

  /// 현재 활성 상태 (자동 전환 고려)
  CharacterAnimationState get _activeState => _currentState ?? widget.state;

  Future<void> _setupAnimation() async {
    final characterId = widget.characterType.animationConfig.characterId;

    // JSON 기반 로딩 시도 (내부 상태 사용)
    _animation = await CharacterFrameAnimation.forStateAsync(
      characterId,
      _activeState,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Controller가 없으면 생성, 있으면 재사용
    if (_controller == null) {
      _controller = AnimationController(
        duration: _animation!.totalDuration,
        vsync: this,
      );

      _controller!.addListener(() {
        if (_animation == null) return;
        final progress = _controller!.value;
        final frameIndex = (progress * _animation!.frameCount).floor();

        if (frameIndex != _frameNotifier.value) {
          // 성능 최적화: setState 대신 ValueNotifier 사용
          _frameNotifier.value = frameIndex.clamp(0, _animation!.frameCount - 1);
        }
      });

      _controller!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_animation!.loop) {
            _controller!.repeat();
          } else {
            // One-shot 애니메이션 완료
            widget.onAnimationComplete?.call();

            // 자동 전환 처리
            if (_animation!.autoTransitionTo != null) {
              _handleAutoTransition(_animation!.autoTransitionTo!);
            }
          }
        }
      });
    } else {
      // Controller 재사용: duration 업데이트
      _controller!.stop();
      _controller!.duration = _animation!.totalDuration;
      _controller!.reset();
    }

    // 애니메이션 시작
    if (_animation!.loop) {
      _controller!.repeat();
    } else {
      _controller!.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태가 변경되면 애니메이션 재설정
    if (oldWidget.state != widget.state ||
        oldWidget.characterType != widget.characterType) {
      _frameNotifier.value = 0;
      _currentState = widget.state; // 외부 상태 변경 반영
      setState(() {
        _isLoading = true;
        _hasFrames = true; // 새로운 상태에서 다시 체크
      });
      _setupAnimation(); // Controller 재사용
    }
  }

  /// 자동 전환 처리
  ///
  /// autoTransitionTo 필드에 지정된 상태 이름을 CharacterAnimationState로 변환하여 전환
  void _handleAutoTransition(String nextStateName) {
    final nextState = _stringToState(nextStateName);
    if (nextState != null) {
      setState(() {
        _currentState = nextState;
        _isLoading = true;
        _hasFrames = true;
      });
      _setupAnimation();
    } else {
      print('⚠️ Unknown autoTransitionTo state: $nextStateName');
    }
  }

  /// 문자열 → CharacterAnimationState 변환
  ///
  /// JSON의 "autoTransitionTo": "personalityIdle" → CharacterAnimationState.personalityIdle
  CharacterAnimationState? _stringToState(String stateName) {
    try {
      return CharacterAnimationState.values.firstWhere(
        (state) => state.name == stateName,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _frameNotifier.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.characterType.animationConfig;
    final isSelected = _activeState == CharacterAnimationState.characterSelected;
    final dialogue = widget.customDialogue ?? config.introDialogue;

    // 성능 최적화: RepaintBoundary로 불필요한 rebuild 방지
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 캐릭터 애니메이션 (로딩 중에도 계속 표시)
            if (_hasFrames && _animation != null)
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
      ),
    );
  }

  /// 프레임 기반 애니메이션
  Widget _buildFrameAnimation() {
    // 성능 최적화: ValueListenableBuilder로 프레임만 업데이트
    return ValueListenableBuilder<int>(
      valueListenable: _frameNotifier,
      builder: (context, currentFrame, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Image.asset(
            _animation!.getFramePath(currentFrame),
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true, // 깜빡임 방지
            // 성능 최적화: 이미지 캐시 크기 제한으로 메모리 절약
            cacheWidth: (widget.size * 2).toInt(),
            cacheHeight: (widget.size * 2).toInt(),
            errorBuilder: (context, error, stackTrace) {
              // 프레임 파일이 없으면 Placeholder로 fallback
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _hasFrames) {
                  setState(() {
                    _hasFrames = false;
                  });
                  // 애니메이션 정지 (불필요한 프레임 로드 시도 방지)
                  _controller?.stop();
                }
              });
              return _buildPlaceholder();
            },
          ),
        );
      },
    );
  }

  /// Placeholder (프레임 파일 없을 때)
  Widget _buildPlaceholder() {
    final isSelected = _activeState == CharacterAnimationState.characterSelected;

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
