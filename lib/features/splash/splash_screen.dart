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
            const RasaLogo(size: 84),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConfig.tagline,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
