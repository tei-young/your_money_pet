import 'package:flutter/material.dart';
import '../models/character_animation_config.dart';
import '../models/character_frame_animation.dart';

/// 캐릭터 애니메이션 프레임 사전 로딩 서비스
///
/// 사용자 경험 최적화를 위해 프레임 이미지를 미리 메모리에 로드합니다.
class CharacterAnimationPreloader {
  /// 모든 캐릭터의 Greeting 상태 로드 (캐릭터 선택 화면용)
  ///
  /// 4개 캐릭터 × 120프레임 = 480개 이미지 (약 20MB)
  /// 예상 시간: 2-3초 (WiFi 기준)
  static Future<void> loadAllIdleStates(BuildContext context) async {
    final characters = [
      'money_bear',
      'save_sheep',
      'hunter_cat',
      'chaser_fox',
    ];

    await Future.wait(
      characters.map((characterId) => _loadCharacterState(
            context,
            characterId,
            CharacterAnimationState.characterGreetingLoop,
          )),
    );
  }

  /// 특정 캐릭터의 모든 온보딩 상태 로드 (캐릭터 선택 후)
  ///
  /// 1개 캐릭터 × 4개 상태 (characterSelected, personalityIdle, personalitySelected, resultCelebration)
  /// 예상 시간: 1-2초 (백그라운드)
  static Future<void> loadCharacterAllStates(
    BuildContext context,
    String characterId,
  ) async {
    await Future.wait([
      _loadCharacterState(context, characterId, CharacterAnimationState.characterSelected),
      _loadCharacterState(context, characterId, CharacterAnimationState.personalityIdle),
      _loadCharacterState(context, characterId, CharacterAnimationState.personalitySelected),
      _loadCharacterState(context, characterId, CharacterAnimationState.resultCelebration),
    ]);
  }

  /// 나머지 캐릭터 로드 (백그라운드, 유휴 시간)
  ///
  /// 3개 캐릭터 × 5개 상태 × 평균 10프레임 = 150개 이미지 (약 6MB)
  /// 예상 시간: 3-5초 (백그라운드)
  static Future<void> loadRemainingCharacters(
    BuildContext context,
    String selectedCharacterId,
  ) async {
    final allCharacters = [
      'money_bear',
      'save_sheep',
      'hunter_cat',
      'chaser_fox',
    ];

    final remainingCharacters =
        allCharacters.where((id) => id != selectedCharacterId).toList();

    for (final characterId in remainingCharacters) {
      await loadCharacterAllStates(context, characterId);
    }
  }

  /// 특정 캐릭터의 특정 상태 프레임 로드
  static Future<void> _loadCharacterState(
    BuildContext context,
    String characterId,
    CharacterAnimationState state,
  ) async {
    final animation = CharacterFrameAnimation.forState(characterId, state);

    final futures = <Future>[];
    for (int i = 0; i < animation.frameCount; i++) {
      final path = animation.getFramePath(i);
      futures.add(
        precacheImage(
          AssetImage(path),
          context,
          onError: (exception, stackTrace) {
            // 프레임 파일이 없어도 에러 무시 (Placeholder로 fallback)
            debugPrint('프레임 로드 실패 (정상): $path');
          },
        ),
      );
    }

    await Future.wait(futures);
  }

  /// 단일 프레임 이미지 로드 (테스트용)
  static Future<void> preloadSingleFrame(
    BuildContext context,
    String characterId,
    CharacterAnimationState state,
    int frameIndex,
  ) async {
    final animation = CharacterFrameAnimation.forState(characterId, state);
    final path = animation.getFramePath(frameIndex);

    await precacheImage(
      AssetImage(path),
      context,
      onError: (exception, stackTrace) {
        debugPrint('프레임 로드 실패: $path');
      },
    );
  }
}
