// lib/presentation/screens/student/student_quizzes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            side: BorderSide(color: AppColors.borderLight, width: 1),
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
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        quiz.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
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

                  // عرض المحاولات السابقة
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
                        final score = lastAttempt['score'] as int;
                        final total = lastAttempt['total_questions'] as int;
                        final percentage = (score / total) * 100;

                        return Container(
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
                            ],
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
              padding: EdgeInsets.all(16.w),
              itemCount: quizzes.length,
              itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
            ),
          );
        },
      ),
    );
  }
}
