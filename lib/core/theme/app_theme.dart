import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Radios alineados al web: 4 para botones/inputs, 8 para cards.
  static const double radiusSmall = 4;
  static const double radiusCard = 8;

  static TextStyle _orbitron({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = 1.5,
  }) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle _montserrat({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.montserrat(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle _robotoMono({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textSecondary,
    double letterSpacing = 0.5,
  }) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    final textTheme = TextTheme(
      displayLarge: _orbitron(size: 32, letterSpacing: 2),
      displayMedium: _orbitron(size: 24),
      displaySmall: _orbitron(size: 20),
      headlineMedium: _orbitron(size: 18),
      titleLarge: _orbitron(size: 16, weight: FontWeight.w700, letterSpacing: 1.2),
      bodyLarge: _montserrat(size: 16),
      bodyMedium: _montserrat(size: 14),
      bodySmall: _montserrat(size: 12, color: AppColors.textSecondary),
      labelLarge: _robotoMono(size: 14, color: AppColors.textPrimary),
      labelMedium: _robotoMono(size: 12),
      labelSmall: _robotoMono(size: 11),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.primaryAccent,
      canvasColor: Colors.transparent,
      dividerColor: AppColors.border,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.background,
        secondary: AppColors.secondaryAccent,
        onSecondary: AppColors.background,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _orbitron(size: 20, letterSpacing: 2),
        iconTheme: const IconThemeData(color: AppColors.primaryAccent),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.background,
          textStyle: _robotoMono(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.background,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryAccent,
          side: const BorderSide(color: AppColors.secondaryAccent),
          textStyle: _robotoMono(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.secondaryAccent,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          textStyle: _robotoMono(
            size: 13,
            weight: FontWeight.w400,
            color: AppColors.primaryAccent,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        labelStyle: _robotoMono(size: 12, color: AppColors.textSecondary),
        hintStyle: _montserrat(size: 14, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryAccent),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryAccent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBackground,
        contentTextStyle: _montserrat(size: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          side: const BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
