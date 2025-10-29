// lib/presentation/screens/admin/student_attempt_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../main.dart';

class StudentAttemptDetailScreen extends StatefulWidget {
  final String attemptId;
  final String studentName;
  final int score;
  final int totalQuestions;

  const StudentAttemptDetailScreen({
    super.key,
    required this.attemptId,
    required this.studentName,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<StudentAttemptDetailScreen> createState() =>
      _StudentAttemptDetailScreenState();
}

class _StudentAttemptDetailScreenState
    extends State<StudentAttemptDetailScreen> {
  late Future<List<Map<String, dynamic>>> _answersFuture;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  void _loadAnswers() {
    setState(() {
      _answersFuture = _fetchStudentAnswers();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchStudentAnswers() async {
    try {
      // جلب quiz_id من المحاولة
      final attemptData = await supabase
          .from('quiz_attempts')
          .select('quiz_id, student_id')
          .eq('id', widget.attemptId)
          .single();

      final quizId = attemptData['quiz_id'] as String;
      final studentId = attemptData['student_id'] as String;

      // جلب جميع الأسئلة الخاصة بالكويز
      final questionsData = await supabase
          .from('questions')
          .select('id, question_text, answer')
          .eq('quiz_id', quizId)
          .order('created_at', ascending: true);

      final questions = questionsData as List<dynamic>;

      // جلب إجابات الطالب
      final progressData = await supabase
          .from('student_progress')
          .select('question_id, is_correct, student_answer, created_at')
          .eq('student_id', studentId)
          .inFilter(
            'question_id',
            questions.map((q) => q['id'] as String).toList(),
          );

      final progressList = progressData as List<dynamic>;

      // ✅ إنشاء Map للوصول السريع للإجابات
      final Map<String, Map<String, dynamic>> progressMap = {};
      for (var p in progressList) {
        progressMap[p['question_id'] as String] = {
          'student_answer': p['student_answer'],
          'is_correct': p['is_correct'],
        };
      }

      // دمج البيانات
      final List<Map<String, dynamic>> answers = [];
      for (var question in questions) {
        final questionId = question['id'] as String;
        final progress = progressMap[questionId];

        answers.add({
          'question_text': question['question_text'] as String,
          'correct_answer': question['answer'] as int,
          'student_answer': progress?['student_answer'] as int?,
          'is_correct': progress?['is_correct'] as bool? ?? false,
        });
      }

      return answers;
    } catch (e) {
      throw Exception('فشل تحميل الإجابات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل محاولة ${widget.studentName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // بطاقة النتيجة الإجمالية
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getPerformanceColor(percentage).withAlpha(25),
                  AppColors.getPerformanceColor(percentage).withAlpha(51),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.getPerformanceColor(percentage).withAlpha(77),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.getPerformanceColor(percentage),
                      width: 4.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getPerformanceColor(percentage),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النتيجة الإجمالية',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${widget.score} من ${widget.totalQuestions}',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16.sp,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${widget.score} صح',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.cancel,
                            size: 16.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${widget.totalQuestions - widget.score} خطأ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // قائمة الإجابات
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _answersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'خطأ في تحميل التفاصيل',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: _loadAnswers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final answers = snapshot.data ?? [];

                if (answers.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد تفاصيل متاحة',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    final isCorrect = answer['is_correct'] as bool;
                    final questionText = answer['question_text'] as String;
                    final correctAnswer = answer['correct_answer'] as int;
                    final studentAnswer = answer['student_answer'] as int?;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: isCorrect
                              ? AppColors.success.withAlpha(77)
                              : AppColors.error.withAlpha(77),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // رأس البطاقة
                            Row(
                              children: [
                                Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? AppColors.success.withAlpha(25)
                                        : AppColors.error.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    questionText,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 32.sp,
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // الإجابات
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.grey50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 18.sp,
                                        color: isCorrect
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'إجابة الطالب: ',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        studentAnswer?.toString() ?? 'لم يجب',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isCorrect) ...[
                                    SizedBox(height: 8.h),
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 18.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'الإجابة الصحيحة: ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          correctAnswer.toString(),
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
