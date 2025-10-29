// lib/data/models/quiz.dart

enum QuizType { manual, auto }

enum OperationType { multiply, add, subtract, divide, mixed }

class Quiz {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final QuizType quizType;
  final OperationType? operationType;
  final int? tableNumber;
  final int? minRange;
  final int? maxRange;
  final int? questionsCount;
  final DateTime createdAt;
  final String adminId;

  Quiz({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.quizType,
    this.operationType,
    this.tableNumber,
    this.minRange,
    this.maxRange,
    this.questionsCount,
    required this.createdAt,
    required this.adminId,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      quizType: _parseQuizType(map['quiz_type'] as String),
      operationType: map['operation_type'] != null
          ? _parseOperationType(map['operation_type'] as String)
          : null,
      tableNumber: map['table_number'] as int?,
      minRange: map['min_range'] as int?,
      maxRange: map['max_range'] as int?,
      questionsCount: map['questions_count'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      adminId: map['admin_id'] as String,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'group_id': groupId,
      'title': title,
      'description': description,
      'quiz_type': quizType.name,
      'operation_type': operationType?.name,
      'table_number': tableNumber,
      'min_range': minRange,
      'max_range': maxRange,
      'questions_count': questionsCount,
      'admin_id': adminId,
    };
  }

  static QuizType _parseQuizType(String type) {
    return QuizType.values.firstWhere((e) => e.name == type);
  }

  static OperationType _parseOperationType(String type) {
    return OperationType.values.firstWhere((e) => e.name == type);
  }

  // Helper methods
  String get operationTypeArabic {
    switch (operationType) {
      case OperationType.multiply:
        return 'ضرب';
      case OperationType.add:
        return 'جمع';
      case OperationType.subtract:
        return 'طرح';
      case OperationType.divide:
        return 'قسمة';
      case OperationType.mixed:
        return 'منوع';
      default:
        return 'غير محدد';
    }
  }

  String get quizTypeArabic {
    return quizType == QuizType.manual ? 'يدوي' : 'تلقائي';
  }
}
