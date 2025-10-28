import 'package:educational_app/data/services/question_service.dart';
import 'package:educational_app/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../../../data/models/question.dart';
import '../../../data/services/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final String groupId;
  const QuizScreen({super.key, required this.groupId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionService _questionService = QuestionService();
  final ProgressService _progressService = ProgressService();
  late Future<List<Question>> _questionsFuture;
  final TextEditingController _answerController = TextEditingController();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final questions = await _questionService.getGroupQuestions(widget.groupId);
    // خلط الأسئلة لعرضها بشكل عشوائي
    questions.shuffle();
    _questions = questions;
    return questions;
  }

  void _submitAnswer() async {
    final enteredAnswer = int.tryParse(_answerController.text.trim());
    if (enteredAnswer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال رقم صحيح.')));
      return;
    }

    setState(() => _isLoading = true);
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = enteredAnswer == currentQuestion.answer;

    try {
      // 1. تسجيل النتيجة في قاعدة البيانات
      await _progressService.recordAnswer(
        questionId: currentQuestion.id,
        isCorrect: isCorrect,
      );

      // 2. تحديث الواجهة
      setState(() {
        _isAnswerSubmitted = true;
        _isCorrect = isCorrect;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تسجيل الإجابة: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextQuestion() {
    _answerController.clear();
    setState(() {
      _isAnswerSubmitted = false;
      // الانتقال للسؤال التالي أو العودة للأول عند الانتهاء
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حل الأسئلة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'العودة',
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل الأسئلة: ${snapshot.error}'),
            );
          }

          if (_questions.isEmpty) {
            return const Center(
              child: Text('لا توجد أسئلة متاحة في هذه المجموعة.'),
            );
          }

          final currentQuestion = _questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'السؤال رقم ${_currentQuestionIndex + 1} من ${_questions.length}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 30),
                Text(
                  currentQuestion.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      48,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: 'أدخل الإجابة هنا',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isAnswerSubmitted,
                ),
                const SizedBox(height: 30),
                if (_isAnswerSubmitted)
                  Column(
                    children: [
                      Text(
                        _isCorrect
                            ? 'إجابة صحيحة! 🎉'
                            : 'إجابة خاطئة. 😔 الإجابة هي: ${currentQuestion.answer}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? 'ابدأ من جديد'
                              : 'السؤال التالي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'تحقق من الإجابة',
                            style: TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
