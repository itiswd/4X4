// lib/data/services/quiz_service.dart
import 'dart:math';

import '../../main.dart';
import '../models/question.dart';
import '../models/quiz.dart';

class QuizService {
  // جلب كويزات مجموعة معينة
  Future<List<Quiz>> getGroupQuizzes(String groupId) async {
    final response = await supabase
        .from('quizzes')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Quiz.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // إنشاء كويز يدوي (فاضي)
  Future<String> createManualQuiz({
    required String groupId,
    required String title,
    String? description,
  }) async {
    final adminId = supabase.auth.currentUser?.id;
    if (adminId == null) throw Exception('Admin not logged in');

    final quiz = Quiz(
      id: '',
      groupId: groupId,
      title: title,
      description: description,
      quizType: QuizType.manual,
      createdAt: DateTime.now(),
      adminId: adminId,
    );

    final response = await supabase
        .from('quizzes')
        .insert(quiz.toInsertMap())
        .select()
        .single();

    return response['id'] as String;
  }

  // إنشاء كويز تلقائي مع الأسئلة
  Future<String> createAutoQuiz({
    required String groupId,
    required String title,
    String? description,
    required OperationType operationType,
    int? tableNumber,
    int? minRange,
    int? maxRange,
    required int questionsCount,
  }) async {
    final adminId = supabase.auth.currentUser?.id;
    if (adminId == null) throw Exception('Admin not logged in');

    // 1. إنشاء الكويز
    final quiz = Quiz(
      id: '',
      groupId: groupId,
      title: title,
      description: description,
      quizType: QuizType.auto,
      operationType: operationType,
      tableNumber: tableNumber,
      minRange: minRange,
      maxRange: maxRange,
      questionsCount: questionsCount,
      createdAt: DateTime.now(),
      adminId: adminId,
    );

    final quizResponse = await supabase
        .from('quizzes')
        .insert(quiz.toInsertMap())
        .select()
        .single();

    final quizId = quizResponse['id'] as String;

    // 2. توليد الأسئلة
    final questions = _generateQuestions(
      quizId: quizId,
      groupId: groupId,
      operationType: operationType,
      tableNumber: tableNumber,
      minRange: minRange ?? 1,
      maxRange: maxRange ?? 10,
      count: questionsCount,
    );

    // 3. إدراج الأسئلة
    final questionsToInsert = questions.map((q) => q.toInsertMap()).toList();
    await supabase.from('questions').insert(questionsToInsert);

    return quizId;
  }

  // توليد الأسئلة حسب النوع
  List<Question> _generateQuestions({
    required String quizId,
    required String groupId,
    required OperationType operationType,
    int? tableNumber,
    required int minRange,
    required int maxRange,
    required int count,
  }) {
    final random = Random();
    final questions = <Question>[];
    final usedQuestions = <String>{};

    while (questions.length < count) {
      int num1, num2;
      String operation;
      int answer;

      if (operationType == OperationType.mixed) {
        // اختيار عملية عشوائية
        final ops = [
          OperationType.multiply,
          OperationType.add,
          OperationType.subtract,
        ];
        operationType = ops[random.nextInt(ops.length)];
      }

      switch (operationType) {
        case OperationType.multiply:
          if (tableNumber != null) {
            num1 = tableNumber;
            num2 = random.nextInt(maxRange - minRange + 1) + minRange;
          } else {
            num1 = random.nextInt(maxRange - minRange + 1) + minRange;
            num2 = random.nextInt(maxRange - minRange + 1) + minRange;
          }
          operation = '×';
          answer = num1 * num2;
          break;

        case OperationType.add:
          num1 = random.nextInt(maxRange - minRange + 1) + minRange;
          num2 = random.nextInt(maxRange - minRange + 1) + minRange;
          operation = '+';
          answer = num1 + num2;
          break;

        case OperationType.subtract:
          num1 = random.nextInt(maxRange - minRange + 1) + minRange;
          num2 = random.nextInt(num1) + 1; // num2 أصغر من num1
          operation = '-';
          answer = num1 - num2;
          break;

        case OperationType.divide:
          // نختار answer الأول ثم نحسب num1
          answer = random.nextInt(maxRange - minRange + 1) + minRange;
          num2 = random.nextInt(9) + 2; // من 2 إلى 10
          num1 = answer * num2;
          operation = '÷';
          break;

        default:
          continue;
      }

      final questionText = '$num1 $operation $num2';

      // تجنب التكرار
      if (usedQuestions.contains(questionText)) continue;
      usedQuestions.add(questionText);

      questions.add(
        Question(
          id: '',
          groupId: groupId,
          questionText: questionText,
          answer: answer,
          quizId: quizId,
        ),
      );
    }

    return questions;
  }

  // حذف كويز
  Future<void> deleteQuiz(String quizId) async {
    await supabase.from('quizzes').delete().eq('id', quizId);
    // الأسئلة هتتحذف تلقائياً بسبب CASCADE
  }

  // تحديث كويز
  Future<void> updateQuiz({
    required String quizId,
    required String title,
    String? description,
  }) async {
    await supabase
        .from('quizzes')
        .update({'title': title, 'description': description})
        .eq('id', quizId);
  }

  // جلب عدد الأسئلة في كويز
  Future<int> getQuizQuestionsCount(String quizId) async {
    final response = await supabase
        .from('questions')
        .select('id')
        .eq('quiz_id', quizId);
    return (response as List).length;
  }
}
