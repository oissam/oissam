import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class EnterResultsScreen extends StatefulWidget {
  const EnterResultsScreen({super.key});

  @override
  State<EnterResultsScreen> createState() => _EnterResultsScreenState();
}

class _EnterResultsScreenState extends State<EnterResultsScreen> {
  Student? _selectedStudent;
  final _mathAnsweredCtrl = TextEditingController();
  final _mathTotalCtrl = TextEditingController();
  final _engAnsweredCtrl = TextEditingController();
  final _engTotalCtrl = TextEditingController();
  final _essayTextCtrl = EssayTextController();
  final _commentaryCtrl = TextEditingController();
  String? _essayGrade;
  bool? _isPassed;
  bool _isSaving = false;

  // Live calculator values
  double _mathPct = 0;
  double _engPct = 0;
  double _overallPct = 0;
  String _grade = '';

  @override
  void initState() {
    super.initState();
    _mathAnsweredCtrl.addListener(_recalc);
    _mathTotalCtrl.addListener(_recalc);
    _engAnsweredCtrl.addListener(_recalc);
    _engTotalCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    _mathAnsweredCtrl.dispose();
    _mathTotalCtrl.dispose();
    _engAnsweredCtrl.dispose();
    _engTotalCtrl.dispose();
    _essayTextCtrl.dispose();
    super.dispose();
  }

  void _recalc() {
    final ma = int.tryParse(_mathAnsweredCtrl.text) ?? 0;
    final mt = int.tryParse(_mathTotalCtrl.text) ?? 0;
    final ea = int.tryParse(_engAnsweredCtrl.text) ?? 0;
    final et = int.tryParse(_engTotalCtrl.text) ?? 0;

    setState(() {
      _mathPct = mt > 0 ? (ma / mt) * 100 : 0;
      _engPct = et > 0 ? (ea / et) * 100 : 0;
      _overallPct = (_mathPct + _engPct) / 2;
      _grade = _overallPct >= 80
          ? 'Good'
          : _overallPct >= 50
              ? 'Middle'
              : 'Bad';
    });
  }

  Future<void> _save() async {
    if (_selectedStudent == null) {
      _snack('Please select a student', AppTheme.warning);
      return;
    }
    final ma = int.tryParse(_mathAnsweredCtrl.text);
    final mt = int.tryParse(_mathTotalCtrl.text);
    final ea = int.tryParse(_engAnsweredCtrl.text);
    final et = int.tryParse(_engTotalCtrl.text);

    if (ma == null || mt == null || ea == null || et == null) {
      _snack('Please enter valid numbers', AppTheme.warning);
      return;
    }
    if (ma > mt || ea > et) {
      _snack('Answered cannot exceed total questions', AppTheme.danger);
      return;
    }
    if (_essayGrade == null) {
      _snack('Please select an Essay CEFR grade', AppTheme.warning);
      return;
    }
    if (_isPassed == null) {
      _snack('Please select if the student passed or failed', AppTheme.warning);
      return;
    }

    setState(() => _isSaving = true);
    final result = ExamResult(
      studentId: _selectedStudent!.id,
      mathAnswered: ma,
      mathTotal: mt,
      englishAnswered: ea,
      englishTotal: et,
      essayGrade: _essayGrade!,
      essayText: _essayTextCtrl.text.trim().isEmpty ? null : _essayTextCtrl.text.trim(),
      commentary: _commentaryCtrl.text.trim().isEmpty ? null : _commentaryCtrl.text.trim(),
      isPassed: _isPassed,
      enteredAt: DateTime.now(),
    );
    await DataService.saveResult(result);
    if (mounted) {
      setState(() => _isSaving = false);
      _snack(
          'Results saved for ${_selectedStudent!.fullName}', AppTheme.success);
      _clearForm();
    }
  }

  void _clearForm() {
    setState(() {
      _selectedStudent = null;
      _essayGrade = null;
      _isPassed = null;
      _mathPct = 0;
      _engPct = 0;
      _overallPct = 0;
      _grade = '';
    });
    _mathAnsweredCtrl.clear();
    _mathTotalCtrl.clear();
    _engAnsweredCtrl.clear();
    _engTotalCtrl.clear();
    _essayTextCtrl.clear();
    _commentaryCtrl.clear();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _loadExistingResult(Student student) {
    final existing = DataService.getResult(student.id);
    if (existing != null) {
      _mathAnsweredCtrl.text = existing.mathAnswered.toString();
      _mathTotalCtrl.text = existing.mathTotal.toString();
      _engAnsweredCtrl.text = existing.englishAnswered.toString();
      _engTotalCtrl.text = existing.englishTotal.toString();
      _essayTextCtrl.text = existing.essayText ?? '';
      _commentaryCtrl.text = existing.commentary ?? '';
      setState(() {
        _essayGrade = existing.essayGrade;
        _isPassed = existing.isPassed;
      });
      _recalc();
    } else {
      _mathAnsweredCtrl.clear();
      _mathTotalCtrl.clear();
      _engAnsweredCtrl.clear();
      _engTotalCtrl.clear();
      _essayTextCtrl.clear();
      _commentaryCtrl.clear();
      setState(() {
        _essayGrade = null;
        _isPassed = null;
      });
      _recalc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, __) {
        final students = DataService.getAllStudents();
        final hasCalcData = _mathTotalCtrl.text.isNotEmpty ||
            _engTotalCtrl.text.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.assignment_turned_in_rounded,
                    color: AppTheme.success, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter Exam Results',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  Text('Enter scores and the smart calculator will do the rest',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Form
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student selector
                    _sectionLabel('Select Student', Icons.person_search_rounded),
                    const SizedBox(height: 10),
                    _card(
                      child: students.isEmpty
                          ? Text('No students registered yet.',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textMuted))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Student',
                                    style: GoogleFonts.nunito(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _selectedStudent?.id,
                                  hint: Text('Choose a student...',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textMuted,
                                          fontSize: 14)),
                                  isExpanded: true,
                                  icon: const Icon(Icons.expand_more,
                                      color: AppTheme.textSecondary),
                                  dropdownColor: AppTheme.card,
                                  borderRadius: BorderRadius.circular(24),
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppTheme.surface,
                                    prefixIcon: const Icon(
                                        Icons.person_outline,
                                        color: AppTheme.textMuted,
                                        size: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                          color: AppTheme.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                          color: AppTheme.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                          color: AppTheme.accent, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                  items: students
                                      .map((s) => DropdownMenuItem<String>(
                                          value: s.id,
                                          child: Row(
                                            children: [
                                              Text(s.fullName,
                                                  style: GoogleFonts.nunito(
                                                      color:
                                                          AppTheme.textPrimary,
                                                      fontSize: 14)),
                                              const SizedBox(width: 8),
                                              Text(
                                                  '• ${s.examDate} ${s.examTime} ${s.examRoom}',
                                                  style: GoogleFonts.nunito(
                                                      color: AppTheme.textMuted,
                                                      fontSize: 12)),
                                            ],
                                          )))
                                      .toList(),
                                  onChanged: (id) {
                                    final s = students
                                        .firstWhere((s) => s.id == id);
                                    setState(() => _selectedStudent = s);
                                    _loadExistingResult(s);
                                  },
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Math scores
                    _sectionLabel('Math Score', Icons.calculate_rounded),
                    const SizedBox(height: 10),
                    _card(
                      child: _scoreRow(
                        'Math',
                        _mathAnsweredCtrl,
                        _mathTotalCtrl,
                        _mathPct,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // English scores
                    _sectionLabel(
                        'English Score', Icons.menu_book_rounded),
                    const SizedBox(height: 10),
                    _card(
                      child: Column(
                        children: [
                          _scoreRow(
                            'English',
                            _engAnsweredCtrl,
                            _engTotalCtrl,
                            _engPct,
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppTheme.border, height: 1),
                          const SizedBox(height: 16),
                          // Student Essay
                          Row(
                            children: [
                              const Icon(Icons.notes_rounded, color: AppTheme.textMuted, size: 18),
                              const SizedBox(width: 8),
                              Text('Student Essay',
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _essayTextCtrl,
                            maxLines: null,
                            minLines: 4,
                            style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Paste student essay here...',
                              hintStyle: GoogleFonts.nunito(color: AppTheme.textMuted, fontSize: 14),
                              filled: true,
                              fillColor: AppTheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final sel = _essayTextCtrl.selection;
                                if (sel.isValid && !sel.isCollapsed) {
                                  final text = _essayTextCtrl.text;
                                  final selectedText = sel.textInside(text);
                                  final newText = text.replaceRange(sel.start, sel.end, '[m]$selectedText[/m]');
                                  _essayTextCtrl.value = TextEditingValue(
                                    text: newText,
                                    selection: TextSelection.collapsed(offset: sel.start + 3 + selectedText.length + 4),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Select some text to highlight as a mistake'),
                                      backgroundColor: AppTheme.warning,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.highlight_alt_rounded, size: 16),
                              label: const Text('Highlight Mistake'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.danger,
                                side: const BorderSide(color: AppTheme.danger),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppTheme.border, height: 1),
                          const SizedBox(height: 16),
                          // Essay CEFR
                          Row(
                            children: [
                              const Icon(Icons.edit_note_rounded,
                                  color: AppTheme.textMuted, size: 18),
                              const SizedBox(width: 8),
                              Text('Essay CEFR Level',
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              ...DataService.essayGrades.map((g) =>
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: _cefrChip(g),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.comment_rounded, color: AppTheme.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Text('Commentary / Feedback',
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _commentaryCtrl,
                            maxLines: 3,
                            style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Add feedback for the call center...',
                              hintStyle: GoogleFonts.nunito(color: AppTheme.textMuted, fontSize: 14),
                              filled: true,
                              fillColor: AppTheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: const BorderSide(color: AppTheme.border),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'Status:',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SegmentedButton<bool>(
                              emptySelectionAllowed: true,
                              segments: const [
                                ButtonSegment(
                                  value: true,
                                  icon: Icon(Icons.check_circle_outline, size: 22),
                                  label: Text('Passed'),
                                ),
                                ButtonSegment(
                                  value: false,
                                  icon: Icon(Icons.cancel_outlined, size: 22),
                                  label: Text('Failed'),
                                ),
                              ],
                              selected: _isPassed == null ? {} : {_isPassed!},
                              onSelectionChanged: (set) {
                                setState(() => _isPassed = set.first);
                              },
                              style: ButtonStyle(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                textStyle: WidgetStatePropertyAll(
                                  GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return _isPassed == true
                                        ? AppTheme.success.withValues(alpha: 0.15)
                                        : AppTheme.danger.withValues(alpha: 0.15);
                                  }
                                  return Colors.transparent;
                                }),
                                foregroundColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return _isPassed == true
                                        ? AppTheme.success
                                        : AppTheme.danger;
                                  }
                                  return AppTheme.textMuted;
                                }),
                              ),
                              showSelectedIcon: false,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(
                              _isSaving ? 'Saving...' : 'Save Results'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right: Smart Calculator Panel
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.card,
                            _gradeColor(_grade).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasCalcData
                              ? _gradeColor(_grade).withValues(alpha: 0.4)
                              : AppTheme.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.auto_graph_rounded,
                                    color: AppTheme.success, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Smart Calculator',
                                  style: GoogleFonts.nunito(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Big percent display
                          Center(
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                      begin: 0, end: _overallPct),
                                  duration:
                                      const Duration(milliseconds: 500),
                                  builder: (_, val, __) => Text(
                                    '${val.toStringAsFixed(1)}%',
                                    style: GoogleFonts.nunito(
                                        color: hasCalcData
                                            ? _gradeColor(_grade)
                                            : AppTheme.textMuted,
                                        fontSize: 56,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (hasCalcData && _grade.isNotEmpty)
                                  GradeBadge(grade: _grade)
                                else
                                  Text('Enter scores to calculate',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textMuted,
                                          fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Score bars
                          ScoreBar(label: 'Math', percent: _mathPct),
                          const SizedBox(height: 12),
                          ScoreBar(label: 'English', percent: _engPct),
                          const SizedBox(height: 12),
                          ScoreBar(
                              label: 'Overall', percent: _overallPct),

                          if (_essayGrade != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Essay Level',
                                    style: GoogleFonts.nunito(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13)),
                                CefrBadge(level: _essayGrade!),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Grade key
                          const Divider(color: AppTheme.border),
                          const SizedBox(height: 12),
                          Text('Grade Scale',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          _gradeKey(
                              '≥ 80%', 'Good', AppTheme.success),
                          const SizedBox(height: 4),
                          _gradeKey(
                              '50–79%', 'Middle', AppTheme.warning),
                          const SizedBox(height: 4),
                          _gradeKey(
                              '< 50%', 'Bad', AppTheme.danger),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _scoreRow(
      String subject,
      TextEditingController answeredCtrl,
      TextEditingController totalCtrl,
      double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Answered',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: answeredCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textPrimary, fontSize: 20,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.nunito(
                          color: AppTheme.textMuted, fontSize: 20),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppTheme.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Text('out of',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Questions',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: totalCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: '20',
                      hintStyle: GoogleFonts.nunito(
                          color: AppTheme.textMuted, fontSize: 20),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppTheme.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Live percent badge
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _gradeColor(
                        percent >= 80
                            ? 'Good'
                            : percent >= 50
                                ? 'Middle'
                                : 'Bad')
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${percent.toStringAsFixed(0)}%',
                      style: GoogleFonts.nunito(
                          color: _gradeColor(percent >= 80
                              ? 'Good'
                              : percent >= 50
                                  ? 'Middle'
                                  : 'Bad'),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cefrChip(String level) {
    final isSelected = _essayGrade == level;
    final color = _cefrColor(level);
    return GestureDetector(
      onTap: () => setState(() => _essayGrade = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? color : AppTheme.border, width: 1.5),
        ),
        child: Text(level,
            style: GoogleFonts.nunito(
                color: isSelected ? color : AppTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Color _cefrColor(String level) {
    switch (level) {
      case 'A1':
        return AppTheme.danger;
      case 'A2':
        return AppTheme.warning;
      case 'B1':
        return AppTheme.accentLight;
      default:
        return AppTheme.success;
    }
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'Good':
        return AppTheme.success;
      case 'Middle':
        return AppTheme.warning;
      default:
        return AppTheme.danger;
    }
  }

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.nunito(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }

  Widget _gradeKey(String range, String label, Color color) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(range,
            style: GoogleFonts.nunito(
                color: AppTheme.textMuted, fontSize: 11)),
        const Spacer(),
        Text(label,
            style: GoogleFonts.nunito(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class EssayTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final RegExp exp = RegExp(r'\[m\](.*?)\[/m\]');
    final List<InlineSpan> children = [];
    int start = 0;
    
    for (final Match match in exp.allMatches(text)) {
      if (match.start > start) {
        children.add(TextSpan(text: text.substring(start, match.start), style: style));
      }
      children.add(TextSpan(
        text: match.group(1), // Show the text without the tags, but wait: if we hide tags, cursor gets misaligned.
        // So we MUST render the tags so the cursor matches the text length.
        // We can just make the tags tiny or transparent, but transparent affects selection.
        // Better: render the whole thing including tags but with red background.
        // Actually, let's render tags in a muted color and the text in red.
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
