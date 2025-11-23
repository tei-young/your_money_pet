import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class CharacterProvider extends ChangeNotifier {
  PersonalityType? _selectedCharacter;
  PersonalityType? _finalPersonality;

  PersonalityType? get selectedCharacter => _selectedCharacter;
  PersonalityType? get finalPersonality => _finalPersonality;

  // 캐릭터 선택 (프리뷰 화면에서)
  void selectCharacter(PersonalityType character) {
    _selectedCharacter = character;
    notifyListeners();
  }

  // 성향 퀴즈 결과 저장
  void setPersonalityResult(PersonalityType personality) {
    _finalPersonality = personality;
    notifyListeners();
  }

  // 캐릭터와 성향이 일치하는지
  bool get isCharacterMatchingPersonality =>
      _selectedCharacter != null &&
      _finalPersonality != null &&
      _selectedCharacter == _finalPersonality;

  // 온보딩 완료 후 초기화
  void reset() {
    _selectedCharacter = null;
    _finalPersonality = null;
    notifyListeners();
  }
}
