import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/student_profile_dialog.dart';

// ── Call Center Dashboard ─────────────────────────────────────────────────

class CallCenterDashboard extends StatefulWidget {
  final VoidCallback? onRefresh;
  const CallCenterDashboard({super.key, this.onRefresh});

  @override
  State<CallCenterDashboard> createState() => _CallCenterDashboardState();
}

class _CallCenterDashboardState extends State<CallCenterDashboard> {
  String _searchQuery = '';
  String _filterTab = 'All'; // All, Pending, Results Ready

  List<Student> get _filtered {
    var students = DataService.getAllStudents();
    if (_searchQuery.isNotEmpty) {
      students = students
          .where(
            (s) =>
                s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.phone1.contains(_searchQuery) ||
                s.studentClass.contains(_searchQuery),
          )
          .toList();
    }
    if (_filterTab == 'Pending') {
      students = students.where((s) => !DataService.hasResult(s.id)).toList();
    } else if (_filterTab == 'Results Ready') {
      students = students.where((s) => DataService.hasResult(s.id)).toList();
    }
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, __) {
        final allStudents = DataService.getAllStudents();
        final withResults = allStudents
            .where((s) => DataService.hasResult(s.id))
            .length;
        final passedStudents = allStudents.where((s) {
          if (!DataService.hasResult(s.id)) return false;
          final result = DataService.getResult(s.id)!;
          return result.isPassed ?? result.overallPercent >= 50;
        }).length;
        final failedStudents = withResults - passedStudents;

        final now = DateTime.now();
        final nowStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final todayStr = nowStr.substring(0, 10);
        
        final todayExams = allStudents.where((s) => s.examDate == todayStr).map((s) => '${s.examTime}-${s.examRoom}').toSet().length;
        final upcomingExams = allStudents.where((s) => '${s.examDate} ${s.examTime}'.compareTo(nowStr) > 0).map((s) => '${s.examDate}-${s.examTime}-${s.examRoom}').toSet().length;

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Students',
                      value: allStudents.length.toString(),
                      icon: Icons.people_alt_rounded,
                      color: AppTheme.accent,
                      isDark: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Results Ready',
                      value: withResults.toString(),
                      icon: Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Passed Students',
                      value: passedStudents.toString(),
                      icon: Icons.thumb_up_alt_outlined,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Failed Students',
                      value: failedStudents.toString(),
                      icon: Icons.thumb_down_alt_outlined,
                      color: AppTheme.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Awaiting',
                      value: (allStudents.length - withResults).toString(),
                      icon: Icons.hourglass_bottom_rounded,
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: "Today's Exams",
                      value: todayExams.toString(),
                      icon: Icons.today_rounded,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Upcoming Exams',
                      value: upcomingExams.toString(),
                      icon: Icons.next_plan_outlined,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Search + filter row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTextStyle.body,
                      decoration: InputDecoration(
                        hintText: 'Search by name, grade, or phone...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: AppTheme.card,
                        hoverColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppTheme.accent,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...['All', 'Pending', 'Results Ready'].map(
                    (tab) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _filterChip(tab),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Table
              Expanded(
                child: _filtered.isEmpty
                    ? _emptyState()
                    : Container(
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          children: [
                            _tableHeader(),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: AppTheme.border,
                                ),
                                itemBuilder: (context, i) =>
                                    _studentRow(_filtered[i]),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _filterChip(String label) {
    final isActive = _filterTab == label;
    return GestureDetector(
      onTap: () => setState(() => _filterTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.accent : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: isActive ? AppTextStyle.filterLabelActive : AppTextStyle.filterLabel,
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _headerCell('Student', flex: 3),
          _headerCell('Grade'),
          _headerCell('Language'),
          _headerCell('Exam Date', flex: 2),
          _headerCell('Time'),
          _headerCell('Room'),
          _headerCell('Level', flex: 2),
          _headerCell('Actions'),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: AppTextStyle.tableHeader),
    );
  }

  Widget _studentRow(Student student) {
    final hasResult = DataService.hasResult(student.id);
    final result = hasResult ? DataService.getResult(student.id) : null;
    
    final now = DateTime.now();
    final nowStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _openProfile(student),
      hoverColor: AppTheme.cardHover.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Name + avatar
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${student.firstName[0]}${student.lastName[0]}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: AppTextStyle.body,
                        ),
                        Text(
                          student.phone1,
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _cell('Grade ${student.studentClass}')),
            Expanded(child: _cell(student.language)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _cell(student.examDate),
                  if ('${student.examDate} ${student.examTime}'.compareTo(nowStr) < 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Past', style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _cell(student.examTime)),
            Expanded(child: _cell(student.examRoom)),
            Expanded(
              flex: 2,
              child: hasResult
                  ? Row(children: [
                      GradeBadge(grade: result!.grade),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (result.isPassed ?? result.overallPercent >= 50) 
                              ? AppTheme.success.withValues(alpha: 0.1) 
                              : AppTheme.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (result.isPassed ?? result.overallPercent >= 50) ? 'Passed' : 'Failed',
                          style: GoogleFonts.nunito(
                            color: (result.isPassed ?? result.overallPercent >= 50) ? AppTheme.success : AppTheme.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ])
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Pending',
                            style: GoogleFonts.nunito(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: Row(
                children: [
                  Tooltip(
                    message: 'View Profile',
                    child: IconButton(
                      onPressed: () => _openProfile(student),
                      icon: const Icon(
                        Icons.open_in_new,
                        color: AppTheme.accent,
                        size: 16,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Delete',
                    child: IconButton(
                      onPressed: () => _confirmDelete(student),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.danger,
                        size: 16,
                      ),
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

  Widget _cell(String text) {
    return Text(text, style: AppTextStyle.tableCell);
  }

  void _openProfile(Student student) {
    final result = DataService.getResult(student.id);
    showDialog(
      context: context,
      builder: (_) => StudentProfileDialog(student: student, result: result),
    );
  }

  void _confirmDelete(Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Student',
          style: GoogleFonts.nunito(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${student.fullName}?',
          style: GoogleFonts.nunito(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await DataService.deleteStudent(student.id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, color: AppTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          Text('No students found', style: AppTextStyle.subtitle),
          const SizedBox(height: 6),
          Text('Register a student using the form on the left',
              style: AppTextStyle.caption),
        ],
      ),
    );
  }
}
