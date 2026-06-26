import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.success,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outline,
    ),
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surfaceLight,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
          displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.45,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
          labelMedium: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.06),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.outline.withValues(alpha: 0.45),
      thickness: 1,
      space: 20,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.accentSoft.withValues(alpha: 0.45),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.accent : AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.accent : AppColors.textSecondary,
          size: 24,
        );
      }),
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}

ThemeData buildDarkAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2DD4BF),
      onPrimary: Color(0xFF042F2E),
      secondary: Color(0xFF34D399),
      surface: Color(0xFF1A2332),
      onSurface: Color(0xFFF1F5F9),
      outline: Color(0xFF334155),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0B1120),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
      ),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: const Color(0xFFF1F5F9),
      displayColor: const Color(0xFFF1F5F9),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A2332),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: Colors.black.withValues(alpha: 0.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 20,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF2DD4BF),
      foregroundColor: const Color(0xFF042F2E),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF111827),
      indicatorColor: const Color(0xFF2DD4BF).withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? const Color(0xFF5EEAD4) : const Color(0xFF94A3B8),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? const Color(0xFF5EEAD4) : const Color(0xFF94A3B8),
          size: 24,
        );
      }),
      height: 72,
    ),
  );
}
