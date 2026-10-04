import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';

/// Splash screen branded — tampil sebentar saat session dimuat.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RasaLoader(size: 88),
            const SizedBox(height: 22),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: 7,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConfig.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
