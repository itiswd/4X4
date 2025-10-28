import 'package:flutter/material.dart';

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

  // دالة لإعادة تحميل الأسئلة من Supabase
  void _reloadQuestions() {
    setState(() {
      _questionsFuture = _questionService.getGroupQuestions(widget.group.id);
    });
  }

  // فتح نموذج الإضافة أو التعديل
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
                    labelText: 'نص السؤال (مثال: 5 * 7)',
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'الإجابة الصحيحة',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
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
                    // عملية التعديل
                    await _questionService.updateQuestion(
                      questionId: question.id,
                      questionText: text,
                      answer: answer,
                    );
                  } else {
                    // عملية الإنشاء
                    await _questionService.createQuestion(
                      groupId: widget.group.id,
                      questionText: text,
                      answer: answer,
                    );
                  }
                  _reloadQuestions(); // تحديث القائمة بعد العملية
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

  // دالة حذف السؤال
  void _deleteQuestion(String questionId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _questionService.deleteQuestion(questionId);
        _reloadQuestions(); // تحديث القائمة بعد الحذف
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة أسئلة: ${widget.group.name}')),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل الأسئلة: ${snapshot.error}'),
            );
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(
              child: Text('لم يتم إضافة أي أسئلة بعد لهذه المجموعة.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadQuestions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('السؤال: ${question.questionText}'),
                    subtitle: Text('الإجابة الصحيحة: ${question.answer}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر التعديل
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showQuestionDialog(question: question),
                        ),
                        // زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteQuestion(question.id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuestionDialog(),
        label: const Text('إضافة سؤال'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
