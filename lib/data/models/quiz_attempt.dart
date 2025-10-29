// lib/data/models/quiz_attempt.dart
class QuizAttempt {
  final String id;
  final String studentId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizAttempt({
    required this.id,
    required this.studentId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      quizId: map['quiz_id'] as String,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'student_id': studentId,
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
    };
  }

  double get percentage => (score / totalQuestions) * 100;

  String get grade {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }
}
