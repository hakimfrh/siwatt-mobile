import 'package:flutter/material.dart';
import 'siwatt_colors.dart';

ThemeData siwattTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: "Poppins",
    scaffoldBackgroundColor: SiwattColors.background,
    primaryColor: SiwattColors.primary,

    colorScheme: ColorScheme.light(
      primary: SiwattColors.primary,
      secondary: SiwattColors.accentWarning,
      surface: SiwattColors.background,
      error: SiwattColors.accentDanger,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: SiwattColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SiwattColors.input,
      isDense: true,
      // Use minHeight (not tight height) so when error text appears
      // the field won't get compressed.
      constraints: const BoxConstraints(minHeight: 48),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SiwattColors.accentDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SiwattColors.accentDanger),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      errorStyle: const TextStyle(
        color: SiwattColors.accentDanger,
        fontSize: 12,
        height: 1.1,
      ),
      hintStyle: const TextStyle(
        color: SiwattColors.textDisabled,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SiwattColors.accentWarning,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SiwattColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: SiwattColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: SiwattColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: SiwattColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: SiwattColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: SiwattColors.textSecondary,
      ),
    ),
  );
}
