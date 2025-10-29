// lib/presentation/screens/admin/quiz_management_screen.dart
import 'package:educational_app/data/services/quiz_services.dart';
import 'package:educational_app/presentation/screens/admin/quiz_attempts_screen.dart';
import 'package:educational_app/presentation/screens/admin/quiz_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/group.dart';
import '../../../data/models/quiz.dart';
import 'create_quiz_screen.dart';

class QuizManagementScreen extends StatefulWidget {
  final Group group;
  const QuizManagementScreen({super.key, required this.group});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  final QuizService _quizService = QuizService();
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _reloadQuizzes();
  }

  void _reloadQuizzes() {
    setState(() {
      _quizzesFuture = _quizService.getGroupQuizzes(widget.group.id);
    });
  }

  void _deleteQuiz(String quizId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا الكويز؟\nسيتم حذف جميع الأسئلة المرتبطة به.',
        ),
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
        await _quizService.deleteQuiz(quizId);
        _reloadQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الكويز بنجاح'),
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

  Widget _buildQuizCard(Quiz quiz) {
    return FutureBuilder<int>(
      future: _quizService.getQuizQuestionsCount(quiz.id),
      builder: (context, snapshot) {
        final questionCount = snapshot.data ?? 0;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizQuestionsScreen(quiz: quiz),
                ),
              ).then((_) => _reloadQuizzes());
            },
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
                          size: 28.sp,
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
                                fontSize: 18.sp,
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
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 24.sp),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteQuiz(quiz.id);
                          }
                        },
                        itemBuilder: (context) => [
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
                  if (quiz.description != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      quiz.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '$questionCount ${questionCount == 1 ? 'سؤال' : 'أسئلة'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_back,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // زر عرض المحاولات
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizAttemptsScreen(quiz: quiz),
                        ),
                      );
                    },
                    icon: Icon(Icons.people_outline, size: 18.sp),
                    label: const Text('عرض محاولات الطلاب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
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
        title: Text(
          'كويزات ${widget.group.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    'لا توجد كويزات بعد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط على الزر أدناه لإضافة كويز جديد',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadQuizzes(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: quizzes.length,
              itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateQuizScreen(group: widget.group),
            ),
          ).then((_) => _reloadQuizzes());
        },
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'إضافة كويز',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
