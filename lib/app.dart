import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/onboarding/splash_screen.dart';
import 'providers/user_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/character_provider.dart';

// TODO: Router import (나중에 추가)
// import 'routes/app_router.dart';

class MoneyPetApp extends StatelessWidget {
  const MoneyPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Splash 화면으로 시작
        home: const SplashScreen(),

        // TODO: Router 설정 (나중에)
        // routerConfig: appRouter,
      ),
    );
  }
}

/// 임시 홈 화면 (개발 확인용)
class _TemporaryHome extends StatelessWidget {
  const _TemporaryHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('머니펫'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // 제목
              Text(
                '머니펫',
                style: theme.textTheme.displayLarge,
              ),

              const SizedBox(height: 16),

              // 설명
              Text(
                '귀여운 친구와 함께,\n매일 5분으로 금융 문맹 탈출',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // 성향 컬러 샘플
              _PersonalityColorSample(),

              const SizedBox(height: 48),

              // 버튼 샘플
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flutter 환경이 정상 작동합니다!')),
                  );
                },
                child: const Text('테스트 버튼'),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary 버튼'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {},
                child: const Text('Text 버튼'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 성향별 컬러 샘플 위젯
class _PersonalityColorSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '성향별 컬러',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: PersonalityType.values.map((type) {
            return Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: type.color,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
