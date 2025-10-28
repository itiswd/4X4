import 'package:educational_app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/group.dart';
import '../../../data/models/question.dart';
import '../../../data/services/question_service.dart';

class QuestionManagementScreen extends StatefulWidget {
  final Group group;
  const QuestionManagementScreen({super.key, required this.group});

  @override
  State<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState extends State<QuestionManagementScreen> {
  final QuestionService _questionService = QuestionService();
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _reloadQuestions();
  }

  void _reloadQuestions() {
    setState(() {
      _questionsFuture = _questionService.getGroupQuestions(widget.group.id);
    });
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
                  keyboardType: TextInputType.text,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final String text = textController.text.trim();
                final int? answer = int.tryParse(answerController.text.trim());

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
                    await _questionService.createQuestion(
                      groupId: widget.group.id,
                      questionText: text,
                      answer: answer,
                    );
                  }
                  _reloadQuestions();
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في العملية: ${e.toString()}'),
                      ),
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
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا السؤال؟',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
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
            // العنوان والأزرار
            Row(
              children: [
                // أيقونة السؤال
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(32),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                // نص السؤال
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

                // أزرار التحكم
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8.w),
                          const Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8.w),
                          const Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // الإجابة الصحيحة
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
          'أسئلة ${widget.group.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  const Text('خطأ في تحميل الأسئلة'),
                  SizedBox(height: 8.h),
                  ElevatedButton.icon(
                    onPressed: _reloadQuestions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
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
                    'لا توجد أسئلة بعد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط على الزر أدناه لإضافة سؤال جديد',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadQuestions(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: questions.length,
              itemBuilder: (context, index) =>
                  _buildQuestionCard(questions[index], index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuestionDialog(),
        icon: const Icon(Icons.add_box, color: AppColors.white),
        label: const Text(
          'إضافة سؤال',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
