import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Palette
  static const Color primaryDarkGreen = Color(0xFF04322E);
  static const Color primaryGreen = Color(0xFF0F4A45);

  // Accent Palette
  static const Color accentLime = Color(0xFFD4F1C5);
  static const Color accentLightGreen = Color(0xFFE8F5E9);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Palette
  static const Color backgroundLight =
      Color(0xFFF2F4F6); // Slightly darker grey for contrast
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkCardBackground = Color(0xFF0A2E2E);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF6B7280); // Cool grey
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color pillBackground =
      Color(0xFFE5E7EB); // Light grey for buttons

  static const Color scaffoldDark = Color(0xFF0A1F1F);

  // Mapped for backward compatibility
  static const Color primaryDarkTeal = primaryDarkGreen;
  static const Color primaryTeal = primaryGreen;
  static const Color accentMintGreen = accentLime;
  static const Color accentLightMint = accentLightGreen;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDarkGreen, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLime, accentLightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  // Shadows
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: primaryDarkGreen.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration glassDecoration({Color? color}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryDarkGreen,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryDarkGreen,
      secondary: accentLime,
      surface: cardBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: primaryDarkGreen,
      onSurface: textDark,
    ),
    // FIX: use string literal, not GoogleFonts.dmSans().fontFamily
    fontFamily: 'DM Sans',
    textTheme: TextTheme(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textDark,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: textDark,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textLight,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: textLight,
      ),
      labelLarge: GoogleFonts.dmMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // Dark Theme (Placeholder for now, using legacy structure adapted)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: accentLime,
        secondary: primaryGreen,
        surface: darkCardBackground,
        error: error,
      ),
      scaffoldBackgroundColor: scaffoldDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldDark,
        foregroundColor: textOnDark,
        elevation: 0,
      ),
      // ... minimal dark theme for now
    );
  }

  // Helper for gradients
  static BoxDecoration gradientButtonDecoration({LinearGradient? gradient}) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: (gradient?.colors.first ?? primaryDarkGreen).withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
