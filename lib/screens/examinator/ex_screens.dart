import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/student_profile_dialog.dart';

// ── Examinator: Student List ─────────────────────────────────────────────

class ExStudentListScreen extends StatefulWidget {
  ExStudentListScreen({super.key});

  @override
  State<ExStudentListScreen> createState() => _ExStudentListScreenState();
}

class _ExStudentListScreenState extends State<ExStudentListScreen> {
  String? _filterDate;
  String? _filterRoom;
  String? _filterTime;

  List<Student> get _filtered {
    var students = DataService.getAllStudents();
    if (_filterDate != null) {
      students = students.where((s) => s.examDate == _filterDate).toList();
    }
    if (_filterRoom != null) {
      students = students.where((s) => s.examRoom == _filterRoom).toList();
    }
    if (_filterTime != null) {
      students = students.where((s) => s.examTime == _filterTime).toList();
    }
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, _) {
        final uniqueDates = DataService.getAvailableDates();
        
        final now = DateTime.now();
        final nowStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final todayStr = nowStr.substring(0, 10);
        
        final allStudents = DataService.getAllStudents();
        
        // Count unique exam sessions (date + time + room)
        final todaySessions = allStudents.where((s) => s.examDate == todayStr).map((s) => '${s.examTime}-${s.examRoom}').toSet().length;
        final upcomingSessions = allStudents.where((s) => '${s.examDate} ${s.examTime}'.compareTo(nowStr) > 0).map((s) => '${s.examDate}-${s.examTime}-${s.examRoom}').toSet().length;
        final pastSessions = allStudents.where((s) => '${s.examDate} ${s.examTime}'.compareTo(nowStr) < 0).map((s) => '${s.examDate}-${s.examTime}-${s.examRoom}').toSet().length;

        // Count passed/failed students
        final withResults = allStudents.where((s) => DataService.hasResult(s.id));
        final passedCount = withResults.where((s) {
          final result = DataService.getResult(s.id)!;
          return result.isPassed ?? result.overallPercent >= 50;
        }).length;
        final failedCount = withResults.length - passedCount;

        return Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0x26374151), // examinatorColor 15%
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: AppTheme.examinatorColor, size: 22),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Registered Students', style: AppTextStyle.heading2),
                      Text('All students registered for upcoming exams',
                          style: AppTextStyle.subtitle),
                    ],
                  ),
                  Spacer(),
                  Text('${_filtered.length} students', style: AppTextStyle.caption),
                ],
              ),
              SizedBox(height: 24),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: "Today's Exams",
                      value: todaySessions.toString(),
                      icon: Icons.today_rounded,
                      color: AppTheme.examinatorColor,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Upcoming Exams',
                      value: upcomingSessions.toString(),
                      icon: Icons.next_plan_outlined,
                      color: AppTheme.examinatorColor,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Past Exams',
                      value: pastSessions.toString(),
                      icon: Icons.history_rounded,
                      color: AppTheme.examinatorColor,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Passed Students',
                      value: passedCount.toString(),
                      icon: Icons.thumb_up_alt_outlined,
                      color: AppTheme.success,
                      isDark: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: StatCard(
                      title: 'Failed Students',
                      value: failedCount.toString(),
                      icon: Icons.thumb_down_alt_outlined,
                      color: AppTheme.danger,
                      isDark: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Filters
              Row(
                children: [
                  _filterDropdown(
                      'Date',
                      _filterDate,
                      [null, ...uniqueDates],
                      (v) => setState(() => _filterDate = v)),
                  SizedBox(width: 12),
                  _filterDropdown(
                      'Room',
                      _filterRoom,
                      [null, ...DataService.rooms],
                      (v) => setState(() => _filterRoom = v)),
                  SizedBox(width: 12),
                  _filterDropdown(
                      'Time',
                      _filterTime,
                      [null, ...DataService.getAllTimes()],
                      (v) => setState(() => _filterTime = v)),
                  SizedBox(width: 12),
                  if (_filterDate != null ||
                      _filterRoom != null ||
                      _filterTime != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _filterDate = null;
                        _filterRoom = null;
                        _filterTime = null;
                      }),
                      icon: Icon(Icons.clear, size: 16),
                      label: Text('Clear Filters'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary),
                    ),
                ],
              ),
              SizedBox(height: 20),

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
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: _filtered.length,
                                          separatorBuilder: (_, _) => Divider(
                                              height: 1, color: AppTheme.border),
                                          itemBuilder: (ctx, i) =>
                                              _studentRow(_filtered[i]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _filterDropdown(String label, String? value, List<String?> options,
      ValueChanged<String?> onChanged) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: GoogleFonts.nunito(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            hint: Text('All ${label}s', style: AppTextStyle.caption),
            items: options
                .map((o) => DropdownMenuItem<String>(
                    value: o,
                    child: Text(o ?? 'All ${label}s', style: AppTextStyle.bodySecondary)))
                .toList(),
            onChanged: onChanged,
            dropdownColor: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.card,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _h('Student', flex: 3),
          _h('Grade'),
          _h('Language'),
          _h('Date', flex: 2),
          _h('Time'),
          _h('Room'),
          _h('Level', flex: 2),
        ],
      ),
    );
  }

  Widget _h(String t, {int flex = 1}) => Expanded(
      flex: flex,
      child: Text(t, style: AppTextStyle.label));

  Widget _studentRow(Student s) {
    final hasResult = DataService.hasResult(s.id);
    
    final now = DateTime.now();
    final nowStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => StudentProfileDialog(
            student: s,
            result: hasResult ? DataService.getResult(s.id) : null,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0x26374151), // examinatorColor 15%
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${s.firstName[0]}${s.lastName[0]}',
                      style: AppTextStyle.label.copyWith(color: AppTheme.examinatorColor, fontSize: 13),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(s.fullName, style: AppTextStyle.body),
                ),
              ]),
            ),
            Expanded(child: _cell('Grade ${s.studentClass}')),
            Expanded(child: _cell(s.language)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _cell(s.examDate),
                  if ('${s.examDate} ${s.examTime}'.compareTo(nowStr) < 0)
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
            Expanded(child: _cell(s.examTime)),
            Expanded(child: _cell(s.examRoom)),
            Expanded(
              flex: 2,
              child: hasResult
                  ? Row(children: [
                      Icon(Icons.check_circle,
                          color: AppTheme.success, size: 16),
                      SizedBox(width: 6),
                      Text('Done',
                          style: TextStyle(
                              color: AppTheme.success, fontSize: 13)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ((DataService.getResult(s.id)!.isPassed ?? DataService.getResult(s.id)!.overallPercent >= 50)) 
                              ? AppTheme.success.withValues(alpha: 0.1) 
                              : AppTheme.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ((DataService.getResult(s.id)!.isPassed ?? DataService.getResult(s.id)!.overallPercent >= 50)) ? 'Passed' : 'Failed',
                          style: GoogleFonts.nunito(
                            color: ((DataService.getResult(s.id)!.isPassed ?? DataService.getResult(s.id)!.overallPercent >= 50)) ? AppTheme.success : AppTheme.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ])
                  : Row(children: [
                      Icon(Icons.pending,
                          color: AppTheme.warning, size: 16),
                      SizedBox(width: 6),
                      Text('Pending',
                          style: GoogleFonts.nunito(
                              color: AppTheme.warning, fontSize: 13)),
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String t) => Text(t, style: AppTextStyle.tableCell);

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, color: AppTheme.textMuted, size: 56),
          SizedBox(height: 16),
          Text('No students match filters', style: AppTextStyle.subtitle),
        ],
      ),
    );
  }
}

// ── Examinator: Timetable ────────────────────────────────────────────────

class TimetableScreen extends StatelessWidget {
  TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final students = DataService.getAllStudents();

    // Group: date → time → room → [students]
    final Map<String, Map<String, Map<String, List<Student>>>> grouped = {};
    
    // 1. Initialize with all available dates and times (so empty slots appear)
    final availableDates = DataService.getAvailableDates();
    for (final d in availableDates) {
      grouped[d] = {};
      final times = DataService.getTimesForDate(d);
      for (final t in times) {
        grouped[d]![t] = {};
      }
    }

    // 2. Populate with students
    for (final s in students) {
      grouped.putIfAbsent(s.examDate, () => {});
      grouped[s.examDate]!.putIfAbsent(s.examTime, () => {});
      grouped[s.examDate]![s.examTime]!.putIfAbsent(s.examRoom, () => []);
      grouped[s.examDate]![s.examTime]![s.examRoom]!.add(s);
    }
    final sortedDates = grouped.keys.toList()..sort();
    
    final now = DateTime.now();
    final nowStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                  color: AppTheme.examinatorColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.calendar_month_rounded,
                    color: AppTheme.examinatorColor, size: 22),
              ),
              SizedBox(width: 16),
              Text('Exam Timetable', style: AppTextStyle.heading2),
            ],
          ),
          SizedBox(height: 24),

          if (sortedDates.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppTheme.textMuted, size: 56),
                    SizedBox(height: 16),
                    Text('No exams scheduled yet', style: AppTextStyle.subtitle),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, di) {
                  final date = sortedDates[di];
                  final byTime = grouped[date]!;
                  final sortedTimes = byTime.keys.toList()..sort();

                  return Container(
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.examinatorColor.withValues(alpha: 0.2),
                                AppTheme.accent.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event,
                                  color: AppTheme.examinatorColor, size: 18),
                              SizedBox(width: 10),
                              Text(date, style: AppTextStyle.bodyBold),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.examinatorColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${students.where((s) => s.examDate == date).length} students',
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.examinatorColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Time slots
                        ...sortedTimes.map((time) {
                          final byRoom = byTime[time]!;
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: AppTheme.accent, size: 16),
                                    SizedBox(width: 6),
                                    Text(time,
                                        style: GoogleFonts.nunito(
                                            color: AppTheme.accent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    if ('$date $time'.compareTo(nowStr) < 0)
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.danger.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                                color: AppTheme.danger.withValues(alpha: 0.3)),
                                          ),
                                          child: Text('Past',
                                              style: GoogleFonts.nunito(
                                                  color: AppTheme.danger,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    SizedBox(width: 8),
                                    Expanded(
                                        child: Divider(
                                            color: AppTheme.border)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: DataService.rooms.map((room) {
                                    final roomStudents =
                                        byRoom[room] ?? [];
                                    return Expanded(
                                      child: InkWell(
                                        onTap: roomStudents.isEmpty ? null : () {
                                          _showRoomStatsDialog(context, date, time, room, roomStudents);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                        margin: EdgeInsets.only(
                                            right: 12),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: roomStudents.isNotEmpty
                                              ? AppTheme.accent
                                                  .withValues(alpha: 0.07)
                                              : AppTheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: roomStudents.isNotEmpty
                                                ? AppTheme.accent
                                                    .withValues(alpha: 0.3)
                                                : AppTheme.border,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons.meeting_room,
                                                    size: 14,
                                                    color:
                                                        AppTheme.textMuted),
                                                SizedBox(width: 4),
                                                Text(room,
                                                    style: GoogleFonts.nunito(
                                                        color: AppTheme
                                                            .textSecondary,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600)),
                                                Spacer(),
                                                if (roomStudents
                                                    .isNotEmpty)
                                                  Container(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: AppTheme.accent
                                                          .withValues(alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10),
                                                    ),
                                                    child: Text(
                                                        '${roomStudents.length}',
                                                        style:
                                                            GoogleFonts.nunito(
                                                                color: AppTheme
                                                                    .accent,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                  ),
                                              ],
                                            ),
                                            if (roomStudents.isNotEmpty) ...[
                                              SizedBox(height: 8),
                                              ...roomStudents.map(
                                                (s) => Padding(
                                                  padding:
                                                      EdgeInsets.only(
                                                          bottom: 4),
                                                  child: Text(
                                                    '• ${s.fullName}',
                                                    style: GoogleFonts.nunito(
                                                        color: AppTheme
                                                            .textSecondary,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              SizedBox(height: 8),
                                              Text('Empty',
                                                  style: GoogleFonts.nunito(
                                                      color:
                                                          AppTheme.textMuted,
                                                      fontSize: 12)),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showRoomStatsDialog(BuildContext context, String date, String time, String room, List<Student> students) {
    int passed = 0;
    int failed = 0;
    int pending = 0;

    for (final s in students) {
      final res = DataService.getResult(s.id);
      if (res == null || res.isPassed == null) {
        pending++;
      } else if (res.isPassed!) {
        passed++;
      } else {
        failed++;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.examinatorColor),
            SizedBox(width: 10),
            Text('Session Summary', style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$date at $time - $room', style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
            SizedBox(height: 24),
            _statRow('Total Students', students.length, AppTheme.accent),
            SizedBox(height: 12),
            _statRow('Passed', passed, AppTheme.success),
            SizedBox(height: 12),
            _statRow('Failed', failed, AppTheme.danger),
            SizedBox(height: 12),
            _statRow('Pending', pending, AppTheme.warning),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 16)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value.toString(), style: GoogleFonts.nunito(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}


