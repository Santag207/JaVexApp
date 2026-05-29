import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Fondos
  static const Color background = Color(0xFF0A0A0F);
  static const Color cardBackground = Color(0xFF1A1A2E);

  // Acentos
  static const Color primaryAccent = Color(0xFF00FFFF);
  static const Color secondaryAccent = Color(0xFFFFAA00);

  // Texto
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF888888);

  // Bordes
  static const Color border = Color(0xFF333344);

  // Funcionales
  static const Color error = Color(0xFFFF3366);
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);

  static Color glowCyan(double opacity) =>
      primaryAccent.withValues(alpha: opacity.clamp(0.0, 1.0));
}
