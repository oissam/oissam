import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/student_profile_dialog.dart';

class ReviewResultsScreen extends StatefulWidget {
  ReviewResultsScreen({super.key});

  @override
  State<ReviewResultsScreen> createState() => _ReviewResultsScreenState();
}

class _ReviewResultsScreenState extends State<ReviewResultsScreen> {
  // Track which student is being updated (to show loading state per row)
  final Set<String> _savingIds = {};
  String _filterStatus = 'all'; // 'all', 'pending', 'passed', 'failed'

  List<_StudentResult> get _items {
    final students = DataService.getAllStudents();
    final list = students
        .where((s) => DataService.hasResult(s.id))
        .map((s) => _StudentResult(s, DataService.getResult(s.id)!))
        .toList();

    switch (_filterStatus) {
      case 'pending':
        return list.where((r) => r.result.isPassed == null).toList();
      case 'passed':
        return list.where((r) => r.result.isPassed == true).toList();
      case 'failed':
        return list.where((r) => r.result.isPassed == false).toList();
      default:
        return list;
    }
  }

  Future<void> _setPassFail(Student student, ExamResult result, bool isPassed) async {
    setState(() => _savingIds.add(student.id));
    final updated = ExamResult(
      studentId: result.studentId,
      mathAnswered: result.mathAnswered,
      mathTotal: result.mathTotal,
      englishAnswered: result.englishAnswered,
      englishTotal: result.englishTotal,
      essayGrade: result.essayGrade,
      essayText: result.essayText,
      commentary: result.commentary,
      isPassed: isPassed,
      enteredAt: result.enteredAt,
    );
    try {
      await DataService.saveResult(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${student.fullName} marked as ${isPassed ? "Passed ✓" : "Failed ✗"}',
            ),
            backgroundColor: isPassed ? AppTheme.success : AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingIds.remove(student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _value, _) {
        final allWithResults = DataService.getAllStudents()
            .where((s) => DataService.hasResult(s.id))
            .toList();
        final pendingCount =
            allWithResults.where((s) => DataService.getResult(s.id)!.isPassed == null).length;
        final passedCount =
            allWithResults.where((s) => DataService.getResult(s.id)!.isPassed == true).length;
        final failedCount =
            allWithResults.where((s) => DataService.getResult(s.id)!.isPassed == false).length;

        final items = _items;

        return SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.how_to_vote_rounded,
                        color: AppTheme.accent, size: 22),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Results',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Set Pass / Fail for students whose results have been entered',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    '${allWithResults.length} with results',
                    style: GoogleFonts.nunito(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // ── Summary stat cards ─────────────────────────────────────
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Awaiting Review',
                      value: pendingCount.toString(),
                      icon: Icons.pending_actions_rounded,
                      color: AppTheme.warning,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Passed',
                      value: passedCount.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      color: AppTheme.success,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Failed',
                      value: failedCount.toString(),
                      icon: Icons.cancel_outlined,
                      color: AppTheme.danger,
                      isDark: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // ── Filter chips ───────────────────────────────────────────
              Wrap(
                spacing: 10,
                children: [
                  _filterChip('All', 'all', allWithResults.length),
                  _filterChip('Pending', 'pending', pendingCount, AppTheme.warning),
                  _filterChip('Passed', 'passed', passedCount, AppTheme.success),
                  _filterChip('Failed', 'failed', failedCount, AppTheme.danger),
                ],
              ),
              SizedBox(height: 20),

              // ── Content ───────────────────────────────────────────────
              if (allWithResults.isEmpty)
                _emptyState()
              else if (items.isEmpty)
                _emptyFilterState()
              else
                _resultsList(items),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value, int count, [Color? color]) {
    final isActive = _filterStatus == value;
    final chipColor = color ?? AppTheme.accent;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? chipColor.withValues(alpha: 0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? chipColor : AppTheme.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isActive ? chipColor : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? chipColor.withValues(alpha: 0.25) : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.nunito(
                  color: isActive ? chipColor : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsList(List<_StudentResult> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _h('Student')),
                Expanded(flex: 2, child: _h('Scores')),
                Expanded(child: _h('Grade')),
                Expanded(child: _h('Essay')),
                Expanded(flex: 3, child: _h('Pass / Fail Decision')),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.border),
            itemBuilder: (ctx, i) => _resultRow(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _h(String t) => Text(
        t,
        style: GoogleFonts.nunito(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      );

  Widget _resultRow(_StudentResult item) {
    final student = item.student;
    final result = item.result;
    final isSaving = _savingIds.contains(student.id);
    final isPassed = result.isPassed;

    Color rowAccent = isPassed == null
        ? AppTheme.warning
        : isPassed
            ? AppTheme.success
            : AppTheme.danger;

    return Container(
      decoration: BoxDecoration(
        color: isPassed == null
            ? AppTheme.warning.withValues(alpha: 0.03)
            : isPassed
                ? AppTheme.success.withValues(alpha: 0.03)
                : AppTheme.danger.withValues(alpha: 0.03),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Student info (tappable → opens profile dialog)
          Expanded(
            flex: 3,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => StudentProfileDialog(
                      student: student,
                      result: result,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: rowAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${student.firstName[0]}${student.lastName[0]}',
                          style: GoogleFonts.nunito(
                            color: rowAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                student.fullName,
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 12,
                                color: AppTheme.textMuted,
                              ),
                            ],
                          ),
                          Text(
                            '${student.examDate} • ${student.examTime} • ${student.examRoom}',
                            style: GoogleFonts.nunito(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scores
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _scoreTag('Math', result.mathPercent),
                SizedBox(height: 4),
                _scoreTag('English', result.englishPercent),
              ],
            ),
          ),

          // Overall grade
          Expanded(
            child: _gradeBadge(result.grade, result.overallPercent),
          ),

          // Essay CEFR
          Expanded(
            child: CefrBadge(level: result.essayGrade),
          ),

          // Pass / Fail decision
          Expanded(
            flex: 3,
            child: isSaving
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accent,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // PASS button
                      Expanded(
                        child: _decisionButton(
                          label: 'Passed',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.success,
                          isSelected: isPassed == true,
                          onTap: () => _setPassFail(student, result, true),
                        ),
                      ),
                      SizedBox(width: 8),
                      // FAIL button
                      Expanded(
                        child: _decisionButton(
                          label: 'Failed',
                          icon: Icons.cancel_outlined,
                          color: AppTheme.danger,
                          isSelected: isPassed == false,
                          onTap: () => _setPassFail(student, result, false),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _decisionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppTheme.textMuted,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isSelected ? color : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreTag(String label, double percent) {
    Color c = percent >= 80
        ? AppTheme.success
        : percent >= 50
            ? AppTheme.warning
            : AppTheme.danger;
    return Row(
      children: [
        Text(
          '$label:',
          style: GoogleFonts.nunito(
              color: AppTheme.textMuted, fontSize: 11),
        ),
        SizedBox(width: 4),
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: GoogleFonts.nunito(
            color: c,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _gradeBadge(String grade, double percent) {
    Color c = grade == 'Good'
        ? AppTheme.success
        : grade == 'Middle'
            ? AppTheme.warning
            : AppTheme.danger;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        grade,
        style: GoogleFonts.nunito(
          color: c,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.how_to_vote_outlined, color: AppTheme.textMuted, size: 64),
            SizedBox(height: 20),
            Text(
              'No results entered yet',
              style: GoogleFonts.nunito(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Once the examinator enters results in "Enter Results",\nstudents will appear here for review.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFilterState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off, color: AppTheme.textMuted, size: 48),
            SizedBox(height: 16),
            Text(
              'No students match this filter',
              style: GoogleFonts.nunito(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentResult {
  final Student student;
  final ExamResult result;
  _StudentResult(this.student, this.result);
}
