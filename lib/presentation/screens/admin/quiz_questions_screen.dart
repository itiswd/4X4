// lib/presentation/screens/admin/quiz_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/question.dart';
import '../../../data/models/quiz.dart';
import '../../../data/services/question_service.dart';
import '../../../main.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizQuestionsScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  final QuestionService _questionService = QuestionService();
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _reloadQuestions();
  }

  void _reloadQuestions() {
    setState(() {
      _questionsFuture = _loadQuizQuestions();
    });
  }

  Future<List<Question>> _loadQuizQuestions() async {
    final response = await supabase
        .from('questions')
        .select()
        .eq('quiz_id', widget.quiz.id)
        .order('created_at', ascending: true);

    return (response as List)
        .map((map) => Question.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  void _showQuestionDialog({Question? question}) {
    final isEditing = question != null;
    final textController = TextEditingController(
      text: isEditing ? question.questionText : '',
    );
    final answerController = TextEditingController(
      text: isEditing ? question.answer.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'تعديل السؤال' : 'إضافة سؤال جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'نص السؤال',
                    hintText: 'مثال: 5 × 7',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'الإجابة الصحيحة',
                    hintText: 'مثال: 35',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = textController.text.trim();
                final answer = int.tryParse(answerController.text.trim());

                if (text.isEmpty || answer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إدخال نص وإجابة صحيحة.'),
                    ),
                  );
                  return;
                }

                try {
                  if (isEditing) {
                    await _questionService.updateQuestion(
                      questionId: question.id,
                      questionText: text,
                      answer: answer,
                    );
                  } else {
                    // إنشاء سؤال جديد مرتبط بالكويز
                    await supabase.from('questions').insert({
                      'group_id': widget.quiz.groupId,
                      'question_text': text,
                      'answer': answer,
                      'quiz_id': widget.quiz.id,
                    });
                  }
                  _reloadQuestions();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'تعديل' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion(String questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _questionService.deleteQuestion(questionId);
        _reloadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف السؤال بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString()}')));
        }
      }
    }
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(32),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السؤال ${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        question.questionText,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 24.sp),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showQuestionDialog(question: question);
                    } else if (value == 'delete') {
                      _deleteQuestion(question.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(25),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.success.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'الإجابة الصحيحة: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '${question.answer}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quiz.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.quiz.quizType == QuizType.auto
                        ? 'الأسئلة تم توليدها تلقائياً'
                        : 'لا توجد أسئلة بعد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (widget.quiz.quizType == QuizType.manual) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'اضغط على الزر أدناه لإضافة سؤال',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadQuestions(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16.w,
                10.h,
                16.w,
                widget.quiz.quizType == QuizType.manual ? 102 : 32.h,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) =>
                  _buildQuestionCard(questions[index], index),
            ),
          );
        },
      ),
      floatingActionButton: widget.quiz.quizType == QuizType.manual
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () => _showQuestionDialog(),
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'إضافة سؤال',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
