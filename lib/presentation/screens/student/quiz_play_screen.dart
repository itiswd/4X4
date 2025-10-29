// lib/presentation/screens/student/quiz_play_screen.dart
import 'package:educational_app/data/models/theme_provider.dart';
import 'package:educational_app/presentation/screens/student/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/question.dart';
import '../../../data/models/quiz.dart';
import '../../../data/services/progress_service.dart';
import '../../../main.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final ProgressService _progressService = ProgressService();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // لحفظ إجابات الطالب
  final Map<String, Map<String, dynamic>> _studentAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await supabase
          .from('questions')
          .select()
          .eq('quiz_id', widget.quiz.id)
          .order('created_at', ascending: true);

      final questions = (response as List)
          .map((map) => Question.fromMap(map as Map<String, dynamic>))
          .toList();

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد أسئلة في هذا الكويز')),
          );
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأسئلة: $e')));
        Navigator.pop(context);
      }
    }
  }

  void _nextQuestion() async {
    final enteredAnswer = int.tryParse(_answerController.text.trim());
    if (enteredAnswer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال رقم صحيح')));
      return;
    }

    setState(() => _isSubmitting = true);

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = enteredAnswer == currentQuestion.answer;

    // حفظ الإجابة
    _studentAnswers[currentQuestion.id] = {
      'student_answer': enteredAnswer,
      'correct_answer': currentQuestion.answer,
      'is_correct': isCorrect,
      'question_text': currentQuestion.questionText,
    };

    try {
      // تسجيل في student_progress
      await _progressService.recordAnswer(
        questionId: currentQuestion.id,
        isCorrect: isCorrect,
        studentAnswer: enteredAnswer,
      );

      if (isCorrect) {
        setState(() => _score++);
      }

      // الانتقال للسؤال التالي أو إنهاء الكويز
      if (_currentIndex < _questions.length - 1) {
        _answerController.clear();
        setState(() {
          _currentIndex++;
          _isSubmitting = false;
        });
        // ✅ إعادة التركيز على الحقل
        Future.delayed(const Duration(milliseconds: 100), () {
          _answerFocusNode.requestFocus();
        });
      } else {
        _finishQuiz();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في حفظ الإجابة: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _finishQuiz() async {
    setState(() => _isSubmitting = true);

    try {
      // حفظ المحاولة
      await _progressService.recordQuizAttempt(
        quizId: widget.quiz.id,
        score: _score,
        totalQuestions: _questions.length,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quiz: widget.quiz,
              score: _score,
              totalQuestions: _questions.length,
              studentAnswers: _studentAnswers,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في حفظ النتيجة: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text(
              'هل أنت متأكد من الخروج؟ سيتم فقدان تقدمك الحالي.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('خروج'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد الخروج'),
                  content: const Text(
                    'هل أنت متأكد من الخروج؟ سيتم فقدان تقدمك الحالي.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('خروج'),
                    ),
                  ],
                ),
              );
              if (shouldPop == true && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.h),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.watch<ThemeProvider>().isDarkMode
                  ? AppColors.grey900
                  : AppColors.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // رقم السؤال
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السؤال ${_currentIndex + 1} من ${_questions.length}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16.sp, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text(
                          'النقاط: $_score',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // السؤال
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().isDarkMode
                      ? AppColors.grey900
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: context.watch<ThemeProvider>().isDarkMode
                        ? AppColors.grey900
                        : AppColors.borderLight,
                    width: 2,
                  ),
                ),
                child: Text(
                  currentQuestion.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 56.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // حقل الإجابة
              TextField(
                controller: _answerController,
                focusNode: _answerFocusNode,
                decoration: InputDecoration(
                  labelText: 'أدخل إجابتك هنا',
                  prefixIcon: const Icon(Icons.edit),
                  enabled: !_isSubmitting, // ✅ التعديل هنا
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                autofocus: true,
                onSubmitted: (_) =>
                    _nextQuestion(), // ✅ إضافة هذا للسماح بالضغط على Enter
              ),

              const Spacer(),

              // زر واحد فقط
              ElevatedButton(
                onPressed: _isSubmitting ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentIndex < _questions.length - 1
                            ? 'السؤال التالي'
                            : 'إنهاء الكويز',
                        style: TextStyle(fontSize: 18.sp),
                      ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }
}
