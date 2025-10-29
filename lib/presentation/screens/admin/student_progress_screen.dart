import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/group.dart';
import '../../../data/services/group_service.dart';
import 'group_student_list_screen.dart'; // يتم استيراد الشاشة التالية لعرض الطلاب

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final GroupService _groupService = GroupService();
  // لحفظ نتيجة جلب المجموعات التي أنشأها المدرس
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    // جلب جميع المجموعات التي أنشأها المدرس
    _groupsFuture = _groupService.getAdminGroups();
  }

  // دالة لإعادة تحميل البيانات
  void _reloadGroups() {
    setState(() {
      _groupsFuture = _groupService.getAdminGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'متابعة تقدم الطلاب',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
            return const Center(
              child: Text('لم تقم بإنشاء أي مجموعات بعد لتتابع الطلاب.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadGroups(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.0.w, 10.h, 16.0.w, 32.0.h),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.people, size: 40.sp),
                    title: Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    subtitle: const Text('اضغط لعرض الطلاب المنضمين'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // الانتقال إلى شاشة قائمة الطلاب في هذه المجموعة
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupStudentListScreen(group: group),
                        ),
                      );
                    },
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
