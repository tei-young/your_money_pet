import 'package:flutter/material.dart';

/// 메인 네비게이션 화면 (홈/학습/설정 탭)
///
/// TODO: 실제 구현 필요
/// 현재는 로그인 성공 후 이동할 placeholder 화면
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('머니펫'),
        backgroundColor: const Color(0xFF9F7AEA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 80,
              color: Color(0xFF9F7AEA),
            ),
            const SizedBox(height: 24),
            const Text(
              '홈 화면 (구현 예정)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getTabName(),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF9F7AEA),
        unselectedItemColor: const Color(0xFF718096),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '학습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  String _getTabName() {
    switch (_currentIndex) {
      case 0:
        return '홈 탭';
      case 1:
        return '학습 탭';
      case 2:
        return '설정 탭';
      default:
        return '';
    }
  }
}
