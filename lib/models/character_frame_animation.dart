import 'character_animation_config.dart';
import '../services/animation_config_loader.dart';

/// 프레임 기반 캐릭터 애니메이션 설정
///
/// 각 상태별 프레임 수, 재생 속도, 루프 여부를 관리합니다.
class CharacterFrameAnimation {
  final String characterId;
  final CharacterAnimationState state;
  final int frameCount;
  final Duration frameDuration;
  final bool loop;

  const CharacterFrameAnimation({
    required this.characterId,
    required this.state,
    required this.frameCount,
    required this.frameDuration,
    this.loop = true,
  });

  /// 프레임 이미지 경로 생성
  ///
  /// 예: 'assets/animations/characters/hunter_cat/idle/frame_01.png'
  String getFramePath(int frameIndex) {
    final stateFolder = state.name; // 'idle', 'selected', etc.
    final frameNumber = (frameIndex + 1).toString().padLeft(2, '0');
    return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.png';
  }

  /// 총 애니메이션 길이
  Duration get totalDuration => frameDuration * frameCount;

  /// 상태별 프리셋 생성 (JSON 기반) - 권장 방식
  ///
  /// animation_config.json 파일에서 설정을 로드합니다.
  /// JSON 파일이 없으면 forState() fallback.
  ///
  /// ```dart
  /// final animation = await CharacterFrameAnimation.forStateAsync(
  ///   'hunter_cat',
  ///   CharacterAnimationState.idle,
  /// );
  /// ```
  static Future<CharacterFrameAnimation> forStateAsync(
    String characterId,
    CharacterAnimationState state,
  ) async {
    try {
      return await AnimationConfigLoader.createAnimation(characterId, state);
    } catch (e) {
      print('⚠️ Failed to load JSON config for $characterId:${state.name}, using defaults');
      return forState(characterId, state);
    }
  }

  /// 상태별 프리셋 생성 (하드코딩) - Fallback 용
  ///
  /// JSON 파일이 없을 때 사용되는 기본값.
  /// 프레임 수는 frameCountOverride로 덮어쓸 수 있습니다.
  static CharacterFrameAnimation forState(
    String characterId,
    CharacterAnimationState state, {
    int? frameCountOverride,
  }) {
    switch (state) {
      case CharacterAnimationState.idle:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 24,
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.selected:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 20,
          frameDuration: const Duration(milliseconds: 42), // 24fps, ~0.8초
          loop: false, // one-shot
        );

      case CharacterAnimationState.happy:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 30,
          frameDuration: const Duration(milliseconds: 42), // 24fps, ~1.2초
          loop: false,
        );

      case CharacterAnimationState.thinking:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 24,
          frameDuration: const Duration(milliseconds: 42), // 24fps, 1초 루프
          loop: true,
        );

      case CharacterAnimationState.confused:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 20,
          frameDuration: const Duration(milliseconds: 42), // 24fps, ~0.8초
          loop: false,
        );

      // 퀴즈 반응은 프레임 애니메이션 없음 (기존 방식 유지)
      case CharacterAnimationState.reactionPositive:
      case CharacterAnimationState.reactionNegative:
      case CharacterAnimationState.reactionNeutral:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: 1,
          frameDuration: const Duration(milliseconds: 100),
          loop: false,
        );
    }
  }
}
