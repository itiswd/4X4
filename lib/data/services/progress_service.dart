// lib/data/services/progress_service.dart
import '../../main.dart';
import '../models/quiz_attempt.dart';
import '../models/student_progress.dart';

class ProgressService {
  // ✅ تسجيل إجابة الطالب مع حفظ الإجابة نفسها
  Future<void> recordAnswer({
    required String questionId,
    required bool isCorrect,
    required int studentAnswer,
  }) async {
    final String? studentId = supabase.auth.currentUser?.id;
    if (studentId == null) {
      throw Exception('Student user not logged in.');
    }

    final newProgress = StudentProgress(
      id: '',
      studentId: studentId,
      questionId: questionId,
      isCorrect: isCorrect,
      studentAnswer: studentAnswer,
      createdAt: DateTime.now(),
    );

    await supabase.from('student_progress').insert(newProgress.toInsertMap());
  }

  // ✅ حفظ محاولة كويز
  Future<void> recordQuizAttempt({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    final studentId = supabase.auth.currentUser?.id;
    if (studentId == null) throw Exception('Student not logged in');

    final attempt = QuizAttempt(
      id: '',
      studentId: studentId,
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions,
      completedAt: DateTime.now(),
    );

    await supabase.from('quiz_attempts').insert(attempt.toInsertMap());
  }

  // ✅ جلب محاولات طالب في كويز معين
  Future<List<QuizAttempt>> getStudentQuizAttempts(
    String studentId,
    String quizId,
  ) async {
    final response = await supabase
        .from('quiz_attempts')
        .select()
        .eq('student_id', studentId)
        .eq('quiz_id', quizId)
        .order('completed_at', ascending: false);

    return (response as List)
        .map((map) => QuizAttempt.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // ✅ جلب كل محاولات طالب
  Future<List<Map<String, dynamic>>> getStudentAllQuizAttempts(
    String studentId,
  ) async {
    final response = await supabase
        .from('quiz_attempts')
        .select('''
          *,
          quizzes(title, quiz_type, operation_type)
        ''')
        .eq('student_id', studentId)
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ✅ جلب محاولات كويز معين (لكل الطلاب)
  Future<List<Map<String, dynamic>>> getQuizAttempts(String quizId) async {
    final response = await supabase
        .from('quiz_attempts')
        .select('''
          *,
          profiles(full_name)
        ''')
        .eq('quiz_id', quizId)
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // دالة جلب إحصائيات الأداء الكلية للطالب
  Future<Map<String, dynamic>> getStudentPerformanceSummary(
    String studentId,
  ) async {
    final List<Map<String, dynamic>> attempts = await supabase
        .from('student_progress')
        .select('is_correct, question_id')
        .eq('student_id', studentId);

    if (attempts.isEmpty) {
      return {'total_attempts': 0, 'correct_count': 0, 'accuracy': 0.0};
    }

    final int totalAttempts = attempts.length;
    final int correctCount = attempts
        .where((attempt) => attempt['is_correct'] == true)
        .length;

    final double accuracy = (correctCount / totalAttempts) * 100;

    return {
      'total_attempts': totalAttempts,
      'correct_count': correctCount,
      'accuracy': double.parse(accuracy.toStringAsFixed(2)),
    };
  }

  // جلب تقدم طالب معين في جميع الأسئلة
  Future<List<StudentProgress>> getStudentProgress(String studentId) async {
    final List<Map<String, dynamic>> response = await supabase
        .from('student_progress')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return response.map((map) => StudentProgress.fromMap(map)).toList();
  }
}
