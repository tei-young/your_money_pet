/// 캐릭터 애니메이션 상태
enum CharacterAnimationState {
  // 카테고리 1: 캐릭터 선택 화면 전용
  greeting,  // 손 흔들며 인사 (구 idle, 125 frames)
  selected,  // 선택됨 반응

  // 카테고리 2: 범용 상태 (모든 화면)
  idle,      // 진짜 조용한 대기 (5초, 복합 애니메이션)
  thinking,  // 퀴즈 문제 표시
  happy,     // 정답/긍정 피드백
  confused,  // 오답/부정 피드백

  // 카테고리 3: 홈 화면 전용
  homeStudying,     // 책 읽기
  homeExcited,      // 활기찬 모습
  homeSleepy,       // 졸린 모습
  homeCelebration,  // 목표 달성

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
