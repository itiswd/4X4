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
        title: const Text(
          'إنشاء كويز جديد',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    Text(
                      'نوع الكويز',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: QuizType.auto,
                            icon: Icons.auto_awesome,
                            title: 'تلقائي',
                            subtitle: 'توليد أسئلة تلقائياً',
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

            SizedBox(height: 16.h),

            // المعلومات الأساسية
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الكويز',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الكويز',
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
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات التوليد',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // نوع العملية
                      DropdownButtonFormField<OperationType>(
                        decoration: const InputDecoration(
                          labelText: 'نوع العملية',
                          prefixIcon: Icon(Icons.calculate),
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
                            child: Text('منوع'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedOperation = value);
                        },
                        validator: (v) =>
                            v == null ? 'الرجاء اختيار نوع العملية' : null,
                      ),

                      SizedBox(height: 16.h),

                      // جدول محدد (لجميع العمليات)
                      if (_selectedOperation != null &&
                          _selectedOperation != OperationType.mixed)
                        CheckboxListTile(
                          title: const Text('استخدام جدول محدد'),
                          subtitle: Text(
                            _selectedOperation == OperationType.multiply
                                ? 'مثال: جدول 5 (5×1، 5×2، ...)'
                                : _selectedOperation == OperationType.add
                                ? 'مثال: جدول 5 (5+1، 5+2، ...)'
                                : _selectedOperation == OperationType.subtract
                                ? 'مثال: جدول 10 (10-1، 10-2، ...)'
                                : 'مثال: جدول 12 (12÷1، 12÷2، ...)',
                          ),
                          value: _useSpecificTable,
                          onChanged: (value) {
                            setState(() => _useSpecificTable = value ?? false);
                          },
                        ),

                      if (_useSpecificTable &&
                          _selectedOperation != null &&
                          _selectedOperation != OperationType.mixed) ...[
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _tableNumberController,
                          decoration: const InputDecoration(
                            labelText: 'رقم الجدول',
                            hintText: 'مثال: 5',
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

                      SizedBox(height: 16.h),

                      // النطاق
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minRangeController,
                              decoration: const InputDecoration(
                                labelText: 'من',
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
                                prefixIcon: Icon(Icons.arrow_downward),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'مطلوب' : null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // عدد الأسئلة
                      TextFormField(
                        controller: _questionsCountController,
                        decoration: const InputDecoration(
                          labelText: 'عدد الأسئلة',
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
              ),
            ],

            SizedBox(height: 24.h),

            // زر الإنشاء
            ElevatedButton(
              onPressed: _isLoading ? null : _createQuiz,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إنشاء الكويز', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
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
