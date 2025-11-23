enum CharacterAnimationState {
  idle,
  selected,
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
