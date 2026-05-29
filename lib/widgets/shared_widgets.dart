import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_theme.dart';

// ── Stat Card (hero dark + light variants) ────────────────────────────────

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String? trend;

  StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isDark = false,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.heroCard : AppTheme.card;
    final titleColor = isDark ? Colors.white70 : AppTheme.textSecondary;
    final valueColor = isDark ? Colors.white : AppTheme.textPrimary;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: isDark ? Colors.white : color, size: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(value,
              style: GoogleFonts.nunito(
                  color: valueColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5)),
          SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.nunito(color: titleColor, fontSize: 13)),
          if (trend != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.trending_up,
                    color: AppTheme.success, size: 14),
                SizedBox(width: 4),
                Text(trend!,
                    style: GoogleFonts.nunito(
                        color: AppTheme.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Score Bar ─────────────────────────────────────────────────────────────

class ScoreBar extends StatelessWidget {
  final String label;
  final double percent;

  ScoreBar({super.key, required this.label, required this.percent});

  Color get _color {
    if (percent >= 80) return AppTheme.success;
    if (percent >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary, fontSize: 13)),
            Text('${percent.toStringAsFixed(1)}%',
                style: GoogleFonts.nunito(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, val, _) => LinearProgressIndicator(
              value: val,
              backgroundColor: AppTheme.borderLight,
              valueColor: AlwaysStoppedAnimation(_color),
              minHeight: 7,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Grade Badge ───────────────────────────────────────────────────────────

class GradeBadge extends StatelessWidget {
  final String grade;
  GradeBadge({super.key, required this.grade});

  Color get _color {
    switch (grade) {
      case 'Good': return AppTheme.success;
      case 'Middle': return AppTheme.warning;
      default: return AppTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(grade,
          style: GoogleFonts.nunito(
              color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── CEFR Badge ────────────────────────────────────────────────────────────

class CefrBadge extends StatelessWidget {
  final String level;
  CefrBadge({super.key, required this.level});

  Color get _color {
    switch (level) {
      case 'A1': return AppTheme.danger;
      case 'A2': return AppTheme.warning;
      case 'B1': return Color(0xFF3B82F6);
      default:   return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(level,
          style: GoogleFonts.nunito(
              color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Styled Dropdown ───────────────────────────────────────────────────────

class StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData? icon;

  StyledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        DropdownButtonFormField<T>(
          key: ValueKey(value),
          initialValue: value,
          items: items,
          onChanged: onChanged,
          hint: hint != null
              ? Text(hint!,
                  style: GoogleFonts.nunito(
                      color: AppTheme.textMuted, fontSize: 14))
              : null,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01,
              color: AppTheme.textSecondary, size: 18),
          dropdownColor: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.nunito(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              SizedBox(height: 2),
              Text(subtitle!,
                  style: GoogleFonts.nunito(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ],
        ),
        Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Light Card ────────────────────────────────────────────────────────────

class LightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  LightCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.smallShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: inner),
      );
    }
    return inner;
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final bool done;

  StatusBadge({super.key, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: done
            ? AppTheme.success.withValues(alpha: 0.1)
            : Color(0xFF6B7280).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        done ? 'Done' : 'Pending',
        style: GoogleFonts.nunito(
          color: done ? AppTheme.success : AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Styled Text Field ─────────────────────────────────────────────────────

class StyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool required;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  StyledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.required = true,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            if (required)
              Text(' *',
                  style: GoogleFonts.nunito(
                      color: AppTheme.danger, fontSize: 13)),
          ],
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 14),
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppTheme.textSecondary, size: 18)
                : null,
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}


