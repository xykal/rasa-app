import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';

/// Entry point RASA.
/// - Firebase init dibungkus try/catch → app TETAP jalan walau belum setup.
/// - Default DEMO_MODE=true → langsung bisa dicoba buyer tanpa config apa pun.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Belum ada google-services.json / belum setup → jalan mode demo lokal.
    debugPrint('Firebase belum dikonfigurasi, berjalan dalam mode demo.');
  }

  try {
    timeago.setLocaleMessages('id', timeago.IdMessages());
  } catch (_) {}

  runApp(const ProviderScope(child: RasaApp()));
}
