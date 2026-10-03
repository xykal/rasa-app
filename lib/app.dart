import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_providers.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

class RasaApp extends ConsumerWidget {
  const RasaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: session.onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
