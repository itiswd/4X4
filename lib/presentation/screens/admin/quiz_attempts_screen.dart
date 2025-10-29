// lib/presentation/screens/admin/quiz_attempts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/quiz.dart';
import '../../../data/services/progress_service.dart';

class QuizAttemptsScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizAttemptsScreen({super.key, required this.quiz});

  @override
  State<QuizAttemptsScreen> createState() => _QuizAttemptsScreenState();
}

class _QuizAttemptsScreenState extends State<QuizAttemptsScreen> {
  final ProgressService _progressService = ProgressService();
  late Future<List<Map<String, dynamic>>> _attemptsFuture;
  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadAttempts();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ar', null);
    if (mounted) {
      setState(() => _isDateFormatInitialized = true);
    }
  }

  void _loadAttempts() {
    setState(() {
      _attemptsFuture = _progressService.getQuizAttempts(widget.quiz.id);
    });
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
          'محاولات: ${widget.quiz.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attemptsFuture,
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
                    Icons.inbox_outlined,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد محاولات بعد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لم يحل أي طالب هذا الكويز بعد',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadAttempts(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                final score = attempt['score'] as int;
                final total = attempt['total_questions'] as int;
                final percentage = (score / total) * 100;
                final completedAt = attempt['completed_at'] as String;
                final profile = attempt['profiles'] as Map<String, dynamic>?;
                final studentName = profile?['full_name'] ?? 'طالب محذوف';

                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: AppColors.getPerformanceColor(
                        percentage,
                      ).withAlpha(77),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الطالب والنسبة
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primary.withAlpha(32),
                              child: Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
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
                                color: AppColors.getPerformanceColor(
                                  percentage,
                                ).withAlpha(25),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${percentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getPerformanceColor(
                                    percentage,
                                  ),
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
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars,
                                size: 18.sp,
                                color: AppColors.getPerformanceColor(
                                  percentage,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'النتيجة: $score من $total',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
