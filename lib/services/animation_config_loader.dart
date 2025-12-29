import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/character_frame_animation.dart';
import '../models/character_animation_config.dart';

/// JSON 기반 애니메이션 설정 로더
///
/// 각 캐릭터의 animation_config.json 파일을 로드하고 캐싱합니다.
class AnimationConfigLoader {
  // 캐릭터별 설정 캐시
  static final Map<String, Map<String, dynamic>> _configCache = {};

  /// 캐릭터의 animation_config.json 로드
  ///
  /// ```dart
  /// final config = await AnimationConfigLoader.loadConfig('hunter_cat');
  /// ```
  static Future<Map<String, dynamic>> loadConfig(String characterId) async {
    // 캐시에서 먼저 확인
    if (_configCache.containsKey(characterId)) {
      return _configCache[characterId]!;
    }

    try {
      // JSON 파일 로드
      final jsonString = await rootBundle.loadString(
        'assets/animations/characters/$characterId/animation_config.json',
      );

      // 파싱
      final config = json.decode(jsonString) as Map<String, dynamic>;

      // 캐싱
      _configCache[characterId] = config;

      return config;
    } catch (e) {
      // JSON 파일이 없으면 기본값 반환
      print('⚠️ animation_config.json not found for $characterId, using defaults');
      return _getDefaultConfig();
    }
  }

  /// CharacterFrameAnimation 객체 생성 (JSON 기반)
  ///
  /// ```dart
  /// final animation = await AnimationConfigLoader.createAnimation(
  ///   'hunter_cat',
  ///   CharacterAnimationState.idle,
  /// );
  /// ```
  static Future<CharacterFrameAnimation> createAnimation(
    String characterId,
    CharacterAnimationState state,
  ) async {
    final config = await loadConfig(characterId);
    final stateConfig = config[state.name] as Map<String, dynamic>?;

    if (stateConfig == null) {
      // 상태 설정이 없으면 기본값 사용
      print('⚠️ No config for ${state.name}, using defaults');
      return CharacterFrameAnimation.forState(characterId, state);
    }

    return CharacterFrameAnimation(
      characterId: characterId,
      state: state,
      frameCount: stateConfig['frameCount'] as int,
      frameDuration: Duration(milliseconds: stateConfig['frameDuration'] as int),
      loop: stateConfig['loop'] as bool,
      autoTransitionTo: stateConfig['autoTransitionTo'] as String?,
    );
  }

  /// 여러 상태의 애니메이션을 한 번에 로드 (preload 용)
  ///
  /// ```dart
  /// final animations = await AnimationConfigLoader.createMultipleAnimations(
  ///   'hunter_cat',
  ///   [CharacterAnimationState.idle, CharacterAnimationState.selected],
  /// );
  /// ```
  static Future<List<CharacterFrameAnimation>> createMultipleAnimations(
    String characterId,
    List<CharacterAnimationState> states,
  ) async {
    // 설정 한 번만 로드
    await loadConfig(characterId);

    // 모든 상태 생성
    return Future.wait(
      states.map((state) => createAnimation(characterId, state)),
    );
  }

  /// 캐시 초기화 (테스트/디버깅 용)
  static void clearCache() {
    _configCache.clear();
  }

  /// 기본 설정 반환
  static Map<String, dynamic> _getDefaultConfig() {
    return {
      'idle': {
        'frameCount': 24,
        'frameDuration': 42,
        'loop': true,
      },
      'selected': {
        'frameCount': 20,
        'frameDuration': 42,
        'loop': false,
      },
      'happy': {
        'frameCount': 30,
        'frameDuration': 42,
        'loop': false,
      },
      'thinking': {
        'frameCount': 24,
        'frameDuration': 42,
        'loop': true,
      },
      'confused': {
        'frameCount': 20,
        'frameDuration': 42,
        'loop': false,
      },
    };
  }
}
