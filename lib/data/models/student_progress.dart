class StudentProgress {
  final String id;
  final String studentId;
  final String questionId;
  final bool isCorrect;
  final int? studentAnswer; // ✅ الحقل الجديد
  final DateTime createdAt;

  StudentProgress({
    required this.id,
    required this.studentId,
    required this.questionId,
    required this.isCorrect,
    this.studentAnswer, // ✅ إضافة هنا
    required this.createdAt,
  });

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      questionId: map['question_id'] as String,
      isCorrect: map['is_correct'] as bool,
      studentAnswer: map['student_answer'] as int?, // ✅ قراءة القيمة
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // لإنشاء إدخال جديد
  Map<String, dynamic> toInsertMap() {
    return {
      'student_id': studentId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'student_answer': studentAnswer, // ✅ إرسال القيمة
    };
  }
}
