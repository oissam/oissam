import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class ManageScheduleScreen extends StatefulWidget {
  ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _timeCtrl = TextEditingController();

  // Local state — updates instantly without waiting for Supabase
  List<String> _times = [];

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    // Load initial times
    _times = DataService.getTimesForDate(_dateStr);
    // Listen for external changes (other devices / streams)
    DataService.notifier.addListener(_onExternalDataChange);
  }

  @override
  void dispose() {
    DataService.notifier.removeListener(_onExternalDataChange);
    _timeCtrl.dispose();
    super.dispose();
  }

  /// Called when Supabase stream fires (e.g. another device changed data).
  void _onExternalDataChange() {
    if (mounted) {
      setState(() {
        _times = DataService.getTimesForDate(_dateStr);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      _timeCtrl.text = '$hh:$mm';
    }
  }

  Future<void> _addTime() async {
    final time = _timeCtrl.text.trim();
    if (time.isEmpty) return;

    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!regex.hasMatch(time)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid time format. Use HH:MM')),
        );
      }
      return;
    }

    if (_times.contains(time)) return; // already added

    // ✅ Update UI IMMEDIATELY — no waiting for Supabase
    setState(() {
      _times = [..._times, time]..sort();
    });
    _timeCtrl.clear();

    // Persist to Supabase in the background
    await DataService.addTimeToDate(_dateStr, time);
  }

  Future<void> _removeTime(String time) async {
    // ✅ Update UI IMMEDIATELY
    setState(() {
      _times = _times.where((t) => t != time).toList();
    });

    // Persist to Supabase in the background
    await DataService.removeTimeFromDate(_dateStr, time);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Calendar
          Expanded(
            flex: 2,
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
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar01,
                        color: AppTheme.examinatorColor,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage Exam Schedule',
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        Text('Select a date to view and manage available times.',
                            style: GoogleFonts.nunito(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                    lastDay: DateTime(2100),
                    focusedDay: _selectedDate,
                    currentDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _times = DataService.getTimesForDate(_dateStr);
                        
                        if (selectedDay.weekday == DateTime.monday || 
                            selectedDay.weekday == DateTime.wednesday || 
                            selectedDay.weekday == DateTime.friday) {
                          _timeCtrl.text = '14:00';
                        } else if (selectedDay.weekday == DateTime.tuesday || 
                                   selectedDay.weekday == DateTime.thursday || 
                                   selectedDay.weekday == DateTime.saturday) {
                          _timeCtrl.text = '10:00';
                        } else {
                          _timeCtrl.clear();
                        }
                      });
                    },
                    eventLoader: (day) {
                      final ds = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                      return DataService.getTimesForDate(ds).isNotEmpty ? ['exam'] : [];
                    },
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: AppTheme.examinatorColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.examinatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 32),
          // Right side: Times for selected date
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Times for $_dateStr',
                      style: GoogleFonts.nunito(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 16),
                  // Add time input
                  Row(
                    children: [
                      Expanded(
                        child: StyledTextField(
                          controller: _timeCtrl,
                          label: 'Add Time',
                          hint: 'Pick time',
                          icon: Icons.access_time,
                          readOnly: true,
                          onTap: _pickTime,
                        ),
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: IconButton(
                          onPressed: _addTime,
                          icon: Icon(Icons.add_circle),
                          color: AppTheme.accent,
                          iconSize: 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (_times.isEmpty)
                    Center(
                      child: Text('No times scheduled.',
                          style: GoogleFonts.nunito(
                              color: AppTheme.textMuted, fontSize: 14)),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _times.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_filled,
                                    color: AppTheme.accent, size: 20),
                                SizedBox(width: 12),
                                Text(_times[i],
                                    style: GoogleFonts.nunito(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: AppTheme.danger, size: 20),
                                  onPressed: () => _removeTime(_times[i]),
                                ),
                              ],
                            ),
                          );
                        },
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
}


