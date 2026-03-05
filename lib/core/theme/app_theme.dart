import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── THE NEW PALETTE ───────────────────────────────────────────────────
  // Background layers
  static const Color bgAbyss = Color(0xFF111214); // scaffold bg
  static const Color bgSurface = Color(0xFF181A1C); // card/sheet bg
  static const Color bgElevated = Color(0xFF1F2225); // elevated cards
  static const Color bgInput = Color(0xFF272B2F); // text fields / pills
  static const Color bgBorder = Color(0xFF32373D); // dividers / borders

  // Coral — primary accent
  static const Color coral = Color(0xFFE8614A); // CTAs, active, badges
  static const Color coralLight = Color(0xFFF07D68); // hover / lighter
  static const Color coralDim = Color(0xFF3D2520); // coral-tinted surface

  // Text hierarchy
  static const Color text100 = Color(0xFFF2F2F2); // headings, amounts
  static const Color text200 = Color(0xFFC8CACF); // body text
  static const Color text400 = Color(0xFF7A7F88); // captions / labels
  static const Color text600 = Color(0xFF444950); // muted / disabled

  // Semantic
  static const Color success = Color(0xFF4CAF82);
  static const Color error = Color(0xFFE8614A);
  static const Color warning = Color(0xFFE8A04A);
  static const Color info = Color(0xFF3B82F6); // kept for compat

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE8614A), Color(0xFFD94F35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [
      Color(0xFF2A1A14),
      Color(0xFF3D2010),
      Color(0xFF1A2A2E),
      Color(0xFF0E1E22)
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = primaryGradient; // compat
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── BACKWARD COMPATIBILITY ALIASES ────────────────────────────────────
  static const Color primaryDarkGreen = bgAbyss;
  static const Color primaryDark = bgAbyss; // Added for compatibility
  static const Color primaryMedium = bgSurface; // Added for compatibility
  static const Color primaryGreen = bgSurface;
  static const Color accentCoral = coral; // Added for compatibility
  static const Color primaryDarkTeal = bgAbyss;
  static const Color primaryTeal = bgSurface;

  static const Color accentLime = coralDim;
  static const Color accentLightGreen = coralDim;
  static const Color accentMintGreen = coralDim;
  static const Color accentLightMint = coralDim;

  static const Color backgroundLight = bgAbyss; // Now dark
  static const Color cardBackground = bgSurface;
  static const Color darkCardBackground = bgElevated;

  static const Color textDark = text100; // Legacy dark text is now light
  static const Color textLight = text400;
  static const Color textOnDark = text100;

  static const Color pillBackground = bgInput;
  static const Color scaffoldDark = bgAbyss;

  // ── DECORATIONS & SHADOWS ─────────────────────────────────────────────

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: coral.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration glassDecoration({Color? color}) {
    return BoxDecoration(
      color: (color ?? bgSurface).withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration gradientButtonDecoration({LinearGradient? gradient}) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: (gradient?.colors.first ?? coral).withOpacity(0.35),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ── THEMEDATA ─────────────────────────────────────────────────────────

  static ThemeData get lightTheme => _buildTheme();
  static ThemeData get darkTheme => _buildTheme();

  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgAbyss,
      colorScheme: const ColorScheme.dark(
        primary: coral,
        secondary: coralLight,
        surface: bgSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text100,
      ),
      fontFamily: 'DM Sans',
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: text100,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: text100,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: text100,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: text100,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: text200, // Slightly softer body text
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: text400,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: text400,
        ),
        labelLarge: GoogleFonts.dmMono(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: text100,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSurface,
        foregroundColor: text100,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: text100),
        titleTextStyle: TextStyle(
          color: text100,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'DM Sans',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coral,
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
      cardTheme: CardTheme(
        color: bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: bgInput,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgBorder),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgBorder),
        ),
        hintStyle: const TextStyle(color: text400),
        labelStyle: const TextStyle(color: text200),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: coral,
        unselectedItemColor: text400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
