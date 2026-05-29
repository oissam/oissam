import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class StudentProfileDialog extends StatelessWidget {
  final Student student;
  final ExamResult? result;

  const StudentProfileDialog({super.key, required this.student, this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.2),
                    AppTheme.callCenterColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${student.firstName[0]}${student.lastName[0]}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _tag(
                              'Grade ${student.studentClass}',
                              AppTheme.accent,
                            ),
                            const SizedBox(width: 8),
                            _tag(student.language, AppTheme.callCenterColor),
                            if (result != null && result!.isPassed != null) ...[
                              const SizedBox(width: 8),
                              _tag(
                                result!.isPassed! ? 'PASSED' : 'FAILED',
                                result!.isPassed! ? AppTheme.success : AppTheme.danger,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Contact info
                      _section('Contact Information', Icons.phone_outlined, [
                        _infoRow(
                          'Phone 1',
                          student.phone1,
                          Icons.phone_rounded,
                        ),
                        if (student.phone2 != null)
                          _infoRow(
                            'Phone 2',
                            student.phone2!,
                            Icons.phone_rounded,
                          ),
                      ]),
                      const SizedBox(height: 16),

                      // Exam info
                      _section('Exam Schedule', Icons.calendar_month_rounded, [
                        _infoRow(
                          'Date',
                          student.examDate,
                          Icons.calendar_today_rounded,
                        ),
                        _infoRow(
                          'Time',
                          student.examTime,
                          Icons.access_time_rounded,
                        ),
                        _infoRow(
                          'Room',
                          student.examRoom,
                          Icons.meeting_room_rounded,
                        ),
                      ]),

                      // Results (if available)
                      if (result != null) ...[
                        const SizedBox(height: 16),
                        _section('Exam Results', Icons.analytics_rounded, [
                          const SizedBox(height: 8),
                          ScoreBar(label: 'Math', percent: result!.mathPercent),
                          const SizedBox(height: 10),
                          ScoreBar(
                            label: 'English',
                            percent: result!.englishPercent,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Essay (CEFR)',
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              CefrBadge(level: result!.essayGrade),
                            ],
                          ),
                          if (result!.essayText != null && result!.essayText!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.notes_rounded, color: AppTheme.textMuted, size: 16),
                                      const SizedBox(width: 6),
                                      Text('Student Essay',
                                          style: GoogleFonts.nunito(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result!.essayText!,
                                    style: GoogleFonts.nunito(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(color: AppTheme.border, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall Result',
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${result!.overallPercent.toStringAsFixed(1)}%',
                                    style: GoogleFonts.nunito(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GradeBadge(grade: result!.grade),
                                ],
                              ),
                            ],
                          ),
                        ]),
                      ] else ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.hourglass_empty,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Results not yet available',
                                style: GoogleFonts.nunito(
                                  color: AppTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accent, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 14),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.nunito(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}