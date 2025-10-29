// lib/presentation/screens/admin/create_quiz_screen.dart
import 'package:educational_app/data/services/quiz_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/group.dart';
import '../../../data/models/quiz.dart';

class CreateQuizScreen extends StatefulWidget {
  final Group group;
  const CreateQuizScreen({super.key, required this.group});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _questionsCountController = TextEditingController(text: '10');
  final _tableNumberController = TextEditingController();
  final _minRangeController = TextEditingController(text: '1');
  final _maxRangeController = TextEditingController(text: '10');

  final QuizService _quizService = QuizService();

  QuizType _selectedType = QuizType.auto;
  OperationType? _selectedOperation;
  bool _useSpecificTable = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _questionsCountController.dispose();
    _tableNumberController.dispose();
    _minRangeController.dispose();
    _maxRangeController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedType == QuizType.manual) {
        await _quizService.createManualQuiz(
          groupId: widget.group.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
        );
      } else {
        if (_selectedOperation == null) {
          throw Exception('الرجاء اختيار نوع العملية');
        }

        await _quizService.createAutoQuiz(
          groupId: widget.group.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          operationType: _selectedOperation!,
          tableNumber: _useSpecificTable
              ? int.tryParse(_tableNumberController.text)
              : null,
          minRange: int.parse(_minRangeController.text),
          maxRange: int.parse(_maxRangeController.text),
          questionsCount: int.parse(_questionsCountController.text),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الكويز بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إنشاء كويز جديد',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // نوع الكويز
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.quiz, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'نوع الكويز',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: QuizType.auto,
                            icon: Icons.auto_awesome,
                            title: 'تلقائي',
                            subtitle: 'توليد أسئلة تلقائيًا',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTypeCard(
                            type: QuizType.manual,
                            icon: Icons.edit_note,
                            title: 'يدوي',
                            subtitle: 'إضافة الأسئلة بنفسك',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // المعلومات الأساسية
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.secondary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'معلومات الكويز',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الكويز',
                        hintText: 'مثال: كويز جدول الضرب 5',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'الرجاء إدخال العنوان' : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'الوصف (اختياري)',
                        hintText: 'وصف مختصر للكويز',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            // إعدادات التوليد التلقائي
            if (_selectedType == QuizType.auto) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: AppColors.accent,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'إعدادات الأسئلة',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // نوع العملية
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calculate,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'نوع العملية الحسابية',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<OperationType>(
                              decoration: const InputDecoration(
                                hintText: 'اختر العملية',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _selectedOperation,
                              items: const [
                                DropdownMenuItem(
                                  value: OperationType.multiply,
                                  child: Text('ضرب (×)'),
                                ),
                                DropdownMenuItem(
                                  value: OperationType.add,
                                  child: Text('جمع (+)'),
                                ),
                                DropdownMenuItem(
                                  value: OperationType.subtract,
                                  child: Text('طرح (-)'),
                                ),
                                DropdownMenuItem(
                                  value: OperationType.divide,
                                  child: Text('قسمة (÷)'),
                                ),
                                DropdownMenuItem(
                                  value: OperationType.mixed,
                                  child: Text('منوع (جميع العمليات)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedOperation = value);
                              },
                              validator: (v) => v == null
                                  ? 'الرجاء اختيار نوع العملية'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // جدول محدد
                      if (_selectedOperation != null &&
                          _selectedOperation != OperationType.mixed)
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.table_chart,
                                      size: 20.sp,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8.w),
                                    const Text('استخدام جدول محدد'),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(
                                    right: 28.w,
                                    top: 4.h,
                                  ),
                                  child: Text(
                                    _getTableExampleText(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                value: _useSpecificTable,
                                onChanged: (value) {
                                  setState(
                                    () => _useSpecificTable = value ?? false,
                                  );
                                },
                              ),
                              if (_useSpecificTable) ...[
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _tableNumberController,
                                  decoration: const InputDecoration(
                                    labelText: 'رقم الجدول',
                                    hintText: 'أدخل رقم من 1 إلى 12',
                                    prefixIcon: Icon(Icons.numbers),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v?.isEmpty ?? true)
                                      return 'الرجاء إدخال رقم الجدول';
                                    final num = int.tryParse(v!);
                                    if (num == null || num < 1 || num > 12) {
                                      return 'الرقم يجب أن يكون بين 1 و 12';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                      SizedBox(height: 16.h),

                      // نطاق الأرقام - مبسط ومع شرح
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.numbers,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'نطاق الأرقام المستخدمة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getRangeExplanation(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _minRangeController,
                                    decoration: const InputDecoration(
                                      labelText: 'من',
                                      hintText: '1',
                                      prefixIcon: Icon(Icons.arrow_upward),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'مطلوب' : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _maxRangeController,
                                    decoration: const InputDecoration(
                                      labelText: 'إلى',
                                      hintText: '10',
                                      prefixIcon: Icon(Icons.arrow_downward),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'مطلوب' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // عدد الأسئلة
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_list_numbered,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'عدد الأسئلة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'كم سؤال تريد في الكويز؟',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _questionsCountController,
                              decoration: const InputDecoration(
                                hintText: 'مثال: 10',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'مطلوب';
                                final num = int.tryParse(v!);
                                if (num == null || num < 1) {
                                  return 'يجب أن يكون أكبر من 0';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // زر الإنشاء
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createQuiz,
              icon: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.add_circle,
                size: 24.sp,
              ),
              label: Text(
                _isLoading ? 'جاري الإنشاء...' : 'إنشاء الكويز',
                style: TextStyle(fontSize: 18.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  String _getTableExampleText() {
    switch (_selectedOperation) {
      case OperationType.multiply:
        return 'مثال: جدول 5 يعني (5×1، 5×2، 5×3، ...)';
      case OperationType.add:
        return 'مثال: جدول 5 يعني (5+1، 5+2، 5+3، ...)';
      case OperationType.subtract:
        return 'مثال: جدول 10 يعني (10-1، 10-2، 10-3، ...)';
      case OperationType.divide:
        return 'مثال: جدول 12 يعني (12÷1، 12÷2، 12÷3، ...)';
      default:
        return '';
    }
  }

  String _getRangeExplanation() {
    if (_useSpecificTable) {
      return 'الأرقام التي سيتم استخدامها مع الجدول المحدد';
    }
    switch (_selectedOperation) {
      case OperationType.multiply:
        return 'مثال: من 1 إلى 10 يعني أسئلة مثل (3×5، 7×2، ...)';
      case OperationType.add:
        return 'مثال: من 1 إلى 10 يعني أسئلة مثل (3+5، 7+2، ...)';
      case OperationType.subtract:
        return 'مثال: من 1 إلى 10 يعني أسئلة مثل (10-5، 8-3، ...)';
      case OperationType.divide:
        return 'مثال: من 1 إلى 10 يعني أسئلة مثل (20÷5، 18÷2، ...)';
      case OperationType.mixed:
        return 'نطاق الأرقام لجميع العمليات الحسابية';
      default:
        return 'حدد نطاق الأرقام المستخدمة في الأسئلة';
    }
  }

  Widget _buildTypeCard({
    required QuizType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? AppColors.primary.withAlpha(25) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
