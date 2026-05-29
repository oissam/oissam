import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DataService {
  static final _supabase = Supabase.instance.client;

  static const List<String> classes = ['5', '6', '7', '8', '9', '10', '11'];
  static const List<String> languages = ['Uzbek', 'Russian'];
  static const List<String> rooms = ['Room 1', 'Room 2', 'Room 3'];
  static const List<String> essayGrades = ['A1', 'A2', 'B1', 'B2'];

  /// Fires every time any in-memory data changes (incremented counter).
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  /// True while the initial data is being fetched.
  static final ValueNotifier<bool> isLoading = ValueNotifier(true);

  static List<Student> _students = [];
  static List<ExamResult> _results = [];
  static Map<String, ExamResult> _resultsMap = {};
  static Map<String, List<String>> _schedules = {};

  // ── Init ─────────────────────────────────────────────────────────────────

  /// Subscribes to all three realtime streams and waits until EACH has
  /// delivered its first batch of data (or timed out after 10 seconds).
  static Future<void> init() async {
    isLoading.value = true;

    // Three completers that each resolve on first data event
    final studentsCompleter = Completer<void>();
    final resultsCompleter = Completer<void>();
    final schedulesCompleter = Completer<void>();

    // ── Students ──────────────────────────────────────────────────────────
    _supabase
        .from('students')
        .stream(primaryKey: ['id'])
        .order('registered_at', ascending: false)
        .listen(
          (data) {
            _students = data.map((e) => Student.fromJson(e)).toList();
            notifier.value++;
            if (!studentsCompleter.isCompleted) studentsCompleter.complete();
          },
          onError: (e) {
            debugPrint('[DataService] students stream error: $e');
            if (!studentsCompleter.isCompleted) studentsCompleter.complete();
          },
        );

    // ── Exam Results ──────────────────────────────────────────────────────
    // NOTE: primaryKey must match the actual PK of the table.
    // If exam_results uses student_id as PK leave it as-is.
    // If there's an 'id' column that's the PK, change to ['id'].
    _supabase
        .from('exam_results')
        .stream(primaryKey: ['student_id'])
        .order('entered_at', ascending: false)
        .listen(
          (data) {
            _results = data.map((e) => ExamResult.fromJson(e)).toList();
            _resultsMap = {for (final r in _results) r.studentId: r};
            notifier.value++;
            if (!resultsCompleter.isCompleted) resultsCompleter.complete();
          },
          onError: (e) {
            debugPrint('[DataService] exam_results stream error: $e');
            if (!resultsCompleter.isCompleted) resultsCompleter.complete();
          },
        );

    // ── Schedules ─────────────────────────────────────────────────────────
    _supabase
        .from('schedules')
        .stream(primaryKey: ['exam_date'])
        .listen(
          (data) {
            _schedules = {};
            for (final row in data) {
              final date = row['exam_date'] as String;
              final times = (row['exam_times'] as List<dynamic>).cast<String>();
              _schedules[date] = times;
            }
            notifier.value++;
            if (!schedulesCompleter.isCompleted) schedulesCompleter.complete();
          },
          onError: (e) {
            debugPrint('[DataService] schedules stream error: $e');
            if (!schedulesCompleter.isCompleted) schedulesCompleter.complete();
          },
        );

    // Wait for all three — but cap at 10 s so the app doesn't hang forever
    await Future.wait([
      studentsCompleter.future,
      resultsCompleter.future,
      schedulesCompleter.future,
    ]).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('[DataService] init timed out waiting for streams');
        if (!studentsCompleter.isCompleted) studentsCompleter.complete();
        if (!resultsCompleter.isCompleted) resultsCompleter.complete();
        if (!schedulesCompleter.isCompleted) schedulesCompleter.complete();
        return [];
      },
    );

    isLoading.value = false;
    debugPrint('[DataService] Ready — '
        'students=${_students.length}, '
        'results=${_results.length}, '
        'schedules=${_schedules.length}');
  }

  // ──────────────── STUDENTS ────────────────

  static List<Student> getAllStudents() => List.unmodifiable(_students);

  static Future<void> addStudent(Student student) async {
    // Optimistic update
    _students = [student, ..._students];
    notifier.value++;
    try {
      await _supabase.from('students').insert(student.toJson());
    } catch (e) {
      // Rollback
      _students = _students.where((s) => s.id != student.id).toList();
      notifier.value++;
      debugPrint('[DataService] addStudent error: $e');
      rethrow;
    }
  }

  static Future<void> deleteStudent(String id) async {
    final backup = _students.where((s) => s.id == id).toList();
    _students = _students.where((s) => s.id != id).toList();
    notifier.value++;
    try {
      await _supabase.from('students').delete().eq('id', id);
    } catch (e) {
      // Rollback
      _students = [...backup, ..._students];
      notifier.value++;
      debugPrint('[DataService] deleteStudent error: $e');
      rethrow;
    }
  }

  static Student? getStudent(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ──────────────── RESULTS ────────────────

  static List<ExamResult> getAllResults() => List.unmodifiable(_results);

  static Future<void> saveResult(ExamResult result) async {
    // Optimistic update
    final oldResults = List<ExamResult>.from(_results);
    final oldMap = Map<String, ExamResult>.from(_resultsMap);
    _results = [result, ..._results.where((r) => r.studentId != result.studentId)];
    _resultsMap = {for (final r in _results) r.studentId: r};
    notifier.value++;
    try {
      await _supabase.from('exam_results').upsert(result.toJson());
    } catch (e) {
      // Rollback
      _results = oldResults;
      _resultsMap = oldMap;
      notifier.value++;
      debugPrint('[DataService] saveResult error: $e');
      rethrow;
    }
  }

  static ExamResult? getResult(String studentId) => _resultsMap[studentId];

  static bool hasResult(String studentId) => _resultsMap.containsKey(studentId);

  // ──────────────── SCHEDULES ────────────────

  static List<String> getAvailableDates() => _schedules.keys.toList()..sort();

  static List<String> getTimesForDate(String date) =>
      (_schedules[date]?.toList() ?? [])..sort();

  static bool _isAtLeastOneHourAway(String dateStr, String timeStr, DateTime now) {
    try {
      final parts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      if (parts.length == 3 && timeParts.length == 2) {
        final examDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        return examDate.difference(now).inMinutes >= 60;
      }
    } catch (_) {}
    return true; // Default to true if parsing fails
  }

  static List<String> getRegisterableDates() {
    final now = DateTime.now();
    return _schedules.keys.where((dateStr) {
      final times = _schedules[dateStr] ?? [];
      for (final timeStr in times) {
        if (_isAtLeastOneHourAway(dateStr, timeStr, now)) return true;
      }
      return false;
    }).toList()..sort();
  }

  static List<String> getRegisterableTimesForDate(String date) {
    final now = DateTime.now();
    final times = _schedules[date]?.toList() ?? [];
    return times.where((timeStr) => _isAtLeastOneHourAway(date, timeStr, now)).toList()..sort();
  }

  static List<String> getAllTimes() {
    final Set<String> allTimes = {};
    for (final times in _schedules.values) {
      allTimes.addAll(times);
    }
    return allTimes.toList()..sort();
  }

  static Future<void> addTimeToDate(String date, String time) async {
    final currentTimes = getTimesForDate(date);
    if (currentTimes.contains(time)) return;
    final newTimes = List<String>.from(currentTimes)..add(time);
    // Optimistic update
    final updated = Map<String, List<String>>.from(_schedules)..[date] = newTimes;
    _schedules = updated;
    notifier.value++;
    try {
      await _supabase
          .from('schedules')
          .upsert({'exam_date': date, 'exam_times': newTimes});
    } catch (e) {
      // Rollback
      final rollback = Map<String, List<String>>.from(_schedules)..[date] = currentTimes;
      _schedules = rollback;
      notifier.value++;
      debugPrint('[DataService] addTimeToDate error: $e');
      rethrow;
    }
  }

  static Future<void> removeTimeFromDate(String date, String time) async {
    final oldTimes = getTimesForDate(date);
    final newTimes = List<String>.from(oldTimes)..remove(time);
    // Optimistic update
    final updated = Map<String, List<String>>.from(_schedules);
    if (newTimes.isEmpty) {
      updated.remove(date);
    } else {
      updated[date] = newTimes;
    }
    _schedules = updated;
    notifier.value++;
    try {
      if (newTimes.isEmpty) {
        await _supabase.from('schedules').delete().eq('exam_date', date);
      } else {
        await _supabase
            .from('schedules')
            .upsert({'exam_date': date, 'exam_times': newTimes});
      }
    } catch (e) {
      // Rollback
      final rollback = Map<String, List<String>>.from(_schedules)..[date] = oldTimes;
      _schedules = rollback;
      notifier.value++;
      debugPrint('[DataService] removeTimeFromDate error: $e');
      rethrow;
    }
  }

  static Future<void> deleteDate(String date) async {
    final backup = _schedules[date];
    final updated = Map<String, List<String>>.from(_schedules)..remove(date);
    _schedules = updated;
    notifier.value++;
    try {
      await _supabase.from('schedules').delete().eq('exam_date', date);
    } catch (e) {
      // Rollback
      if (backup != null) {
        final rollback = Map<String, List<String>>.from(_schedules)..[date] = backup;
        _schedules = rollback;
        notifier.value++;
      }
      debugPrint('[DataService] deleteDate error: $e');
      rethrow;
    }
  }
}
