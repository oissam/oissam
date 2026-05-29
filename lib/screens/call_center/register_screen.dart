import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterStudentScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const RegisterStudentScreen({super.key, this.onSaved});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _commentaryCtrl = TextEditingController();

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  String? _selectedClass;
  String? _selectedLanguage;
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedRoom;
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _commentaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null ||
        _selectedLanguage == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final student = Student(
      id: const Uuid().v4(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      studentClass: _selectedClass!,
      language: _selectedLanguage!,
      phone1: _phone1Ctrl.text.trim(),
      phone2: _phone2Ctrl.text.trim().isEmpty ? null : _phone2Ctrl.text.trim(),
      examDate: _selectedDate!,
      examTime: _selectedTime!,
      examRoom: _selectedRoom!,
      registeredAt: DateTime.now(),
      commentary: _commentaryCtrl.text.trim().isEmpty ? null : _commentaryCtrl.text.trim(),
    );

    await DataService.addStudent(student);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${student.fullName} registered successfully!'),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      _clearForm();
      widget.onSaved?.call();
    }
  }

  void _clearForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _phone1Ctrl.clear();
    _phone2Ctrl.clear();
    _commentaryCtrl.clear();
    setState(() {
      _selectedClass = null;
      _selectedLanguage = null;
      _selectedDate = null;
      _selectedTime = null;
      _selectedRoom = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DataService.notifier,
      builder: (context, _, __) {
        final dates = DataService.getRegisterableDates();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Student',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Add a new student to the exam schedule',
                          style: GoogleFonts.nunito(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Section: Personal Info
                _sectionHeader('Personal Information', Icons.person_outline),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StyledTextField(
                        label: 'First Name',
                        controller: _firstNameCtrl,
                        hint: 'e.g. Amir',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Last Name',
                        controller: _lastNameCtrl,
                        hint: 'e.g. Karimov',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      StyledDropdown<String>(
                        label: 'Grade',
                        value: _selectedClass,
                        hint: 'Select grade',
                        icon: Icons.class_outlined,
                        items: DataService.classes
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text('Grade $c'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClass = v),
                      ),
                      const SizedBox(height: 16),
                      StyledDropdown<String>(
                        label: 'Language',
                        value: _selectedLanguage,
                        hint: 'Select language',
                        icon: Icons.language_outlined,
                        items: DataService.languages
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedLanguage = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Contact
                _sectionHeader('Contact Information', Icons.phone_outlined),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StyledTextField(
                        label: 'Phone Number 1',
                        controller: _phone1Ctrl,
                        hint: '+998 90 123 4567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneFormatter],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (v.length < 16) {
                            return 'Incomplete phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Phone Number 2',
                        controller: _phone2Ctrl,
                        hint: '+998 90 765 4321',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneFormatter],
                        required: false,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 16) {
                            return 'Incomplete phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Commentary (Optional)',
                        controller: _commentaryCtrl,
                        hint: 'Notes, special requests, etc.',
                        icon: Icons.notes,
                        required: false,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Exam Schedule
                _sectionHeader('Exam Schedule', Icons.calendar_month_rounded),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StyledDropdown<String>(
                        label: 'Exam Date',
                        value: _selectedDate,
                        hint: 'Select date',
                        icon: Icons.calendar_today_outlined,
                        items: dates
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedDate = v;
                          _selectedTime = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      StyledDropdown<String>(
                        label: 'Exam Time',
                        value: _selectedTime,
                        hint: 'Select time',
                        icon: Icons.access_time_outlined,
                        items: (_selectedDate == null ? <String>[] : DataService.getRegisterableTimesForDate(_selectedDate!))
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTime = v),
                      ),
                      const SizedBox(height: 16),
                      StyledDropdown<String>(
                        label: 'Room',
                        value: _selectedRoom,
                        hint: 'Select room',
                        icon: Icons.meeting_room_outlined,
                        items: DataService.rooms
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRoom = v),
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
                      label: const Text('Clear Form'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 18),
                      label: Text(_isSaving ? 'Saving...' : 'Register Student'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}
