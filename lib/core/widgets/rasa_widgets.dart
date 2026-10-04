import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/post_model.dart';

/// ============================================================
/// RASA Flat v2 — seluruh komponen UI custom.
/// Solid 1 warna brand + 1 warna AI. Tanpa gradasi, tanpa glow.
/// Micro-interaction: press-scale + haptic di semua yang bisa ditekan.
/// Animasi dibungkus RepaintBoundary supaya mulus di 120Hz.
/// ============================================================

// ---------- Radius & shadow tunggal ----------

class RasaRadii {
  RasaRadii._();
  static const double card = 26;
  static const double sheet = 30;
  static const double dialog = 28;
  static const double field = 20;
  static const double button = 999;
  static const double tile = 18;
}

class RasaShadows {
  RasaShadows._();

  /// Shadow netral, blur kecil → murah di GPU, tidak bikin ngelag.
  static List<BoxShadow> soft(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.07),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ];
  }

  /// Shadow timbul untuk tombol utama — solid, bukan glow neon.
  static List<BoxShadow> pop(ColorScheme s) => [
        BoxShadow(
          color: s.primary.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// ---------- Micro-interaction: memencet saat ditekan ----------

/// Membungkus widget agar menyusut sedikit saat jari menempel.
/// Dipakai di semua tombol, chip, dan ikon yang bisa ditekan.
class _PressScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const _PressScale({required this.child, this.enabled = true});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        if (widget.enabled) setState(() => _down = true);
      },
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down && widget.enabled ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ---------- Logo ----------

/// Logo RASA: kotak solid warna brand + huruf R tebal.
class RasaLogo extends StatelessWidget {
  final double size;
  const RasaLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: RasaShadows.pop(scheme),
      ),
      child: Center(
        child: Text(
          'R',
          style: TextStyle(
            fontSize: size * 0.52,
            fontWeight: FontWeight.w800,
            color: scheme.onPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ---------- Loading ----------

/// Loader khas RASA: logo berdenyut + titik mengetik.
class RasaLoader extends StatefulWidget {
  final String? label;
  final double size;
  const RasaLoader({super.key, this.label, this.size = 84});

  @override
  State<RasaLoader> createState() => _RasaLoaderState();
}

class _RasaLoaderState extends State<RasaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + (_c.value * 0.07),
                child: Opacity(
                  opacity: 0.88 + (_c.value * 0.12),
                  child: RasaLogo(size: widget.size),
                ),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 18),
              Text(
                widget.label!,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const TypingDots(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tiga titik mengetik khas aplikasi chat.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_c.value * 3) - i).clamp(0.0, 1.0);
            final bounce = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8 - (bounce * 2.5),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.45 + bounce * 0.55),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------- Skeleton shimmer ----------

/// Placeholder shimmer selagi konten dimuat — terasa jauh lebih cepat
/// daripada spinner, dan jadi bahasa loading utama RASA.
class RasaSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;
  const RasaSkeleton({
    super.key,
    required this.height,
    this.width,
    this.radius = 14,
  });

  @override
  State<RasaSkeleton> createState() => _RasaSkeletonState();
}

class _RasaSkeletonState extends State<RasaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final highlight = dark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.6);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          height: widget.height,
          width: widget.width,
          color: scheme.surfaceContainerHighest,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => LayoutBuilder(
              builder: (_, bc) {
                final w = bc.maxWidth.isFinite ? bc.maxWidth : 300.0;
                final x = -w * 0.6 + (_c.value * w * 1.6);
                return Stack(
                  children: [
                    Positioned(
                      left: x,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: w * 0.6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              highlight,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Judul seksi ----------

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

// ---------- Tombol ----------

/// Tombol utama: solid warna brand, memencet + getar saat ditekan.
class RasaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  const RasaButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !busy;
    return _PressScale(
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Material(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(RasaRadii.button),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(RasaRadii.button),
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RasaRadii.button),
                boxShadow:
                    enabled ? RasaShadows.pop(scheme) : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Center(
                child: busy
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: scheme.onPrimary,
                            ),
                          ),
                          if (icon != null) ...[
                            const SizedBox(width: 9),
                            Icon(icon,
                                size: 20, color: scheme.onPrimary),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol kedua: latar lembut, teks warna brand.
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
    return _PressScale(
      enabled: onPressed != null,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(RasaRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(RasaRadii.button),
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: scheme.primary),
                  const SizedBox(width: 9),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol teks: tanpa latar, untuk aksi sekunder.
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
    return _PressScale(
      enabled: onPressed != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RasaRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(RasaRadii.button),
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: onPressed == null
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Kartu & field ----------

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
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(RasaRadii.card),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(RasaRadii.card),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RasaRadii.card),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: RasaShadows.soft(scheme),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Kolom ketik khas RASA: sudut besar, fokus bergaris brand.
class RasaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefix;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  const RasaTextField({
    super.key,
    this.controller,
    this.hint = '',
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(color: scheme.onSurface, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        prefixIcon:
            prefix == null ? null : Icon(prefix, color: scheme.primary),
        suffixIcon: suffix,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RasaRadii.field),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RasaRadii.field),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}

// ---------- AppBar ----------

/// AppBar khas RASA: logo + judul, tombol kembali bulat.
class RasaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  final List<Widget> actions;
  const RasaAppBar({
    super.key,
    required this.title,
    this.showLogo = false,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          if (canPop && !showLogo)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _PressScale(
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showLogo) ...[
            const RasaLogo(size: 36),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
        if (actions.isNotEmpty) const SizedBox(width: 10),
      ],
    );
  }
}

/// Badge kecil untuk appbar (streak, timer, status).
class RasaMiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const RasaMiniBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Chip & mood ----------

/// Chip pil khas RASA. Ikon selalu berwarna biar hidup.
class RasaChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  const RasaChip({
    super.key,
    required this.icon,
    this.iconColor,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelected(!selected);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RasaRadii.button),
            border: selected
                ? null
                : Border.all(color: scheme.outlineVariant),
            boxShadow: selected ? RasaShadows.pop(scheme) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? scheme.onPrimary
                    : (iconColor ?? scheme.primary),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: selected
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data mood: id, label, ikon Material, warna solid.
class MoodInfo {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const MoodInfo(this.id, this.label, this.icon, this.color);
}

const kMoods = [
  MoodInfo('senang', 'Senang', Icons.sentiment_very_satisfied_rounded,
      Color(0xFFE39B2D)),
  MoodInfo('sedih', 'Sedih', Icons.sentiment_dissatisfied_rounded,
      Color(0xFF4C7DE0)),
  MoodInfo('marah', 'Marah', Icons.sentiment_very_dissatisfied_rounded,
      Color(0xFFDE5A5A)),
  MoodInfo('tenang', 'Tenang', Icons.spa_rounded, Color(0xFF35A06F)),
  MoodInfo('lelah', 'Lelah', Icons.bedtime_rounded, Color(0xFF8E93A6)),
  MoodInfo('flat', 'Biasa', Icons.sentiment_neutral_rounded,
      Color(0xFF8E93A6)),
];

MoodInfo moodOf(String id) =>
    kMoods.firstWhere((m) => m.id == id, orElse: () => kMoods.last);

/// Avatar lingkaran solid warna mood + ikon putih.
class MoodAvatar extends StatelessWidget {
  final String mood;
  final double radius;
  const MoodAvatar({super.key, required this.mood, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final m = moodOf(mood);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: m.color,
        shape: BoxShape.circle,
      ),
      child: Icon(m.icon, color: Colors.white, size: radius * 1.15),
    );
  }
}

/// Pemilih mood: baris ikon yang membesar saat dipilih.
class MoodPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onPick;
  const MoodPicker({super.key, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final m in kMoods)
          _PressScale(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onPick(m.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: selected == m.id ? 16 : 13,
                  vertical: selected == m.id ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  color: selected == m.id
                      ? m.color.withValues(alpha: 0.16)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RasaRadii.button),
                  border: Border.all(
                    color: selected == m.id
                        ? m.color
                        : scheme.outlineVariant,
                    width: selected == m.id ? 2 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.icon, size: 20, color: m.color),
                    const SizedBox(width: 7),
                    Text(
                      m.label,
                      style: TextStyle(
                        fontWeight: selected == m.id
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 13.5,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------- Avatar anonim ----------

/// Avatar huruf: lingkaran lembut + inisial warna brand.
class RasaAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const RasaAvatar({super.key, required this.name, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ch = name.trim().isEmpty ? 'R' : name.trim()[0].toUpperCase();
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          ch,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.95,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}

// ---------- Kartu cerita ----------

/// Kartu cerita di feed: header mood → isi → tombol peluk & aku-juga.
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
    final mood = moodOf(post.mood);
    return RasaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MoodAvatar(mood: post.mood, radius: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.alias,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    Text(
                      '${mood.label} • ${timeId(post.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: mood.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mood.icon, size: 14, color: mood.color),
                    const SizedBox(width: 5),
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: mood.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14.5, height: 1.55),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _ReactButton(
                icon: Icons.volunteer_activism_rounded,
                label: 'Peluk ${post.hugCount}',
                active: post.huggedByMe,
                onTap: onHug,
              ),
              const SizedBox(width: 9),
              _ReactButton(
                icon: Icons.group_outlined,
                label: 'Aku juga ${post.meTooCount}',
                active: post.meTooByMe,
                onTap: onMeToo,
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 17,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${post.replyCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (onReport != null) ...[
                const SizedBox(width: 4),
                _PressScale(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onReport!();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_horiz_rounded,
                        size: 21,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _ReactButton({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PressScale(
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: active
                ? null
                : Border.all(color: scheme.outlineVariant),
            boxShadow: active ? RasaShadows.pop(scheme) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: active
                    ? scheme.onPrimary
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Kartu pertanyaan harian ----------

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
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(RasaRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: scheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                'Pertanyaan hari ini',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.45,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          _PressScale(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAnswer();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: RasaShadows.pop(scheme),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Jawab sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: scheme.onPrimary,
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

// ---------- Chat ----------

/// Gelembung chat: milikku solid brand kanan, lawan abu kiri.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  const ChatBubble({super.key, required this.text, required this.mine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: mine ? 52 : 0,
          right: mine ? 0 : 52,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: mine ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: mine
                ? const Radius.circular(6)
                : const Radius.circular(20),
            bottomLeft: mine
                ? const Radius.circular(20)
                : const Radius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            height: 1.5,
            fontSize: 14.5,
            color: mine ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Kolom ketik chat + tombol kirim lingkaran solid.
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
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    HapticFeedback.lightImpact();
                    onSend();
                  },
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        TextStyle(color: scheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            _PressScale(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSend();
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: RasaShadows.pop(scheme),
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: scheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Segmented & switch & setting ----------

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

/// Pilihan segmen (mis. tema Terang/Auto/Gelap).
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (final s in segments)
            Expanded(
              child: _PressScale(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(s.value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: s.value == value
                          ? scheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: s.value == value
                          ? RasaShadows.pop(scheme)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          s.icon,
                          size: 18,
                          color: s.value == value
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: s.value == value
                                ? scheme.onPrimary
                                : scheme.onSurface,
                          ),
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
}

/// Switch geser khas RASA.
class RasaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const RasaSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PressScale(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 54,
          height: 32,
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            color: value
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: value
                ? null
                : Border.all(color: scheme.outlineVariant),
          ),
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: value ? scheme.onPrimary : scheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: value
                ? Icon(Icons.check_rounded,
                    size: 16, color: scheme.primary)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Baris pengaturan: ikon + judul + aksi kanan.
class RasaSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const RasaSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dangerColor = scheme.brightness == Brightness.dark
        ? scheme.error
        : const Color(0xFFD64545);
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(RasaRadii.tile),
      child: InkWell(
        borderRadius: BorderRadius.circular(RasaRadii.tile),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RasaRadii.tile),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: danger
                      ? dangerColor.withValues(alpha: 0.12)
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: danger ? dangerColor : scheme.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: danger ? dangerColor : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
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
        ),
      ),
    );
  }
}

// ---------- Dialog, sheet, snackbar ----------

/// Dialog khas RASA: ikon, judul, pesan, konten opsional, tombol.
Future<T?> showRasaDialog<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  Widget? content,
  required List<Widget> actions,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 230),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, __, ____) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: AlertDialog(
            backgroundColor: scheme.surfaceContainerLow,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RasaRadii.dialog),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(icon, size: 28, color: scheme.primary),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 9),
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
                Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Dialog konfirmasi hapus (merah).
Future<bool> confirmDelete(BuildContext context, String message) async {
  final scheme = Theme.of(context).colorScheme;
  final danger = scheme.brightness == Brightness.dark
      ? scheme.error
      : const Color(0xFFD64545);
  final ok = await showRasaDialog<bool>(
    context,
    icon: Icons.delete_outline_rounded,
    title: 'Hapus?',
    message: message,
    actions: [
      RasaTonalButton(
        label: 'Batal',
        onPressed: () => Navigator.pop(context, false),
      ),
      _DangerButton(
        label: 'Hapus',
        color: danger,
        onPressed: () => Navigator.pop(context, true),
      ),
    ],
  );
  return ok ?? false;
}

class _DangerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _DangerButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(RasaRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(RasaRadii.button),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet khas RASA: gagang, judul, isi.
Future<T?> showRasaSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: scheme.surfaceContainerLow,
    elevation: 0,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Sheet pilih alasan laporan.
void showReportSheet(BuildContext context, String postId) {
  const reasons = [
    (Icons.bullying_outlined, 'Perundungan / kasar'),
    (Icons.privacy_tip_outlined, 'Bocorkan privasi'),
    (Icons.campaign_outlined, 'Spam / promosi'),
    (Icons.warning_amber_rounded, 'Konten berbahaya'),
  ];
  showRasaSheet(
    context,
    title: 'Laporkan cerita ini?',
    child: Column(
      children: [
        for (final r in reasons)
          Builder(builder: (ctx) {
            final scheme = Theme.of(ctx).colorScheme;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _PressScale(
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RasaRadii.tile),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(RasaRadii.tile),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      RasaSnack.show(
                        context,
                        'Terima kasih. Laporanmu membantu menjaga RASA tetap aman.',
                        icon: Icons.check_circle_rounded,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(r.$1,
                              size: 22, color: scheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            r.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    ),
  );
}

/// Snackbar khas RASA: pil adaptif terang/gelap + ikon.
class RasaSnack {
  RasaSnack._();

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
  }) {
    final scheme = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: scheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin:
              const EdgeInsets.fromLTRB(18, 0, 18, 110),
          content: Row(
            children: [
              Icon(icon, color: scheme.inversePrimary, size: 22),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

// ---------- Status kosong ----------

class RasaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const RasaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, size: 44, color: scheme.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            RasaButton(
              label: actionLabel!,
              icon: Icons.add_rounded,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- Bottom bar ----------

/// Bottom bar khas RASA: 5 slot, tombol + solid mengambang di tengah.
class RasaBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const RasaBottomBar({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Beranda'),
    (Icons.auto_awesome_rounded, 'AI'),
    (Icons.add_rounded, ''),
    (Icons.casino_rounded, 'Biliar'),
    (Icons.person_rounded, 'Saya'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: RasaShadows.soft(scheme),
          ),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                if (i == 2)
                  Expanded(
                    child: Center(
                      child: _PressScale(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap(i);
                          },
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: RasaShadows.pop(scheme),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 30,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _PressScale(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17, vertical: 7),
                              decoration: BoxDecoration(
                                color: index == i
                                    ? scheme.primaryContainer
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(999),
                              ),
                              child: Icon(
                                _items[i].$1,
                                size: 23,
                                color: index == i
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _items[i].$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: index == i
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: index == i
                                    ? scheme.primary
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
        ),
      ),
    );
  }
}

// ---------- Util ----------

/// Format waktu Bahasa Indonesia ("5 mnt lalu").
String timeId(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
  if (d.inHours < 24) return '${d.inHours} jam lalu';
  if (d.inDays < 7) return '${d.inDays} hari lalu';
  return '${t.day}/${t.month}/${t.year}';
}
