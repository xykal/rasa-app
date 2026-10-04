import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/app_config.dart';
import '../../data/models/post_model.dart';

// ─── FONDASI ─────────────────────────────────────────────────────

/// Format waktu ala "5 menit lalu" (Indonesia, fallback Inggris).
String timeId(DateTime dt) {
  try {
    return timeago.format(dt, locale: 'id');
  } catch (_) {
    return timeago.format(dt);
  }
}

class RasaRadii {
  RasaRadii._();
  static const double card = 26;
  static const double sheet = 30;
  static const double field = 22;
  static const double button = 999;
  static const double tile = 18;
}

class RasaShadows {
  RasaShadows._();
  static List<BoxShadow> soft(ColorScheme s) => [
        BoxShadow(
          color: s.shadow.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
  static List<BoxShadow> glow(ColorScheme s) => [
        BoxShadow(
          color: s.primary.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

LinearGradient rasaGradient(ColorScheme s) => LinearGradient(
      colors: [s.primary, s.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

// ─── LOGO & LOADER ───────────────────────────────────────────────

/// Logo brand RASA — gradient + ikon, dipakai di mana-mana.
class RasaLogo extends StatelessWidget {
  final double size;
  const RasaLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: rasaGradient(scheme),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: RasaShadows.glow(scheme),
      ),
      child: Icon(
        Icons.spa,
        color: scheme.onPrimary,
        size: size * 0.55,
      ),
    );
  }
}

/// Loader khas RASA: logo berdenyut (pengganti spinner bawaan).
class RasaLoader extends StatefulWidget {
  final double size;
  final String? label;
  const RasaLoader({super.key, this.size = 56, this.label});

  @override
  State<RasaLoader> createState() => _RasaLoaderState();
}

class _RasaLoaderState extends State<RasaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Opacity(
              opacity: 0.65 + _c.value * 0.35,
              child: Transform.scale(
                scale: 0.92 + _c.value * 0.08,
                child: child,
              ),
            ),
            child: RasaLogo(size: widget.size),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 14),
            Text(
              widget.label!,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Titik-titik mengetik animasi (pengganti teks + spinner).
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(
                  alpha: 0.35 + 0.65 * (0.5 + 0.5 * _wave(i)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _wave(int i) {
    final t = (_c.value * 3 - i * 0.5).clamp(0.0, 1.0);
    return (t * 3.14159).clamp(-1.0, 1.0) >= 0
        ? (1 - (t * 2 - 1).abs())
        : 0;
  }
}

// ─── TOMBOL ──────────────────────────────────────────────────────

/// Tombol utama RASA: pil gradient + glow.
class RasaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool danger;
  final bool expanded;
  const RasaButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.busy = false,
    this.danger = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !busy;
    final gradient = danger
        ? const LinearGradient(colors: [Color(0xFFE5484D), Color(0xFFB4232A)])
        : rasaGradient(scheme);
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(RasaRadii.button),
          boxShadow: enabled ? RasaShadows.glow(scheme) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(RasaRadii.button),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: Row(
                mainAxisSize:
                    expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.onPrimary,
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: scheme.onPrimary),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol tonal: pil lembut tanpa gradient.
class RasaTonalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const RasaTonalButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(RasaRadii.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(RasaRadii.button),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: scheme.onSecondaryContainer),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol ghost: teks + ikon, tanpa latar.
class RasaGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const RasaGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
      ),
    );
  }
}

// ─── KARTU, FIELD, APPBAR ────────────────────────────────────────

/// Kartu khas RASA: radius besar + border halus + bayangan lembut.
class RasaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const RasaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RasaRadii.card),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: RasaShadows.soft(scheme),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RasaRadii.card),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Field teks khas RASA.
class RasaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  const RasaTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            prefix == null ? null : Icon(prefix, size: 22),
        suffixIcon: suffix,
      ),
    );
  }
}

/// AppBar khas RASA: tinggi lega + tombol kembali bulat custom.
class RasaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  final List<Widget>? actions;
  const RasaAppBar({
    super.key,
    required this.title,
    this.showLogo = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canPop = Navigator.canPop(context);
    return AppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12),
              child: Material(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_rounded, size: 22),
                ),
              ),
            )
          : null,
      leadingWidth: canPop ? 60 : 0,
      titleSpacing: canPop ? 2 : 18,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            const RasaLogo(size: 34),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [...?actions, const SizedBox(width: 10)],
    );
  }
}

/// Judul seksi kecil yang konsisten di semua layar.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ─── AVATAR & MOOD ───────────────────────────────────────────────

/// Avatar gradient dari inisial nama (warnanya stabil per nama).
class RasaAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const RasaAvatar({super.key, required this.name, this.radius = 22});

  static const _pairs = [
    [Color(0xFF6C4CF1), Color(0xFFB057C9)],
    [Color(0xFF0EA5A5), Color(0xFF34D399)],
    [Color(0xFFF76B15), Color(0xFFFFB59E)],
    [Color(0xFF3E63DD), Color(0xFF8EC8FF)],
    [Color(0xFFE5484D), Color(0xFFFF8C8C)],
    [Color(0xFF8E4EC6), Color(0xFF5B5BD6)],
  ];

  @override
  Widget build(BuildContext context) {
    final pair = _pairs[name.hashCode.abs() % _pairs.length];
    final initial = name.isEmpty ? 'R' : name.trim()[0].toUpperCase();
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [pair[0], pair[1]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: radius,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Avatar mood berwarna — konsisten di feed, detail, dan editor.
class MoodAvatar extends StatelessWidget {
  final String mood;
  final double radius;
  const MoodAvatar({super.key, required this.mood, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final m = moodOf(mood);
    return CircleAvatar(
      radius: radius,
      backgroundColor: m.color.withValues(alpha: 0.15),
      child: Icon(m.icon, color: m.color, size: radius * 1.1),
    );
  }
}

/// Chip pil khas RASA (pengganti ChoiceChip bawaan).
class RasaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final ValueChanged<bool> onSelected;
  const RasaChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RasaRadii.button),
          boxShadow: selected ? RasaShadows.glow(scheme) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: selected
                    ? scheme.onPrimary
                    : (iconColor ?? scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pilihan mood — dipakai di onboarding & editor cerita.
class MoodPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onPick;
  const MoodPicker({super.key, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final m in kMoods)
          RasaChip(
            icon: m.icon,
            iconColor: m.color,
            label: m.label,
            selected: selected == m.id,
            onSelected: (_) => onPick(m.id),
          ),
      ],
    );
  }
}

/// Tombol reaksi (Peluk / Sama) khas RASA.
class HugButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  const HugButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = active ? scheme.onPrimary : scheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? rasaGradient(scheme) : null,
          color: active ? null : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active ? RasaShadows.glow(scheme) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 7),
            Text(
              '$label  •  $count',
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── KARTU CERITA & FEED ─────────────────────────────────────────

/// Kartu cerita — dipakai di feed & profil.
class RasaPostCard extends StatelessWidget {
  final RasaPost post;
  final VoidCallback? onTap;
  final VoidCallback? onHug;
  final VoidCallback? onMeToo;
  final VoidCallback? onReport;
  const RasaPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onHug,
    this.onMeToo,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RasaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MoodAvatar(mood: post.mood),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.alias,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      timeId(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.aiReply != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: rasaGradient(scheme),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: scheme.onPrimary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Ditemani AI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              if (onReport != null)
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: onReport,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 13),
          Text(post.text, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HugButton(
                icon: Icons.volunteer_activism_rounded,
                label: 'Peluk',
                count: post.hugCount,
                active: post.hugged,
                onTap: onHug ?? () {},
              ),
              HugButton(
                icon: Icons.groups_rounded,
                label: 'Sama',
                count: post.meTooCount,
                active: post.meToo,
                onTap: onMeToo ?? () {},
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.replyCount} tanggapan',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu pertanyaan harian di atas feed.
class DailyQuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onAnswer;
  const DailyQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: rasaGradient(scheme),
        borderRadius: BorderRadius.circular(RasaRadii.card),
        boxShadow: RasaShadows.glow(scheme),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -45,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'PERTANYAAN HARI INI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onAnswer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                    child: Text(
                      'Jawab Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Status kosong khas RASA — ikon gradient + ajakan aksi.
class RasaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const RasaEmptyState({
    super.key,
    this.icon = Icons.forum_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: rasaGradient(scheme),
                shape: BoxShape.circle,
                boxShadow: RasaShadows.glow(scheme),
              ),
              child: Icon(icon, size: 38, color: scheme.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.6),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              RasaTonalButton(
                label: actionLabel!,
                icon: Icons.add_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── CHAT ────────────────────────────────────────────────────────

/// Gelembung chat konsisten (AI Teman & Biliar).
class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  final bool highlight;
  const ChatBubble({
    super.key,
    required this.text,
    required this.mine,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = mine
        ? null
        : (highlight ? scheme.tertiaryContainer : scheme.surfaceContainerHigh);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          gradient: mine ? rasaGradient(scheme) : null,
          color: bg,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight:
                mine ? const Radius.circular(6) : const Radius.circular(20),
            bottomLeft:
                mine ? const Radius.circular(20) : const Radius.circular(6),
          ),
          border: highlight
              ? Border.all(color: scheme.tertiary.withValues(alpha: 0.5))
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            height: 1.5,
            color: mine
                ? scheme.onPrimary
                : (highlight
                    ? scheme.onTertiaryContainer
                    : scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Baris komposer chat khas RASA (field + tombol kirim gradient).
class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;
  const ChatComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: RasaTextField(
                controller: controller,
                hint: hint,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: rasaGradient(scheme),
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: RasaShadows.glow(scheme),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: scheme.onPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PILIHAN & PENGATURAN ────────────────────────────────────────

class RasaSegment<T> {
  final T value;
  final IconData icon;
  final String label;
  const RasaSegment({
    required this.value,
    required this.icon,
    required this.label,
  });
}

/// Segmented control khas RASA (pengganti SegmentedButton bawaan).
class RasaSegmented<T> extends StatelessWidget {
  final List<RasaSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  const RasaSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final s in segments)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(s.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient:
                        s.value == value ? rasaGradient(scheme) : null,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow:
                        s.value == value ? RasaShadows.glow(scheme) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        s.icon,
                        size: 17,
                        color: s.value == value
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: s.value == value
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Toggle khas RASA (pengganti Switch bawaan).
class RasaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const RasaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 31,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value ? rasaGradient(scheme) : null,
          color: value ? null : scheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? Icons.check_rounded : Icons.close_rounded,
              size: 15,
              color: value ? scheme.primary : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris pengaturan khas RASA.
class RasaSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const RasaSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = danger ? const Color(0xFFE5484D) : scheme.onSurface;
    return RasaCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: danger
                  ? const Color(0xFFE5484D).withValues(alpha: 0.12)
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: danger ? const Color(0xFFE5484D) : scheme.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, color: fg),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ] else if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

/// Badge kecil: streak, demo, dsb.
class RasaMiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const RasaMiniBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── DIALOG, SHEET, SNACKBAR ─────────────────────────────────────

Future<T?> showRasaDialog<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  Widget? content,
  required List<Widget> actions,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: rasaGradient(scheme),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.onPrimary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            if (content != null) ...[
              const SizedBox(height: 16),
              content,
            ],
            const SizedBox(height: 20),
            Row(children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: actions[i]),
              ],
            ]),
          ],
        ),
      ),
    ),
  );
}

/// Dialog konfirmasi hapus yang standar di seluruh aplikasi.
Future<bool> confirmDelete(BuildContext context, String message) async {
  final res = await showRasaDialog<bool>(
    context,
    icon: Icons.delete_outline_rounded,
    title: 'Hapus?',
    message: message,
    actions: [
      RasaTonalButton(
        label: 'Batal',
        onPressed: () => Navigator.pop(context, false),
      ),
      RasaButton(
        label: 'Hapus',
        danger: true,
        onPressed: () => Navigator.pop(context, true),
      ),
    ],
  );
  return res ?? false;
}

Future<T?> showRasaSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: child,
      ),
    ),
  );
}

/// Bottom sheet lapor konten (masuk ke koleksi reports buat dimoderasi admin).
Future<void> showReportSheet(BuildContext context, String postId) {
  final scheme = Theme.of(context).colorScheme;
  return showRasaSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.flag_outlined, color: scheme.primary),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporkan cerita ini?',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tim moderasi akan meninjau dalam 1x24 jam.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final r in kReportReasons)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.pop(context);
                  RasaSnack.show(
                    context,
                    'Terima kasih. Laporanmu akan kami tinjau.',
                    icon: Icons.flag_rounded,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Snackbar khas RASA: ikon + pesan, selalu floating.
class RasaSnack {
  RasaSnack._();
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
  }) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: scheme.inversePrimary, size: 22),
              const SizedBox(width: 11),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

// ─── BOTTOM BAR ──────────────────────────────────────────────────

class _BarItem {
  final IconData icon;
  final String label;
  const _BarItem(this.icon, this.label);
}

/// Bottom bar total custom (pengganti NavigationBar bawaan).
class RasaBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const RasaBottomBar({super.key, required this.index, required this.onTap});

  static const _items = [
    _BarItem(Icons.home_rounded, 'Beranda'),
    _BarItem(Icons.auto_awesome_rounded, 'AI Teman'),
    _BarItem(Icons.add_rounded, 'Curhat'),
    _BarItem(Icons.casino_rounded, 'Biliar'),
    _BarItem(Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: RasaShadows.soft(scheme),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              if (i == 2)
                _BarCenter(onTap: () => onTap(2))
              else
                Expanded(
                  child: _BarEntry(
                    item: _items[i],
                    selected: index == i,
                    onTap: () => onTap(i),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BarEntry extends StatelessWidget {
  final _BarItem item;
  final bool selected;
  final VoidCallback onTap;
  const _BarEntry({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? rasaGradient(scheme) : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected ? RasaShadows.glow(scheme) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            if (selected) ...[
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarCenter extends StatelessWidget {
  final VoidCallback onTap;
  const _BarCenter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: rasaGradient(scheme),
          shape: BoxShape.circle,
          boxShadow: RasaShadows.glow(scheme),
        ),
        child: Icon(Icons.add_rounded, color: scheme.onPrimary, size: 30),
      ),
    );
  }
}
