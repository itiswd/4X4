// lib/presentation/screens/admin/student_detail_screen.dart
import 'package:educational_app/data/models/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/progress_service.dart';
import 'student_attempt_detail_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Profile student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final ProgressService _progressService = ProgressService();
  late Future<List<Map<String, dynamic>>> _quizAttemptsFuture;
  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadData();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ar', null);
    if (mounted) {
      setState(() => _isDateFormatInitialized = true);
    }
  }

  void _loadData() {
    setState(() {
      _quizAttemptsFuture = _progressService.getStudentAllQuizAttempts(
        widget.student.id,
      );
    });
  }

  Color _getPerformanceColor(double percentage) {
    return AppColors.getPerformanceColor(percentage);
  }

  String _formatDateTime(String dateTimeStr) {
    if (!_isDateFormatInitialized) return dateTimeStr;

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
      return formatter.format(dateTime);
    } catch (e) {
      return DateTime.parse(dateTimeStr).toString().substring(0, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student.fullName,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _quizAttemptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('خطأ: ${snapshot.error}'));
            }

            final attempts = snapshot.data ?? [];

            if (attempts.isEmpty) {
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
                      'لم يحل أي كويزات بعد',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                final score = attempt['score'] as int;
                final total = attempt['total_questions'] as int;
                final percentage = (score / total) * 100;
                final completedAt = attempt['completed_at'] as String;
                final attemptId = attempt['id'] as String;

                final quiz = attempt['quizzes'] as Map<String, dynamic>?;
                final quizTitle = quiz?['title'] ?? 'كويز محذوف';
                final quizType = quiz?['quiz_type'] as String?;
                final operationType = quiz?['operation_type'] as String?;

                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: _getPerformanceColor(percentage).withAlpha(77),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // ✅ فتح صفحة التفاصيل عند الضغط
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentAttemptDetailScreen(
                            attemptId: attemptId,
                            studentName: widget.student.fullName,
                            score: score,
                            totalQuestions: total,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان والنسبة
                          Row(
                            children: [
                              // أيقونة الكويز
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(32),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  quizType == 'auto'
                                      ? Icons.auto_awesome
                                      : Icons.edit_note,
                                  color: AppColors.primary,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quizTitle,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatDateTime(completedAt),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPerformanceColor(
                                    percentage,
                                  ).withAlpha(25),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${percentage.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getPerformanceColor(percentage),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // النتيجة
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: context.watch<ThemeProvider>().isDarkMode
                                  ? AppColors.grey900
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 20.sp,
                                      color: _getPerformanceColor(percentage),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'النتيجة: $score من $total',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            context
                                                .watch<ThemeProvider>()
                                                .isDarkMode
                                            ? AppColors.grey50
                                            : AppColors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.sp,
                                  color: _getPerformanceColor(percentage),
                                ),
                              ],
                            ),
                          ),

                          // نوع العملية (إن وجد)
                          if (operationType != null) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha(25),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate,
                                    size: 14.sp,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _getOperationTypeArabic(operationType),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 12.h),

                          // رسالة توضيحية
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(25),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 16.sp,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'اضغط لعرض تفاصيل الإجابات',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getOperationTypeArabic(String operationType) {
    switch (operationType) {
      case 'multiply':
        return 'ضرب';
      case 'add':
        return 'جمع';
      case 'subtract':
        return 'طرح';
      case 'divide':
        return 'قسمة';
      case 'mixed':
        return 'منوع';
      default:
        return operationType;
    }
  }
}
