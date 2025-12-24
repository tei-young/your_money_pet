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
  /// 예: 'assets/animations/characters/hunter_cat/character_greeting_loop/frame_01.png'
  String getFramePath(int frameIndex) {
    final stateFolder = _stateToFolderName(state);
    final frameNumber = (frameIndex + 1).toString().padLeft(2, '0');
    return 'assets/animations/characters/$characterId/$stateFolder/frame_$frameNumber.png';
  }

  /// camelCase enum → snake_case 폴더명 변환
  ///
  /// 예: CharacterAnimationState.characterGreetingLoop → 'character_greeting_loop'
  static String _stateToFolderName(CharacterAnimationState state) {
    switch (state) {
      case CharacterAnimationState.characterGreetingLoop:
        return 'character_greeting_loop';
      case CharacterAnimationState.characterSelected:
        return 'character_selected';
      case CharacterAnimationState.personalityIdle:
        return 'personality_idle';
      case CharacterAnimationState.personalitySelected:
        return 'personality_selected';
      case CharacterAnimationState.quizIdle:
        return 'quiz_idle';
      case CharacterAnimationState.quizCorrectFlow:
        return 'quiz_correct_flow';
      case CharacterAnimationState.quizWrongFlow:
        return 'quiz_wrong_flow';
      case CharacterAnimationState.resultCelebration:
        return 'result_celebration';
      case CharacterAnimationState.homeIdle:
        return 'home_idle';
      case CharacterAnimationState.homeStudying:
        return 'home_studying';
      case CharacterAnimationState.homeExcited:
        return 'home_excited';
      case CharacterAnimationState.homeSleepy:
        return 'home_sleepy';
      case CharacterAnimationState.homeCelebration:
        return 'home_celebration';
    }
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
  /// JSON 파일이 없을 때 사용되는 기본값 (13-state 시스템)
  /// 프레임 수는 frameCountOverride로 덮어쓸 수 있습니다.
  static CharacterFrameAnimation forState(
    String characterId,
    CharacterAnimationState state, {
    int? frameCountOverride,
  }) {
    switch (state) {
      // 카테고리 1: 캐릭터 선택 화면 (2개)
      case CharacterAnimationState.characterGreetingLoop:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 120, // 약 5초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.characterSelected:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 36, // 약 1.5초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot
        );

      // 카테고리 2-A: 성향 퀴즈 (2개)
      case CharacterAnimationState.personalityIdle:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 72, // 약 3초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.personalitySelected:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 48, // 약 2초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot, auto→personalityIdle
        );

      // 카테고리 2-B: 학습 퀴즈 (3개) - 통합 애니메이션
      case CharacterAnimationState.quizIdle:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 72, // 약 3초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.quizCorrectFlow:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 120, // 약 5초 (thinking→happy→idle)
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot, auto→quizIdle
        );

      case CharacterAnimationState.quizWrongFlow:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 120, // 약 5초 (thinking→confused→idle)
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot, auto→quizIdle
        );

      // 카테고리 3: 결과 화면 (1개)
      case CharacterAnimationState.resultCelebration:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 72, // 약 3초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot
        );

      // 카테고리 4: 홈 화면 (5개)
      case CharacterAnimationState.homeIdle:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 120, // 약 5초 복합 애니메이션
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.homeStudying:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 72, // 약 3초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.homeExcited:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 48, // 약 2초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.homeSleepy:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 72, // 약 3초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: true,
        );

      case CharacterAnimationState.homeCelebration:
        return CharacterFrameAnimation(
          characterId: characterId,
          state: state,
          frameCount: frameCountOverride ?? 48, // 약 2초
          frameDuration: const Duration(milliseconds: 42), // 24fps
          loop: false, // one-shot, auto→homeIdle
        );
    }
  }
}
