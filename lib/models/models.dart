// Data Models - No Hive annotations needed for simple JSON persistence

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String studentClass;
  final String language;
  final String phone1;
  final String? phone2;
  final String examDate;
  final String examTime;
  final String examRoom;
  final DateTime registeredAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.studentClass,
    required this.language,
    required this.phone1,
    this.phone2,
    required this.examDate,
    required this.examTime,
    required this.examRoom,
    required this.registeredAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) => other is Student && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'student_class': studentClass,
        'language': language,
        'phone1': phone1,
        'phone2': phone2,
        'exam_date': examDate,
        'exam_time': examTime,
        'exam_room': examRoom,
        'registered_at': registeredAt.toIso8601String(),
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        firstName: json['first_name'] ?? json['firstName'], // Fallback for old Hive data if needed, but not required for new Supabase DB
        lastName: json['last_name'] ?? json['lastName'],
        studentClass: json['student_class'] ?? json['studentClass'],
        language: json['language'],
        phone1: json['phone1'],
        phone2: json['phone2'],
        examDate: json['exam_date'] ?? json['examDate'],
        examTime: json['exam_time'] ?? json['examTime'],
        examRoom: json['exam_room'] ?? json['examRoom'],
        registeredAt: DateTime.parse(json['registered_at'] ?? json['registeredAt']),
      );
}

class ExamResult {
  final String studentId;
  final int mathAnswered;
  final int mathTotal;
  final int englishAnswered;
  final int englishTotal;
  final String essayGrade; // A1, A2, B1, B2
  final String? essayText; // Pasted essay text
  final bool? isPassed; // Manual Pass/Fail override
  final String? commentary; // Examinator feedback
  final DateTime enteredAt;

  ExamResult({
    required this.studentId,
    required this.mathAnswered,
    required this.mathTotal,
    required this.englishAnswered,
    required this.englishTotal,
    required this.essayGrade,
    this.essayText,
    this.isPassed,
    this.commentary,
    required this.enteredAt,
  });

  double get mathPercent =>
      mathTotal > 0 ? (mathAnswered / mathTotal) * 100 : 0;
  double get englishPercent =>
      englishTotal > 0 ? (englishAnswered / englishTotal) * 100 : 0;
  double get overallPercent => (mathPercent + englishPercent) / 2;

  String get grade {
    if (overallPercent >= 80) return 'Good';
    if (overallPercent >= 50) return 'Middle';
    return 'Bad';
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'math_answered': mathAnswered,
        'math_total': mathTotal,
        'english_answered': englishAnswered,
        'english_total': englishTotal,
        'essay_grade': essayGrade,
        'essay_text': essayText,
        'is_passed': isPassed,
        'commentary': commentary,
        'entered_at': enteredAt.toIso8601String(),
      };

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
        studentId: json['student_id'] ?? json['studentId'],
        mathAnswered: json['math_answered'] ?? json['mathAnswered'],
        mathTotal: json['math_total'] ?? json['mathTotal'],
        englishAnswered: json['english_answered'] ?? json['englishAnswered'],
        englishTotal: json['english_total'] ?? json['englishTotal'],
        essayGrade: json['essay_grade'] ?? json['essayGrade'],
        essayText: json['essay_text'] ?? json['essayText'],
        isPassed: json['is_passed'] ?? json['isPassed'],
        commentary: json['commentary'],
        enteredAt: DateTime.parse(json['entered_at'] ?? json['enteredAt']),
      );
}
