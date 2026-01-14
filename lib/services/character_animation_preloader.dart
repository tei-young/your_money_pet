import 'package:flutter/material.dart';
import '../models/character_animation_config.dart';
import '../models/character_frame_animation.dart';

/// 캐릭터 애니메이션 프레임 사전 로딩 서비스
///
/// 사용자 경험 최적화를 위해 프레임 이미지를 미리 메모리에 로드합니다.
class CharacterAnimationPreloader {
  /// 모든 캐릭터의 Greeting 상태 로드 (캐릭터 선택 화면용)
  ///
  /// 성능 최적화: 점진적 로딩
  /// - 첫 캐릭터: 전체 프레임 (120개)
  /// - 나머지: 초기 10프레임만 (부드러운 시작)
  /// 총 150개 이미지 (약 5MB) → 초기 로딩 75% 감소
  /// 예상 시간: 0.5-1초
  static Future<void> loadAllIdleStates(BuildContext context) async {
    final characters = [
      'money_bear',
      'save_sheep',
      'hunter_cat',
      'chaser_fox',
    ];

    // 점진적 로딩: 첫 캐릭터만 전체, 나머지는 부분 로딩
    for (int i = 0; i < characters.length; i++) {
      await _loadCharacterStatePartial(
        context,
        characters[i],
        CharacterAnimationState.characterGreetingLoop,
        maxFrames: i == 0 ? null : 10, // 첫 캐릭터만 전체 로딩
      );
    }
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

  /// 특정 캐릭터의 특정 상태 프레임 로드 (전체)
  static Future<void> _loadCharacterState(
    BuildContext context,
    String characterId,
    CharacterAnimationState state,
  ) async {
    await _loadCharacterStatePartial(context, characterId, state);
  }

  /// 특정 캐릭터의 특정 상태 프레임 로드 (부분 또는 전체)
  ///
  /// [maxFrames]가 null이면 전체 프레임, 숫자면 해당 개수만 로드
  /// 성능 최적화: 초기 로딩 시간 단축
  static Future<void> _loadCharacterStatePartial(
    BuildContext context,
    String characterId,
    CharacterAnimationState state, {
    int? maxFrames,
  }) async {
    final animation = CharacterFrameAnimation.forState(characterId, state);
    final frameCount = maxFrames ?? animation.frameCount;

    final futures = <Future>[];
    for (int i = 0; i < frameCount; i++) {
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
