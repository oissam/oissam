import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

class ExStatisticsScreen extends StatelessWidget {
  ExStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, _) {
        final allStudents = DataService.getAllStudents();
        final allResults = DataService.getAllResults();

        // Passed students logic
        final passedStudentIds = allResults.where((r) {
          return r.isPassed ?? r.overallPercent >= 50;
        }).map((r) => r.studentId).toSet();

        final passedStudents = allStudents.where((s) => passedStudentIds.contains(s.id)).toList();

        final totalRegistered = allStudents.length;
        final totalPassed = passedStudents.length;

        // Language breakdown for all registered OR passed? The plan said passed, but I'll show both for maximum info or just registered and passed.
        // Let's do registered language and passed language
        final registeredUzbek = allStudents.where((s) => s.language.toLowerCase() == 'uzbek').length;
        final registeredRussian = allStudents.where((s) => s.language.toLowerCase() == 'russian').length;
        
        final passedUzbek = passedStudents.where((s) => s.language.toLowerCase() == 'uzbek').length;
        final passedRussian = passedStudents.where((s) => s.language.toLowerCase() == 'russian').length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Global Statistics',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              // Global Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final crossAxisCount = isMobile ? 1 : 3;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 2.5 : 1.5,
                    children: [
                      _buildStatCard(
                        'Total Registered',
                        totalRegistered.toString(),
                        Icons.group,
                        Colors.blueAccent,
                        'Uzbek: $registeredUzbek  |  Russian: $registeredRussian',
                      ),
                      _buildStatCard(
                        'Total Passed',
                        totalPassed.toString(),
                        Icons.verified,
                        AppTheme.success,
                        'Uzbek: $passedUzbek  |  Russian: $passedRussian',
                      ),
                      _buildStatCard(
                        'Pass Rate',
                        totalRegistered > 0 ? '${((totalPassed / totalRegistered) * 100).toStringAsFixed(1)}%' : '0%',
                        Icons.analytics,
                        AppTheme.warning,
                        'Overall success rate',
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 40),
              Text(
                'Class Breakdown',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              // Class Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final crossAxisCount = isMobile ? 1 : 2;
                  
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 180,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: DataService.classes.length,
                    itemBuilder: (context, index) {
                      final className = DataService.classes[index];
                      final classStudents = allStudents.where((s) => s.studentClass == className).toList();
                      final classPassedStudents = passedStudents.where((s) => s.studentClass == className).toList();
                      
                      final cRegUzbek = classStudents.where((s) => s.language.toLowerCase() == 'uzbek').length;
                      final cRegRussian = classStudents.where((s) => s.language.toLowerCase() == 'russian').length;
                      
                      final cPassUzbek = classPassedStudents.where((s) => s.language.toLowerCase() == 'uzbek').length;
                      final cPassRussian = classPassedStudents.where((s) => s.language.toLowerCase() == 'russian').length;

                      return Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: AppTheme.accent,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Class $className',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat('Registered', classStudents.length, cRegUzbek, cRegRussian, AppTheme.textSecondary),
                                _buildMiniStat('Passed', classPassedStudents.length, cPassUzbek, cPassRussian, AppTheme.success),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int total, int uzbek, int russian, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          total.toString(),
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'UZ: $uzbek | RU: $russian',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
