import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.glow = false,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool glow;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final isDanger = variant == AppButtonVariant.danger;
    final isGhost = variant == AppButtonVariant.ghost;

    final Color background;
    final Color foreground;
    final Color borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        background = AppColors.primaryAccent;
        foreground = AppColors.background;
        borderColor = AppColors.primaryAccent;
        break;
      case AppButtonVariant.secondary:
        background = Colors.transparent;
        foreground = AppColors.secondaryAccent;
        borderColor = AppColors.secondaryAccent;
        break;
      case AppButtonVariant.ghost:
        background = Colors.transparent;
        foreground = AppColors.primaryAccent;
        borderColor = AppColors.border;
        break;
      case AppButtonVariant.danger:
        background = Colors.transparent;
        foreground = AppColors.error;
        borderColor = AppColors.error;
        break;
    }

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
        ],
        if (!loading)
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'monospace',
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
      ],
    );

    final button = Material(
      color: background,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: child,
        ),
      ),
    );

    final wrapped = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        boxShadow: glow && (isPrimary || isDanger || isGhost)
            ? [
                BoxShadow(
                  color: isDanger
                      ? AppColors.error.withValues(alpha: 0.35)
                      : AppColors.glowCyan(0.35),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: button,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: wrapped) : wrapped;
  }
}
