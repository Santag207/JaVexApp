import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

/// Título tipo "holograma": texto en fuente arcade con color cyan que aparece
/// y se oculta en bucle (oscila la opacidad) con un leve brillo y flotación,
/// simulando una proyección holográfica.
class HologramText extends StatelessWidget {
  const HologramText(
    this.text, {
    super.key,
    this.size = 16,
    this.color = AppColors.primaryAccent,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double size;
  final Color color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final glow = color.withValues(alpha: 0.6);

    final content = Text(
      text,
      textAlign: textAlign,
      style: AppTheme.arcade(size: size, color: color).copyWith(
        shadows: [
          Shadow(color: glow, blurRadius: 12),
          Shadow(color: glow, blurRadius: 24),
        ],
      ),
    );

    // Bucle: aparece y se oculta (reverse) con shimmer y una leve flotación.
    return content
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(
          begin: 0.35,
          end: 1.0,
          duration: 1400.ms,
          curve: Curves.easeInOut,
        )
        .shimmer(
          duration: 1400.ms,
          color: AppColors.glowWhite(0.7),
        )
        .moveY(begin: 1.5, end: -1.5, duration: 1400.ms, curve: Curves.easeInOut);
  }
}
