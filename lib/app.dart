import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_providers.dart';
import 'data/services/onesignal_service.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';

class RasaApp extends ConsumerStatefulWidget {
  const RasaApp({super.key});

  @override
  ConsumerState<RasaApp> createState() => _RasaAppState();
}

class _RasaAppState extends ConsumerState<RasaApp> {
  @override
  void initState() {
    super.initState();
    OneSignalService.init();
  }

  @override
  Widget build(BuildContext context) {
    // Session siap → daftarkan user ke OneSignal (external_id).
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      final wasOut = prev == null || !prev.initialized;
      if (next.initialized && (wasOut || prev!.userId != next.userId)) {
        OneSignalService.login(next.userId, next.alias);
      }
    });

    final session = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeModeProvider);

    Widget home;
    if (!session.initialized) {
      home = const SplashScreen();
    } else if (session.onboarded) {
      home = const HomeShell();
    } else {
      home = const OnboardingScreen();
    }

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      scrollBehavior: const RasaScrollBehavior(),
      navigatorKey: OneSignalService.navigatorKey,
      home: home,
    );
  }
}
