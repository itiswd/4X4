import 'package:flutter/material.dart';

import '../../../data/models/group.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/group_service.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  late Future<List<Group>> _groupsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // الحصول على جميع المجموعات (RLS تسمح للطالب بالرؤية)
    _groupsFuture = _loadAllGroups();
  }

  Future<List<Group>> _loadAllGroups() async {
    // سنستخدم دالة عامة لجلب جميع المجموعات، ونفترض أن GroupService سيتولى ذلك
    // ملاحظة: سنحتاج إلى إضافة دالة `getAllGroups()` إلى GroupService
    return await _groupService.getAllGroups();
  }

  // دالة الانضمام للمجموعة
  void _joinGroup(String groupId) async {
    setState(() => _isLoading = true);
    try {
      await _authService.updateStudentGroup(groupId: groupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الانضمام إلى المجموعة بنجاح!')),
        );
        Navigator.of(context).pop(); // العودة للشاشة الرئيسية للطالب
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الانضمام: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار المجموعة')),
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
            return const Center(child: Text('لا توجد مجموعات متاحة حاليًا.'));
          }

          return ListView.builder(
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
                  trailing: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _joinGroup(group.id),
                          child: const Text('اخترها'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
