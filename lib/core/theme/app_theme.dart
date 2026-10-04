import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// RASA Flat v2 — design system solid, tenang, premium.
/// Satu warna brand + satu warna AI. Tanpa gradasi, tanpa glow neon.
/// Palet adaptif penuh: tiap warna punya pasangan terang & gelap.
class AppTheme {
  AppTheme._();

  // Brand: violet tenang (solid, tidak neon).
  static const _brand = Color(0xFF5A3EE6);
  static const _brandDark = Color(0xFFA89BFF);
  // Warna kedua: hijau AI — hanya untuk hal berbau AI.
  static const _ai = Color(0xFF2E9E66);
  static const _aiDark = Color(0xFF7BD3A2);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _brand,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE5DEFF),
      onPrimaryContainer: Color(0xFF27156F),
      secondary: Color(0xFF5B576B),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE3E0EB),
      onSecondaryContainer: Color(0xFF1C1A24),
      tertiary: _ai,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCBEDD9),
      onTertiaryContainer: Color(0xFF0A3B23),
      error: Color(0xFFD64545),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: Color(0xFFFBFAFE),
      onSurface: Color(0xFF191823),
      onSurfaceVariant: Color(0xFF54546A),
      outline: Color(0xFF7A7590),
      outlineVariant: Color(0xFFC9C5D6),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF3F1F8),
      surfaceContainer: Color(0xFFECEAF2),
      surfaceContainerHigh: Color(0xFFE6E3EC),
      surfaceContainerHighest: Color(0xFFE0DDE6),
      inverseSurface: Color(0xFF23222E),
      onInverseSurface: Color(0xFFF4F2FA),
      surfaceTint: _brand,
      scrim: Colors.black,
    );
    return _build(scheme);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _brandDark,
      onPrimary: Color(0xFF27156F),
      primaryContainer: Color(0xFF3A2A7D),
      onPrimaryContainer: Color(0xFFE5DEFF),
      secondary: Color(0xFFC9C5D8),
      onSecondary: Color(0xFF2E2B3D),
      secondaryContainer: Color(0xFF44415A),
      onSecondaryContainer: Color(0xFFE8E4F2),
      tertiary: _aiDark,
      onTertiary: Color(0xFF06301B),
      tertiaryContainer: Color(0xFF0E3B24),
      onTertiaryContainer: Color(0xFFCBEDD9),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF12111A),
      onSurface: Color(0xFFE7E4F0),
      onSurfaceVariant: Color(0xFFA5A1B8),
      outline: Color(0xFF8E8A9E),
      outlineVariant: Color(0xFF484554),
      surfaceContainerLowest: Color(0xFF0C0B12),
      surfaceContainerLow: Color(0xFF171622),
      surfaceContainer: Color(0xFF1C1B27),
      surfaceContainerHigh: Color(0xFF26252F),
      surfaceContainerHighest: Color(0xFF302F3B),
      inverseSurface: Color(0xFFE7E4F0),
      onInverseSurface: Color(0xFF1B1A24),
      surfaceTint: _brandDark,
      scrim: Colors.black,
    );
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Font custom yang dibundel di assets/fonts.
      fontFamily: 'PlusJakartaSans',
      // Ikon status bar & nav bar ikut tema (edge-to-edge dari main.dart).
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              dark ? Brightness.light : Brightness.dark,
        ),
      ),
      // Splash tekan custom (lembut, tidak kotak).
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
      // Transisi halaman khas RASA: fade + slide pendek.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _RasaPageTransition(),
          TargetPlatform.iOS: _RasaPageTransition(),
          TargetPlatform.macOS: _RasaPageTransition(),
          TargetPlatform.windows: _RasaPageTransition(),
          TargetPlatform.linux: _RasaPageTransition(),
          TargetPlatform.fuchsia: _RasaPageTransition(),
        },
      ),
      // Kartu bawaan (fallback) ikut bahasa bentuk RASA.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      // Ketebalan teks CMaterial bawaan (fallback kalau widget custom
      // tidak dipakai di suatu tempat).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
    );
  }
}

/// Transisi fade + slide 260ms — terasa mulus di 60Hz maupun 120Hz.
class _RasaPageTransition extends PageTransitionsBuilder {
  const _RasaPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Scroll khas RASA: memantul lembut, tanpa glow biru Android.
class RasaScrollBehavior extends ScrollBehavior {
  const RasaScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // glow biru dimatikan
  }
}
