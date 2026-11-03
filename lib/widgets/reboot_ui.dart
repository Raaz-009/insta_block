import 'package:flutter/material.dart';

class RebootColors {
  static const bg = Color(0xFF0B0D14);
  static const panel = Color(0xFF151925);
  static const panel2 = Color(0xFF1B2030);
  static const purple = Color(0xFF9A8CFF);
  static const purpleDark = Color(0xFF6757D9);
  static const mint = Color(0xFFB9F3D1);
  static const text = Color(0xFFF4F3FA);
  static const muted = Color(0xFF9296A8);
  static const line = Color(0xFF292E3D);
  static const amber = Color(0xFFFFC979);
}

class RebootScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;
  const RebootScaffold({super.key, required this.child, this.appBar, this.safeArea = true});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: RebootColors.bg,
    appBar: appBar,
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF111422), RebootColors.bg, Color(0xFF0D111A)]),
      ),
      child: safeArea ? SafeArea(child: child) : child,
    ),
  );
}

class RebootCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Border? border;
  const RebootCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.color, this.border});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? RebootColors.panel,
      borderRadius: BorderRadius.circular(24),
      border: border ?? Border.all(color: RebootColors.line.withValues(alpha: .8)),
    ),
    child: child,
  );
}

class RebootPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const RebootPrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 58,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: RebootColors.purple,
        foregroundColor: const Color(0xFF10111A),
        disabledBackgroundColor: RebootColors.panel2,
        disabledForegroundColor: RebootColors.muted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: .1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 9)],
        Text(label),
      ]),
    ),
  );
}

class RebootEyebrow extends StatelessWidget {
  final String text;
  const RebootEyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(
    color: RebootColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5));
}

class RebootBackButton extends StatelessWidget {
  const RebootBackButton({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () => Navigator.maybePop(context),
    style: IconButton.styleFrom(backgroundColor: RebootColors.panel, foregroundColor: RebootColors.text),
    icon: const Icon(Icons.arrow_back_rounded),
  );
}

class RebootProgress extends StatelessWidget {
  final double value;
  const RebootProgress({super.key, required this.value});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 6,
      backgroundColor: Colors.white.withValues(alpha: .08),
      valueColor: const AlwaysStoppedAnimation(RebootColors.purple)),
  );
}
