import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

// ── Essay controller that renders [m]...[/m] as red highlights ─────────────

class _EssayHighlightController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final exp = RegExp(r'\[m\](.*?)\[/m\]');
    final List<InlineSpan> children = [];
    int start = 0;
    for (final match in exp.allMatches(text)) {
      if (match.start > start) {
        children.add(TextSpan(text: text.substring(start, match.start), style: style));
      }
      children.add(TextSpan(
        children: [
          TextSpan(text: '[m]', style: style?.copyWith(color: Colors.transparent, fontSize: 0)),
          TextSpan(
            text: match.group(1),
            style: style?.copyWith(
              backgroundColor: Colors.red.withOpacity(0.2),
              color: Colors.red.shade900,
              decoration: TextDecoration.underline,
              decorationColor: Colors.red.shade900,
            ),
          ),
          TextSpan(text: '[/m]', style: style?.copyWith(color: Colors.transparent, fontSize: 0)),
        ],
      ));
      start = match.end;
    }
    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start), style: style));
    }
    return TextSpan(style: style, children: children);
  }
}

// ── ReviewProfileDialog ────────────────────────────────────────────────────

class ReviewProfileDialog extends StatefulWidget {
  final Student student;
  final ExamResult result;

  ReviewProfileDialog({super.key, required this.student, required this.result});

  @override
  State<ReviewProfileDialog> createState() => _ReviewProfileDialogState();
}

class _ReviewProfileDialogState extends State<ReviewProfileDialog> {
  late final _EssayHighlightController _essayCtrl;
  late bool? _isPassed;
  bool _isSaving = false;
  bool _essayChanged = false;

  @override
  void initState() {
    super.initState();
    _essayCtrl = _EssayHighlightController()
      ..text = widget.result.essayText ?? '';
    _isPassed = widget.result.isPassed;
    _essayCtrl.addListener(() {
      final changed = _essayCtrl.text != (widget.result.essayText ?? '');
      if (changed != _essayChanged) setState(() => _essayChanged = changed);
    });
  }

  @override
  void dispose() {
    _essayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final updated = ExamResult(
      studentId: widget.result.studentId,
      mathAnswered: widget.result.mathAnswered,
      mathTotal: widget.result.mathTotal,
      englishAnswered: widget.result.englishAnswered,
      englishTotal: widget.result.englishTotal,
      essayGrade: widget.result.essayGrade,
      essayText: _essayCtrl.text.trim().isEmpty ? null : _essayCtrl.text.trim(),
      commentary: widget.result.commentary,
      isPassed: _isPassed,
      enteredAt: widget.result.enteredAt,
    );
    try {
      await DataService.saveResult(updated);
      if (mounted) {
        setState(() { _isSaving = false; _essayChanged = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Changes saved for ${widget.student.fullName}'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  void _highlightMistake() {
    final sel = _essayCtrl.selection;
    if (sel.isValid && !sel.isCollapsed) {
      final text = _essayCtrl.text;
      final selected = sel.textInside(text);
      final newText = text.replaceRange(sel.start, sel.end, '[m]$selected[/m]');
      _essayCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: sel.start + 3 + selected.length + 4),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Select some text in the essay first'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _clearHighlights() {
    final cleaned = _essayCtrl.text
        .replaceAll('[m]', '')
        .replaceAll('[/m]', '');
    _essayCtrl.text = cleaned;
  }

  Color get _rowAccent => _isPassed == null
      ? AppTheme.warning
      : _isPassed == true
          ? AppTheme.success
          : AppTheme.danger;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final student = widget.student;
    final hasEssay = _essayCtrl.text.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        width: 720,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 48,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _rowAccent.withOpacity(0.18),
                    AppTheme.surface.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _rowAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${student.firstName[0]}${student.lastName[0]}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: [
                            _tag('Grade ${student.studentClass}', AppTheme.accent),
                            _tag(student.language, AppTheme.examinatorColor),
                            _tag(
                              _isPassed == null
                                  ? 'PENDING'
                                  : _isPassed!
                                      ? 'PASSED ✓'
                                      : 'FAILED ✗',
                              _rowAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Two-column: info + scores
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: student info
                        Expanded(
                          child: _section(
                            'Exam Schedule',
                            Icons.calendar_month_rounded,
                            [
                              _infoRow('Date', student.examDate, Icons.calendar_today_rounded),
                              _infoRow('Time', student.examTime, Icons.access_time_rounded),
                              _infoRow('Room', student.examRoom, Icons.meeting_room_rounded),
                              _infoRow('Phone', student.phone1, Icons.phone_rounded),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Right: scores
                        Expanded(
                          child: _section(
                            'Exam Scores',
                            Icons.analytics_rounded,
                            [
                              ScoreBar(label: 'Math', percent: result.mathPercent),
                              SizedBox(height: 10),
                              ScoreBar(label: 'English', percent: result.englishPercent),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Overall',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textSecondary, fontSize: 13)),
                                  Row(children: [
                                    Text(
                                      '${result.overallPercent.toStringAsFixed(1)}%',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(width: 8),
                                    GradeBadge(grade: result.grade),
                                  ]),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Essay CEFR',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textSecondary, fontSize: 13)),
                                  CefrBadge(level: result.essayGrade),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // ── Essay Editor ─────────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Essay section header
                          Row(
                            children: [
                              Icon(Icons.notes_rounded, color: AppTheme.accent, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Student Essay',
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              // Highlight mistake button
                              OutlinedButton.icon(
                                onPressed: _highlightMistake,
                                icon: Icon(Icons.highlight_alt_rounded, size: 15),
                                label: Text('Highlight Mistake'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.danger,
                                  side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.6)),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: GoogleFonts.nunito(
                                      fontSize: 12, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Clear highlights button
                              OutlinedButton.icon(
                                onPressed: _clearHighlights,
                                icon: Icon(Icons.format_clear_rounded, size: 15),
                                label: Text('Clear Highlights'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textSecondary,
                                  side: BorderSide(color: AppTheme.border),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: GoogleFonts.nunito(
                                      fontSize: 12, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // The editable essay field with live highlights
                          TextField(
                            controller: _essayCtrl,
                            maxLines: null,
                            minLines: hasEssay ? 5 : 3,
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                height: 1.6),
                            decoration: InputDecoration(
                              hintText: 'No essay text entered yet...',
                              hintStyle: GoogleFonts.nunito(
                                  color: AppTheme.textMuted, fontSize: 14),
                              filled: true,
                              fillColor: AppTheme.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: AppTheme.accent, width: 1.5),
                              ),
                              contentPadding: EdgeInsets.all(14),
                            ),
                          ),

                          if (_essayChanged) ...[
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.edit_rounded,
                                    size: 12, color: AppTheme.warning),
                                SizedBox(width: 4),
                                Text(
                                  'Unsaved changes — click "Save Changes" below',
                                  style: GoogleFonts.nunito(
                                    color: AppTheme.warning,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // ── Examinator Commentary ─────────────────────────────
                    if (result.commentary != null && result.commentary!.isNotEmpty) ...[
                      _section(
                        'Examinator Commentary',
                        Icons.comment_rounded,
                        [
                          SizedBox(height: 4),
                          Text(
                            result.commentary!,
                            style: GoogleFonts.nunito(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],

                    // ── Pass / Fail Decision ──────────────────────────────
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _rowAccent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.how_to_vote_rounded,
                                  color: AppTheme.accent, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Pass / Fail Decision',
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              // PASSED button
                              Expanded(
                                child: _bigDecisionBtn(
                                  label: 'Passed',
                                  sublabel: 'Student has passed the exam',
                                  icon: Icons.check_circle_outline_rounded,
                                  color: AppTheme.success,
                                  isSelected: _isPassed == true,
                                  onTap: () => setState(() => _isPassed = true),
                                ),
                              ),
                              SizedBox(width: 12),
                              // FAILED button
                              Expanded(
                                child: _bigDecisionBtn(
                                  label: 'Failed',
                                  sublabel: 'Student has not passed the exam',
                                  icon: Icons.cancel_outlined,
                                  color: AppTheme.danger,
                                  isSelected: _isPassed == false,
                                  onTap: () => setState(() => _isPassed = false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer with Save button ───────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  // Status summary
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: _isPassed == null
                        ? Row(
                            key: ValueKey('pending'),
                            children: [
                              Icon(Icons.pending_actions_rounded,
                                  color: AppTheme.warning, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'No decision yet',
                                style: GoogleFonts.nunito(
                                    color: AppTheme.warning, fontSize: 13),
                              ),
                            ],
                          )
                        : Row(
                            key: ValueKey(_isPassed),
                            children: [
                              Icon(
                                _isPassed!
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: _rowAccent,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _isPassed!
                                    ? 'Marked as Passed'
                                    : 'Marked as Failed',
                                style: GoogleFonts.nunito(
                                    color: _rowAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.border),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Close',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.isDark
                                    ? Colors.black
                                    : Colors.white),
                          )
                        : Icon(Icons.save_rounded, size: 16),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigDecisionBtn({
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? color : AppTheme.textMuted, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: isSelected ? color : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.nunito(
                      color: isSelected
                          ? color.withValues(alpha: 0.8)
                          : AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppTheme.accent, size: 15),
            SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.nunito(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, color: AppTheme.textMuted, size: 13),
        SizedBox(width: 8),
        Text('$label: ',
            style: GoogleFonts.nunito(
                color: AppTheme.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
