import '../../main.dart'; // للوصول إلى متغير supabase
import '../models/question.dart'; // للتأكد من استيراد نموذج السؤال

class QuestionService {
  // الحصول على جميع الأسئلة لمجموعة محددة
  Future<List<Question>> getGroupQuestions(String groupId) async {
    // جلب الأسئلة التي تطابق group_id المحدد
    final List<Map<String, dynamic>> response = await supabase
        .from('questions')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: true); // ترتيب حسب الأقدم

    return response.map((map) => Question.fromMap(map)).toList();
  }

  // إنشاء سؤال جديد
  Future<void> createQuestion({
    required String groupId,
    required String questionText,
    required int answer,
  }) async {
    final Question newQuestion = Question(
      id: '', // يتم تجاهله عند الإدخال
      groupId: groupId,
      questionText: questionText,
      answer: answer,
    );

    // نستخدم toInsertMap لإرسال البيانات المطلوبة لـ Supabase
    await supabase.from('questions').insert(newQuestion.toInsertMap());
  }

  // تعديل سؤال موجود
  Future<void> updateQuestion({
    required String questionId,
    required String questionText,
    required int answer,
  }) async {
    // تحديث الأعمدة المحددة للسؤال الذي يطابق questionId
    await supabase
        .from('questions')
        .update({'question_text': questionText, 'answer': answer})
        .eq('id', questionId);
  }

  // حذف سؤال
  Future<void> deleteQuestion(String questionId) async {
    // حذف الصف الذي يطابق questionId
    await supabase.from('questions').delete().eq('id', questionId);
  }
}
