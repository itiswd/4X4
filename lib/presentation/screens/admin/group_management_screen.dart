import 'package:educational_app/data/models/group.dart';
import 'package:educational_app/presentation/screens/admin/question_management_screen.dart';
import 'package:flutter/material.dart';

import '../../../data/services/group_service.dart'; // سننشئها لاحقا

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final GroupService _groupService = GroupService();
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupService.getAdminGroups();
  }

  // إعادة تحميل البيانات
  void _reloadGroups() {
    setState(() {
      _groupsFuture = _groupService.getAdminGroups();
    });
  }

  // فتح نموذج الإضافة أو التعديل
  void _showGroupDialog({Group? group}) {
    final isEditing = group != null;
    final controller = TextEditingController(text: isEditing ? group.name : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'تعديل المجموعة' : 'إضافة مجموعة جديدة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'اسم المجموعة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                try {
                  if (isEditing) {
                    await _groupService.updateGroup(
                      id: group.id,
                      newName: controller.text.trim(),
                    );
                  } else {
                    await _groupService.createGroup(
                      name: controller.text.trim(),
                    );
                  }
                  _reloadGroups();
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

  // تأكيد الحذف
  void _deleteGroup(String groupId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المجموعة وجميع أسئلتها؟'),
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
        await _groupService.deleteGroup(id: groupId);
        _reloadGroups();
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
      appBar: AppBar(title: const Text('إدارة المجموعات')),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل المجموعات: ${snapshot.error}'),
            );
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(child: Text('لم تقم بإنشاء أي مجموعات بعد.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadGroups(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('ID: ${group.id.substring(0, 8)}...'),
                    onTap: () {
                      // للانتقال إلى شاشة إدارة الأسئلة
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuestionManagementScreen(group: group),
                            ),
                          )
                          .then(
                            (_) => _reloadGroups(),
                          ); // إعادة تحميل بعد العودة
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر التعديل
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showGroupDialog(group: group),
                        ),
                        // زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteGroup(group.id),
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
        onPressed: () => _showGroupDialog(),
        label: const Text('إضافة مجموعة'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
