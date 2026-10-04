import 'package:flutter/material.dart';

import '../../core/widgets/rasa_widgets.dart';
import '../ai/ai_chat_screen.dart';
import '../chat/biliar_chat_screen.dart';
import '../feed/feed_screen.dart';
import '../post/create_post_screen.dart';
import '../profile/profile_screen.dart';

/// Navigasi utama dengan bottom bar total custom.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    FeedScreen(),
    AiChatScreen(),
    SizedBox.shrink(), // slot tombol +
    BiliarChatScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    if (i == 2) {
      // Tombol tengah → buka editor cerita
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreatePostScreen()),
      );
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index == 2 ? 0 : _index, children: _pages),
      bottomNavigationBar: RasaBottomBar(index: _index, onTap: _onTap),
      extendBody: true,
    );
  }
}
