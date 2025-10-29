// lib/data/models/question.dart
class Question {
  final String id;
  final String groupId;
  final String questionText;
  final int answer;
  final String? quizId; // ✅ إضافة هنا

  Question({
    required this.id,
    required this.groupId,
    required this.questionText,
    required this.answer,
    this.quizId, // ✅ إضافة هنا
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      questionText: map['question_text'] as String,
      answer: map['answer'] as int,
      quizId: map['quiz_id'] as String?, // ✅ إضافة هنا
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'question_text': questionText,
      'answer': answer,
      'quiz_id': quizId, // ✅ إضافة هنا
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'group_id': groupId,
      'question_text': questionText,
      'answer': answer,
      'quiz_id': quizId, // ✅ إضافة هنا
    };
  }
}
