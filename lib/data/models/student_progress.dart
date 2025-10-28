class StudentProgress {
  final String id;
  final String studentId;
  final String questionId;
  final bool isCorrect;
  final DateTime createdAt;

  StudentProgress({
    required this.id,
    required this.studentId,
    required this.questionId,
    required this.isCorrect,
    required this.createdAt,
  });

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      questionId: map['question_id'] as String,
      isCorrect: map['is_correct'] as bool,
      // تحويل الـ timestamp إلى DateTime
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // لإنشاء إدخال جديد
  Map<String, dynamic> toInsertMap() {
    return {
      'student_id': studentId,
      'question_id': questionId,
      'is_correct': isCorrect,
      // Supabase سيتولى أمر created_at افتراضيًا
    };
  }
}
