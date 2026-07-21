import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color gradientStart = Color(0xFFFF8FC7);
  static const Color gradientMid = Color(0xFFC08CFF);
  static const Color gradientEnd = Color(0xFF7C4DFF);

  static const Color background = Color(0xFFFBF7FF);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF2D1B4E);
  static const Color textMuted = Color(0xFF9C90B5);
  static const Color chipUnselected = Color(0xFFF1E9FF);

  static const Color yellow = Color(0xFFFFD166);
  static const Color yellowSoft = Color(0xFFFFF3D6);
  static const Color mint = Color(0xFF4ECDC4);
  static const Color mintSoft = Color(0xFFD7F5F2);
  static const Color coral = Color(0xFFFF6F91);
  static const Color coralSoft = Color(0xFFFFE1E8);
  static const Color sky = Color(0xFF5FA8FF);
  static const Color skySoft = Color(0xFFDCEBFF);
  static const Color lilacSoft = Color(0xFFEDE3FF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientEnd,
        primary: AppColors.gradientEnd,
        secondary: AppColors.gradientStart,
        background: AppColors.background,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textDark),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark),
        bodyMedium: GoogleFonts.poppins(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.gradientEnd.withOpacity(0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.gradientEnd : AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.gradientEnd : AppColors.textMuted);
        }),
      ),
    );
  }
}
