/// 캐릭터 애니메이션 상태 (2025-12-24 재설계: 13개 통합 애니메이션 방식)
enum CharacterAnimationState {
  // 카테고리 1: 캐릭터 선택 화면 (2개)
  characterGreetingLoop,  // 손 흔들며 인사 (약 5초, loop)
  characterSelected,      // 선택 반응 (약 1-2초, one-shot)

  // 카테고리 2-A: 성향 퀴즈 (2개)
  personalityIdle,      // 성향 문제 대기 (약 3초, loop)
  personalitySelected,  // 성향 선택 반응 (약 2초, auto→idle)

  // 카테고리 2-B: 학습 퀴즈 (3개) - 통합 애니메이션
  quizIdle,          // 학습 문제 대기 (약 3초, loop)
  quizCorrectFlow,   // 통합: thinking→happy→idle (약 4-6초, auto→quizIdle)
  quizWrongFlow,     // 통합: thinking→confused→idle (약 4-6초, auto→quizIdle)

  // 카테고리 3: 결과 화면 (1개)
  resultCelebration,  // 성향 결과 축하 (약 3초, one-shot)

  // 카테고리 4: 홈 화면 (5개)
  homeIdle,          // 기본 대기 - 복합 애니메이션 (약 5초, loop)
  homeStudying,      // 책 읽기 (약 3초, loop)
  homeExcited,       // 활기참 (약 2초, loop)
  homeSleepy,        // 졸림 (약 3초, loop)
  homeCelebration,   // 목표 달성 (약 2초, auto→homeIdle)
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
