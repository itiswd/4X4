import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/quiz.dart';

class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;
  final int score;
  final int totalQuestions;
  final Map<String, Map<String, dynamic>> studentAnswers;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.totalQuestions,
    required this.studentAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 70) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color _getGradeColor() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    return AppColors.getPerformanceColor(percentage);
  }

  String _getGradeText() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  IconData _getGradeIcon() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 70) return Icons.sentiment_satisfied_alt;
    if (percentage >= 50) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نتيجة الكويز',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 24.h,
              bottom: 100.h, // ✅ مسافة للزر المثبت
            ),
            child: Column(
              children: [
                // بطاقة النتيجة الرئيسية
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getGradeColor().withAlpha(25),
                          _getGradeColor().withAlpha(51),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getGradeIcon(),
                          size: 64.sp,
                          color: _getGradeColor(),
                        ),

                        Text(
                          _getGradeText(),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 130.w,
                          height: 130.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getGradeColor(),
                              width: 8.w,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${percentage.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getGradeColor(),
                                  ),
                                ),
                                Text(
                                  'الدرجة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '${widget.score} من ${widget.totalQuestions}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'إجابات صحيحة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // زر عرض التفاصيل
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  icon: Icon(
                    _showDetails ? Icons.visibility_off : Icons.visibility,
                  ),
                  label: Text(_showDetails ? 'إخفاء التفاصيل' : 'عرض إجاباتي'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(12.h),
                  ),
                ),

                // تفاصيل الإجابات
                if (_showDetails) ...[
                  SizedBox(height: 16.h),
                  ...widget.studentAnswers.entries.map((entry) {
                    final data = entry.value;
                    final isCorrect = data['is_correct'] as bool;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
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
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    data['question_text'] as String,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Text(
                                  'إجابتك: ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${data['student_answer']}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCorrect) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    'الصحيحة: ',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    '${data['correct_answer']}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
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
                    );
                  }),
                ],

                SizedBox(height: 12.h),
                //إعادة المحاولة
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(12.h),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // ✅ زر العودة المثبت في الأسفل
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),

              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: Icon(Icons.home, size: 24.sp),
                  label: const Text('العودة للرئيسية'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
