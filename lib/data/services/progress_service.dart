import '../../main.dart'; // للوصول إلى متغير supabase
import '../models/student_progress.dart';

class ProgressService {
  // تسجيل إجابة الطالب (تقدم)
  Future<void> recordAnswer({
    required String questionId,
    required bool isCorrect,
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
      createdAt: DateTime.now(),
    );

    await supabase.from('student_progress').insert(newProgress.toInsertMap());
  }

  // --- دالات المدير (التي تستخدم في التقارير) ---

  // دالة جديدة: جلب إحصائيات الأداء الكلية للطالب
  Future<Map<String, dynamic>> getStudentPerformanceSummary(
    String studentId,
  ) async {
    // جلب جميع محاولات الطالب
    final List<Map<String, dynamic>> attempts = await supabase
        .from('student_progress')
        .select('is_correct, question_id')
        .eq('student_id', studentId);

    if (attempts.isEmpty) {
      return {'total_attempts': 0, 'correct_count': 0, 'accuracy': 0.0};
    }

    final int totalAttempts = attempts.length;
    // حساب عدد الإجابات الصحيحة
    final int correctCount = attempts
        .where((attempt) => attempt['is_correct'] == true)
        .length;

    final double accuracy = (correctCount / totalAttempts) * 100;

    return {
      'total_attempts': totalAttempts,
      'correct_count': correctCount,
      // تقريب الدقة إلى منزلتين عشريتين
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
