/// 캐릭터 애니메이션 상태
enum CharacterAnimationState {
  // 기본 상태
  idle,      // 기본 대기 (숨쉬기)
  selected,  // 선택됨 (손 흔들기)

  // 감정 상태 (프레임 애니메이션)
  happy,     // 기쁨 (점프)
  thinking,  // 고민 (머리 갸웃)
  confused,  // 혼란 (어리둥절)

  // 퀴즈 반응 (기존 호환성 유지)
  reactionPositive,
  reactionNegative,
  reactionNeutral,
}

enum ReactionType {
  positive,
  negative,
  neutral,
}

class CharacterAnimationConfig {
  final String characterId;
  final String introDialogue;
  final String quizGreeting;
  final Map<String, String> quizReactions;
  final String resultDialogueMatch;
  final String resultDialogueDifferent;

  const CharacterAnimationConfig({
    required this.characterId,
    required this.introDialogue,
    required this.quizGreeting,
    required this.quizReactions,
    required this.resultDialogueMatch,
    required this.resultDialogueDifferent,
  });
}
