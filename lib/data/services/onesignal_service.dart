import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../core/config/app_config.dart';
import '../../features/post/post_detail_screen.dart';

/// Push notification via OneSignal.
///
/// - App ID dari --dart-define=ONESIGNAL_APP_ID (lihat AppConfig + SETUP.md).
/// - Kosong = SDK tidak diinit, app tetap jalan normal (aman buat demo/build).
/// - Semua pemanggilan dibungkus try/catch → tidak pernah crash gara-gara push.
/// - Pengiriman push dilakukan SERVER (notify-worker/), bukan dari aplikasi.
class OneSignalService {
  OneSignalService._();

  /// Dipakai MaterialApp biar notif bisa buka halaman dari background.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _ready = false;
  static bool get enabled => AppConfig.oneSignalAppId.isNotEmpty;

  static Future<void> init() async {
    if (!enabled || _ready) return;
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.none);
      OneSignal.initialize(AppConfig.oneSignalAppId);

      // Tetap tampilkan banner walau app sedang dibuka.
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });

      // Klik notif → langsung buka cerita terkait.
      OneSignal.Notifications.addClickListener((event) {
        final postId =
            event.notification.additionalData?['postId']?.toString() ?? '';
        if (postId.isNotEmpty) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: postId)),
          );
        }
      });

      _ready = true;
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('OneSignal permission: $granted');
    } catch (e) {
      debugPrint('OneSignal init dilewati: $e');
    }
  }

  /// Daftarkan user anonim sebagai external_id + tag alias.
  /// Dipanggil otomatis dari app.dart saat session siap.
  static Future<void> login(String userId, String alias) async {
    if (!enabled || !_ready) return;
    try {
      await OneSignal.login(userId);
      OneSignal.User.addTags({'alias': alias});
    } catch (e) {
      debugPrint('OneSignal login dilewati: $e');
    }
  }

  static Future<void> logout() async {
    if (!enabled || !_ready) return;
    try {
      await OneSignal.logout();
    } catch (_) {}
  }
}
