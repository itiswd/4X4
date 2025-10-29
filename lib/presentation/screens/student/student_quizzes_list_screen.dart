// lib/presentation/screens/student/student_quizzes_list_screen.dart
import 'package:educational_app/data/models/theme_provider.dart';
import 'package:educational_app/presentation/screens/student/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/quiz.dart';
import '../../../data/services/quiz_services.dart';
import '../../../main.dart';
import 'quiz_play_screen.dart';

class StudentQuizzesListScreen extends StatefulWidget {
  final String groupId;
  const StudentQuizzesListScreen({super.key, required this.groupId});

  @override
  State<StudentQuizzesListScreen> createState() =>
      _StudentQuizzesListScreenState();
}

class _StudentQuizzesListScreenState extends State<StudentQuizzesListScreen> {
  final QuizService _quizService = QuizService();
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    setState(() {
      _quizzesFuture = _quizService.getGroupQuizzes(widget.groupId);
    });
  }

  // ✅ دالة لجلب إجابات الطالب في محاولة معينة
  Future<Map<String, Map<String, dynamic>>> _getStudentAnswers(
    String attemptId,
  ) async {
    try {
      // جلب معلومات المحاولة
      final attemptData = await supabase
          .from('quiz_attempts')
          .select('quiz_id, student_id')
          .eq('id', attemptId)
          .single();

      final quizId = attemptData['quiz_id'] as String;
      final studentId = attemptData['student_id'] as String;

      // جلب أسئلة الكويز
      final questionsData = await supabase
          .from('questions')
          .select('id, question_text, answer')
          .eq('quiz_id', quizId)
          .order('created_at', ascending: true);

      final questions = questionsData as List<dynamic>;

      // جلب إجابات الطالب
      final progressData = await supabase
          .from('student_progress')
          .select('question_id, is_correct, student_answer')
          .eq('student_id', studentId)
          .inFilter(
            'question_id',
            questions.map((q) => q['id'] as String).toList(),
          );

      final progressList = progressData as List<dynamic>;

      // إنشاء Map للإجابات
      final Map<String, Map<String, dynamic>> answersMap = {};
      final Map<String, Map<String, dynamic>> progressMap = {};

      for (var p in progressList) {
        progressMap[p['question_id'] as String] = {
          'student_answer': p['student_answer'],
          'is_correct': p['is_correct'],
        };
      }

      for (var question in questions) {
        final questionId = question['id'] as String;
        final progress = progressMap[questionId];

        if (progress != null) {
          answersMap[questionId] = {
            'question_text': question['question_text'] as String,
            'correct_answer': question['answer'] as int,
            'student_answer': progress['student_answer'] as int?,
            'is_correct': progress['is_correct'] as bool,
          };
        }
      }

      return answersMap;
    } catch (e) {
      debugPrint('Error fetching student answers: $e');
      return {};
    }
  }

  Widget _buildQuizCard(Quiz quiz) {
    return FutureBuilder<int>(
      future: _quizService.getQuizQuestionsCount(quiz.id),
      builder: (context, snapshot) {
        final questionCount = snapshot.data ?? 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: context.watch<ThemeProvider>().isDarkMode
                  ? AppColors.grey900
                  : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: questionCount > 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPlayScreen(quiz: quiz),
                      ),
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(16.r),
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
                          quiz.quizType == QuizType.auto
                              ? Icons.auto_awesome
                              : Icons.edit_note,
                          color: AppColors.primary,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                _buildChip(quiz.quizTypeArabic, Colors.blue),
                                if (quiz.operationType != null) ...[
                                  SizedBox(width: 8.w),
                                  _buildChip(
                                    quiz.operationTypeArabic,
                                    Colors.purple,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (quiz.description != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().isDarkMode
                            ? AppColors.grey900
                            : AppColors.grey50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        quiz.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: context.watch<ThemeProvider>().isDarkMode
                              ? AppColors.grey50
                              : AppColors.grey900,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),

                  // معلومات الكويز
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isLoading
                            ? 'جاري التحميل...'
                            : '$questionCount ${questionCount == 1 ? 'سؤال' : 'أسئلة'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // زر البدء
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: questionCount > 0
                            ? [AppColors.primary, AppColors.primaryLight]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          questionCount > 0
                              ? Icons.play_circle_filled
                              : Icons.lock,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          questionCount > 0 ? 'ابدأ الكويز' : 'لا توجد أسئلة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ عرض المحاولات السابقة - قابل للضغط
                  FutureBuilder<List<dynamic>>(
                    future: supabase
                        .from('quiz_attempts')
                        .select()
                        .eq('quiz_id', quiz.id)
                        .eq('student_id', supabase.auth.currentUser!.id)
                        .order('completed_at', ascending: false)
                        .limit(1),
                    builder: (context, attemptsSnapshot) {
                      if (attemptsSnapshot.hasData &&
                          attemptsSnapshot.data!.isNotEmpty) {
                        final lastAttempt = attemptsSnapshot.data!.first;
                        final attemptId = lastAttempt['id'] as String;
                        final score = lastAttempt['score'] as int;
                        final total = lastAttempt['total_questions'] as int;
                        final percentage = (score / total) * 100;

                        return InkWell(
                          onTap: () async {
                            // ✅ عرض مؤشر تحميل
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              // جلب الإجابات
                              final answers = await _getStudentAnswers(
                                attemptId,
                              );

                              if (mounted) {
                                // إغلاق مؤشر التحميل
                                Navigator.pop(context);

                                // الانتقال لصفحة النتائج
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizResultScreen(
                                      quiz: quiz,
                                      score: score,
                                      totalQuestions: total,
                                      studentAnswers: answers,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ في تحميل النتائج: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            margin: EdgeInsets.only(top: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(25),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.info.withAlpha(77),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 18.sp,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'آخر محاولة: $score من $total (${percentage.toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.sp,
                                  color: AppColors.info,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الكويزات المتاحة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 80.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد كويزات متاحة حالياً',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'انتظر حتى يضيف المدرس كويزات جديدة',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadQuizzes(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 32.h),
              itemCount: quizzes.length,
              itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
            ),
          );
        },
      ),
    );
  }
}
