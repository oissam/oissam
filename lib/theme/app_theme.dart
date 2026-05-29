import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  // ── Headings ──────────────────────────────────────────────────────────
  static TextStyle get heading1 => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800,
  );
  static TextStyle get heading2 => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700,
  );
  static TextStyle get heading3 => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
  );

  // ── Body ──────────────────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
  );
  static TextStyle get bodySecondary => GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static TextStyle get bodyBold => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
  );

  // ── Labels & Captions ─────────────────────────────────────────────────
  static TextStyle get label => GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600,
  );
  static TextStyle get caption => GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 11,
  );
  static TextStyle get subtitle => GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );

  // ── Special ───────────────────────────────────────────────────────────
  static TextStyle get navLabel => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
  );
  static TextStyle get navLabelActive => GoogleFonts.nunito(
    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
  );
  static TextStyle get sidebarTitle => GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800,
  );
  static TextStyle get tableHeader => GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );
  static TextStyle get tableCell => GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static TextStyle get accent => GoogleFonts.nunito(
    color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w600,
  );
  static TextStyle get success => GoogleFonts.nunito(
    color: AppTheme.success, fontSize: 13,
  );
  static TextStyle get warning => GoogleFonts.nunito(
    color: AppTheme.warning, fontSize: 13,
  );
  static TextStyle get filterLabel => GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static TextStyle get filterLabelActive => GoogleFonts.nunito(
    color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  // Global theme state
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  // ── Color Palette ──────────────────────────────
  static Color get background  => isDark ? Color(0xFF111111) : Color(0xFFE5E7EB);
  static Color get surface     => isDark ? Color(0xFF1F2937) : Color(0xFFFFFFFF);
  static Color get card        => isDark ? Color(0xFF1F2937) : Color(0xFFFFFFFF);
  static Color get cardHover   => isDark ? Color(0xFF374151) : Color(0xFFF9FAFB);
  static Color get sidebarBg   => isDark ? Color(0xFF1F2937) : Color(0xFFFFFFFF);

  static Color get textPrimary   => isDark ? Color(0xFFF9FAFB) : Color(0xFF000000);
  static Color get textSecondary => isDark ? Color(0xFFD1D5DB) : Color(0xFF4B5563);
  static Color get textMuted     => isDark ? Color(0xFF9CA3AF) : Color(0xFF9CA3AF);

  static Color get border      => isDark ? Color(0xFF374151) : Color(0xFFE5E7EB);
  static Color get borderLight => isDark ? Color(0xFF4B5563) : Color(0xFFF3F4F6);

  // Accent
  static Color get accent      => isDark ? Color(0xFFFFFFFF) : Color(0xFF111111);
  static Color get accentLight => isDark ? Color(0xFFD1D5DB) : Color(0xFF374151);

  // Role colors
  static Color get callCenterColor  => isDark ? Color(0xFFFFFFFF) : Color(0xFF111111);
  static Color get examinatorColor  => isDark ? Color(0xFFD1D5DB) : Color(0xFF374151);

  // Status colors
  static Color success = Color(0xFF10B981);
  static Color warning = Color(0xFFF59E0B);
  static Color danger  = Color(0xFFEF4444);

  // Dark hero card
  static Color get heroCard     => isDark ? Color(0xFF222222) : Color(0xFF111111);
  static Color get heroCardText => Color(0xFFFFFFFF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static LinearGradient get heroGradient => LinearGradient(
    colors: isDark 
        ? [Color(0xFF374151), Color(0xFF111111)]
        : [Color(0xFF222222), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => LinearGradient(
    colors: isDark
        ? [Color(0xFF4B5563), Color(0xFF1F2937)]
        : [Color(0xFF374151), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Color(0xFF000000).withValues(alpha: isDark ? 0.3 : 0.02),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get smallShadow => [
    BoxShadow(
      color: Color(0xFF000000).withValues(alpha: isDark ? 0.2 : 0.02),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get theme {
    return _buildThemeData(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildThemeData(Brightness.dark);
  }

  static ThemeData _buildThemeData(Brightness brightness) {
    // Determine context manually for theme generation so it reflects properly when nested
    final isDarkContext = brightness == Brightness.dark;
    final currentBackground = isDarkContext ? Color(0xFF111111) : Color(0xFFE5E7EB);
    final currentSurface = isDarkContext ? Color(0xFF1F2937) : Color(0xFFFFFFFF);
    final currentAccent = isDarkContext ? Color(0xFFFFFFFF) : Color(0xFF111111);
    final currentTextPrimary = isDarkContext ? Color(0xFFF9FAFB) : Color(0xFF000000);
    final currentTextMuted = isDarkContext ? Color(0xFF9CA3AF) : Color(0xFF9CA3AF);
    final currentBorder = isDarkContext ? Color(0xFF374151) : Color(0xFFE5E7EB);
    final currentBorderLight = isDarkContext ? Color(0xFF4B5563) : Color(0xFFF3F4F6);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: currentBackground,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: currentAccent,
        onPrimary: isDarkContext ? Colors.black : Colors.white,
        secondary: currentAccent,
        onSecondary: isDarkContext ? Colors.black : Colors.white,
        error: danger,
        onError: Colors.white,
        surface: currentSurface,
        onSurface: currentTextPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: currentAccent,
          foregroundColor: isDarkContext ? Colors.black : Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: currentTextPrimary,
          side: BorderSide(color: currentBorder),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: currentSurface,
        hintStyle: GoogleFonts.nunito(color: currentTextMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: currentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: currentBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: currentAccent, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      dividerColor: currentBorder,
    );
  }
}


