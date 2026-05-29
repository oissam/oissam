import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/student_profile_dialog.dart';
// To reuse the empty state and row designs

class CCFilteredStudentsScreen extends StatefulWidget {
  final bool isPassed;

  CCFilteredStudentsScreen({super.key, required this.isPassed});

  @override
  State<CCFilteredStudentsScreen> createState() =>
      _CCFilteredStudentsScreenState();
}

class _CCFilteredStudentsScreenState extends State<CCFilteredStudentsScreen> {
  String _searchQuery = '';

  List<Student> get _filteredStudents {
    final all = DataService.getAllStudents();
    return all.where((s) {
      final res = DataService.getResult(s.id);
      // Filter strictly by the passed status
      if (res == null || res.isPassed != widget.isPassed) return false;

      // Also apply search query
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.firstName.toLowerCase().contains(q) ||
          s.lastName.toLowerCase().contains(q) ||
          s.phone1.contains(q) ||
          (s.phone2 != null && s.phone2!.contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, _) {
        final list = _filteredStudents;
        final String title = widget.isPassed ? 'Passed Students' : 'Failed Students';
        final IconData icon = widget.isPassed ? Icons.check_circle_outline : Icons.cancel_outlined;
        final Color color = widget.isPassed ? AppTheme.success : AppTheme.danger;

        return Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Students who have ${widget.isPassed ? 'passed' : 'failed'} the exam',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Local Search Input
                  Container(
                    width: 240,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.border),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: AppTheme.textMuted, size: 18),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search these students...',
                              hintStyle: GoogleFonts.nunito(
                                  color: AppTheme.textMuted, fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hoverColor: Colors.transparent,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 13),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: AppTheme.textMuted, size: 56),
                            SizedBox(height: 16),
                            Text('No students found',
                                style: GoogleFonts.nunito(
                                    color: AppTheme.textMuted, fontSize: 16)),
                          ],
                        ),
                      )
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
                                itemCount: list.length,
                                separatorBuilder: (_, _) => Divider(
                                height: 1, color: AppTheme.border),
                            itemBuilder: (ctx, i) => _studentRow(list[i]),
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

  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _colHeader('Student Name')),
          Expanded(flex: 2, child: _colHeader('Contact')),
          Expanded(flex: 2, child: _colHeader('Grade/Lang')),
          Expanded(flex: 2, child: _colHeader('Exam Info')),
          SizedBox(width: 80), // Actions
        ],
      ),
    );
  }

  Widget _colHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.nunito(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _studentRow(Student s) {
    final result = DataService.getResult(s.id);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => StudentProfileDialog(student: s, result: result),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${s.firstName[0]}${s.lastName[0]}',
                        style: GoogleFonts.nunito(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.fullName,
                          style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${s.id.substring(0, 6)}',
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
            // Contact
            Expanded(
              flex: 2,
              child: Text(
                s.phone1,
                style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            // Grade/Lang
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('G${s.studentClass}',
                        style: GoogleFonts.nunito(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(width: 8),
                  Text(s.language.substring(0, 2).toUpperCase(),
                      style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Exam Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.examDate,
                      style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text('${s.examTime} - ${s.examRoom}',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textMuted),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          StudentProfileDialog(student: s, result: result),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


