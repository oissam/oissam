import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pre-cached text styles — call GoogleFonts once, reuse everywhere.
/// This avoids expensive font lookups on every widget rebuild.
class AppTextStyle {
  AppTextStyle._();

  // ── Headings ──────────────────────────────────────────────────────────
  static final TextStyle heading1 = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800,
  );
  static final TextStyle heading2 = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700,
  );
  static final TextStyle heading3 = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
  );

  // ── Body ──────────────────────────────────────────────────────────────
  static final TextStyle body = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
  );
  static final TextStyle bodySecondary = GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static final TextStyle bodyBold = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
  );

  // ── Labels & Captions ─────────────────────────────────────────────────
  static final TextStyle label = GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600,
  );
  static final TextStyle caption = GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 11,
  );
  static final TextStyle subtitle = GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );

  // ── Special ───────────────────────────────────────────────────────────
  static final TextStyle navLabel = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
  );
  static final TextStyle navLabelActive = GoogleFonts.nunito(
    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
  );
  static final TextStyle sidebarTitle = GoogleFonts.nunito(
    color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800,
  );
  static final TextStyle tableHeader = GoogleFonts.nunito(
    color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );
  static final TextStyle tableCell = GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static final TextStyle accent = GoogleFonts.nunito(
    color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w600,
  );
  static final TextStyle success = GoogleFonts.nunito(
    color: AppTheme.success, fontSize: 13,
  );
  static final TextStyle warning = GoogleFonts.nunito(
    color: AppTheme.warning, fontSize: 13,
  );
  static final TextStyle filterLabel = GoogleFonts.nunito(
    color: AppTheme.textSecondary, fontSize: 13,
  );
  static final TextStyle filterLabelActive = GoogleFonts.nunito(
    color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  // ── Color Palette (Minimalist Light Theme) ──────────────────────────────
  static const Color background  = Color(0xFFE5E7EB); // Soft light grey background
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color card        = Color(0xFFFFFFFF);
  static const Color cardHover   = Color(0xFFF9FAFB);
  static const Color sidebarBg   = Color(0xFFFFFFFF);

  static const Color textPrimary   = Color(0xFF000000); // Sharp black for headers
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted     = Color(0xFF9CA3AF);

  static const Color border      = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Accent (black)
  static const Color accent      = Color(0xFF111111);
  static const Color accentLight = Color(0xFF374151);

  // Role colors
  static const Color callCenterColor  = Color(0xFF111111);
  static const Color examinatorColor  = Color(0xFF374151);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFEF4444);

  // Dark hero card
  static const Color heroCard     = Color(0xFF111111);
  static const Color heroCardText = Color(0xFFFFFFFF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF222222), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF374151), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.02),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get smallShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.02),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        surface: card,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Heavy pill rounding
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        fillColor: surface,
        hintStyle: GoogleFonts.nunito(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      dividerColor: border,
    );
  }
}
