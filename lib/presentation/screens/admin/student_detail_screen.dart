import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ إضافة هذا الاستيراد
import 'package:intl/intl.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/progress_service.dart';
import '../../../main.dart';

class StudentDetailScreen extends StatefulWidget {
  final Profile student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final ProgressService _progressService = ProgressService();
  late Future<List<Map<String, dynamic>>> _attemptsFuture;
  Map<String, dynamic>? _summary;
  bool _isDateFormatInitialized = false; // ✅ متغير لتتبع حالة التهيئة

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting(); // ✅ تهيئة بيانات التاريخ
    _loadData();
  }

  // ✅ دالة تهيئة بيانات التاريخ للغة العربية
  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ar', null);
    if (mounted) {
      setState(() {
        _isDateFormatInitialized = true;
      });
    }
  }

  void _loadData() {
    _attemptsFuture = _loadAttempts();
    _loadSummary();
  }

  Future<List<Map<String, dynamic>>> _loadAttempts() async {
    // جلب كل المحاولات مع تفاصيل الأسئلة
    final response = await supabase
        .from('student_progress')
        .select('''
          *,
          questions(question_text, answer)
        ''')
        .eq('student_id', widget.student.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _loadSummary() async {
    final summary = await _progressService.getStudentPerformanceSummary(
      widget.student.id,
    );
    if (mounted) {
      setState(() {
        _summary = summary;
      });
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return AppColors.excellent;
    if (accuracy >= 75) return AppColors.good;
    if (accuracy >= 50) return AppColors.average;
    return AppColors.poor;
  }

  String _formatDateTime(String dateTimeStr) {
    // ✅ فحص ما إذا كانت بيانات التاريخ جاهزة
    if (!_isDateFormatInitialized) {
      return dateTimeStr; // إرجاع النص الأصلي مؤقتاً
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
      return formatter.format(dateTime);
    } catch (e) {
      // في حالة حدوث خطأ، نرجع تنسيق بسيط
      return DateTime.parse(dateTimeStr).toString().substring(0, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student.fullName,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الإحصائيات
              if (_summary != null) _buildSummaryCard(),

              SizedBox(height: 20.h),

              Text(
                'سجل المحاولات:',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12.h),

              // قائمة المحاولات
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _attemptsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('خطأ: ${snapshot.error}'));
                  }

                  final attempts = snapshot.data ?? [];

                  if (attempts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لم يحل أي أسئلة بعد',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attempts.length,
                    itemBuilder: (context, index) {
                      return _buildAttemptCard(attempts[index], index + 1);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalAttempts = _summary!['total_attempts'];
    final correctCount = _summary!['correct_count'];
    final accuracy = _summary!['accuracy'];
    final wrongCount = totalAttempts - correctCount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // النسبة المئوية الكبيرة
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getAccuracyColor(accuracy).withAlpha(25),
                border: Border.all(
                  color: _getAccuracyColor(accuracy),
                  width: 4.w,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${accuracy.toInt()}%',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: _getAccuracyColor(accuracy),
                      ),
                    ),
                    Text(
                      'الدقة',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // الإحصائيات التفصيلية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: Icons.assignment,
                  label: 'عدد الأسئلة',
                  value: '$totalAttempts',
                  color: AppColors.accent,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'صحيحة',
                  value: '$correctCount',
                  color: AppColors.success,
                ),
                _buildStatItem(
                  icon: Icons.cancel,
                  label: 'خاطئة',
                  value: '$wrongCount',
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAttemptCard(Map<String, dynamic> attempt, int attemptNumber) {
    final isCorrect = attempt['is_correct'] as bool;
    final createdAt = attempt['created_at'] as String;
    final question = attempt['questions'];

    final questionText = question?['question_text'] ?? 'سؤال محذوف';
    final correctAnswer = question?['answer']?.toString() ?? '-';

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
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.success.withAlpha(25)
                        : AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? AppColors.success : AppColors.error,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isCorrect ? 'إجابة صحيحة ✓' : 'إجابة خاطئة ✗',
                        style: TextStyle(
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '#$attemptNumber',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // السؤال
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'السؤال:',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  ),
                  SizedBox(width: 24.w),
                  Text(
                    questionText,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // الإجابة الصحيحة
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16.sp,
                  color: AppColors.amber,
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
                  correctAnswer,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // التاريخ والوقت
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                SizedBox(width: 6.w),
                Text(
                  _formatDateTime(createdAt),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
