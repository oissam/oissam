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
  CallCenterDashboard({super.key, this.onRefresh});

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
      builder: (context, _, _) {
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

        final isMobile = MediaQuery.sizeOf(context).width < 800;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              // Stats row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  final double cardWidth = isMobile
                      ? (constraints.maxWidth - 12) / 2
                      : (constraints.maxWidth - (6 * 12)) / 7;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Total Students',
                          value: allStudents.length.toString(),
                          icon: Icons.people_alt_rounded,
                          color: AppTheme.accent,
                          isDark: false,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Results Ready',
                          value: withResults.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppTheme.success,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Passed Students',
                          value: passedStudents.toString(),
                          icon: Icons.thumb_up_alt_outlined,
                          color: AppTheme.success,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Failed Students',
                          value: failedStudents.toString(),
                          icon: Icons.thumb_down_alt_outlined,
                          color: AppTheme.danger,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Awaiting',
                          value: (allStudents.length - withResults).toString(),
                          icon: Icons.hourglass_bottom_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: "Today's Exams",
                          value: todayExams.toString(),
                          icon: Icons.today_rounded,
                          color: AppTheme.accent,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? constraints.maxWidth : cardWidth,
                        child: StatCard(
                          title: 'Upcoming Exams',
                          value: upcomingExams.toString(),
                          icon: Icons.next_plan_outlined,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 28),

              // Search + filter row
              // Search + filter row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isMobile ? constraints.maxWidth : 300,
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: AppTextStyle.body,
                          decoration: InputDecoration(
                            hintText: 'Search by name, grade, or phone...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppTheme.textMuted,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: AppTheme.card,
                            hoverColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: AppTheme.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: AppTheme.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: AppTheme.accent,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      ...['All', 'Pending', 'Results Ready'].map(
                        (tab) => Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: _filterChip(tab),
                        ),
                      ),
                    ],
                  );
                }
              ),
              SizedBox(height: 20),

              // Table
              _filtered.isEmpty
                  ? _emptyState()
                  : Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 900,
                              ),
                              child: SizedBox(
                                width: constraints.maxWidth > 900 ? constraints.maxWidth : 900,
                                child: Column(
                                  children: [
                                    _tableHeader(),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _filtered.length,
                                      separatorBuilder: (_, _) => Divider(
                                        height: 1,
                                        color: AppTheme.border,
                                      ),
                                      itemBuilder: (context, i) =>
                                          _studentRow(_filtered[i]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
            ],
          ),
        ));
      }
    );
  }

  Widget _filterChip(String label) {
    final isActive = _filterTab == label;
    return GestureDetector(
      onTap: () => setState(() => _filterTab = label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  SizedBox(width: 10),
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
                      padding: EdgeInsets.only(left: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          padding: EdgeInsets.symmetric(
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
                      icon: Icon(
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
                      icon: Icon(
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
        if (hasResult && result!.commentary != null && result.commentary!.isNotEmpty) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.comment_rounded, size: 16, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.commentary!,
                    style: GoogleFonts.nunito(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ), // Column
    ), // Padding
  ); // InkWell
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
            child: Text('Delete'),
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
          Icon(Icons.people_outline, color: AppTheme.textMuted, size: 64),
          SizedBox(height: 16),
          Text('No students found', style: AppTextStyle.subtitle),
          SizedBox(height: 6),
          Text('Register a student using the form on the left',
              style: AppTextStyle.caption),
        ],
      ),
    );
  }
}


