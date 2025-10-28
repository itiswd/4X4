import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/group.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/group_service.dart';
import '../../../data/services/progress_service.dart';

class GroupStudentListScreen extends StatefulWidget {
  final Group group;
  const GroupStudentListScreen({super.key, required this.group});

  @override
  State<GroupStudentListScreen> createState() => _GroupStudentListScreenState();
}

class _GroupStudentListScreenState extends State<GroupStudentListScreen> {
  final GroupService _groupService = GroupService();
  final ProgressService _progressService = ProgressService();
  // لحفظ نتيجة جلب الطلاب في هذه المجموعة
  late Future<List<Profile>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    // جلب الطلاب المنضمين إلى المجموعة المحددة
    _studentsFuture = _groupService.getStudentsInGroup(widget.group.id);
  }

  // دالة مساعدة لجلب الإحصائيات وعرضها في ListTile
  Widget _buildStudentTile(Profile student) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _progressService.getStudentPerformanceSummary(student.id),
      builder: (context, snapshot) {
        String subtitleText = 'جاري تحميل التقدم...';
        Widget trailingWidget = SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(strokeWidth: 2),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          // حالة التحميل أثناء جلب الإحصائيات
        } else if (snapshot.hasError) {
          subtitleText = 'فشل تحميل التقدم';
          trailingWidget = const Icon(Icons.error, color: Colors.red);
        } else if (snapshot.hasData) {
          final summary = snapshot.data!;
          final total = summary['total_attempts'];
          final accuracy = summary['accuracy'];

          subtitleText = 'المحاولات: $total\nالدقة: ${accuracy.toInt()}%';
          trailingWidget = Text(
            '${accuracy.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              // تغيير اللون حسب مستوى الدقة
              color: accuracy >= 75
                  ? Colors.green
                  : accuracy >= 50
                  ? Colors.orange
                  : Colors.red,
            ),
          );
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20.r,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(32),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 22.sp,
              ),
            ),
            title: Text(
              student.fullName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            subtitle: Text(subtitleText, style: TextStyle(fontSize: 14.sp)),
            trailing: trailingWidget,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.group.name,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'العودة',
        ),
      ),
      body: FutureBuilder<List<Profile>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل الطلاب: ${snapshot.error}'),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text('لم ينضم أي طالب لهذه المجموعة بعد.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              // لكل طالب، نقوم ببناء _buildStudentTile لجلب وعرض إحصائياته
              return _buildStudentTile(students[index]);
            },
          );
        },
      ),
    );
  }
}
