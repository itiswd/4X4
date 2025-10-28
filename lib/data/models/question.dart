class Question {
  final String id;
  final String groupId;
  final String questionText;
  final int answer;

  Question({
    required this.id,
    required this.groupId,
    required this.questionText,
    required this.answer,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      questionText: map['question_text'] as String,
      answer: map['answer'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'question_text': questionText,
      'answer': answer,
    };
  }

  // لإنشاء سؤال جديد قبل إرساله لـ Supabase (بدون ID)
  Map<String, dynamic> toInsertMap() {
    return {
      'group_id': groupId,
      'question_text': questionText,
      'answer': answer,
    };
  }
}
