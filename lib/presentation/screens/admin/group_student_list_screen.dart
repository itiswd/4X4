import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_colors.dart';
import '../../../data/models/group.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/group_service.dart';
import '../../../data/services/progress_service.dart';
import 'student_detail_screen.dart';

class GroupStudentListScreen extends StatefulWidget {
  final Group group;
  const GroupStudentListScreen({super.key, required this.group});

  @override
  State<GroupStudentListScreen> createState() => _GroupStudentListScreenState();
}

class _GroupStudentListScreenState extends State<GroupStudentListScreen> {
  final GroupService _groupService = GroupService();
  final ProgressService _progressService = ProgressService();
  late Future<List<Profile>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _groupService.getStudentsInGroup(widget.group.id);
  }

  Widget _buildStudentTile(Profile student) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _progressService.getStudentPerformanceSummary(student.id),
      builder: (context, snapshot) {
        String subtitleText = 'جاري تحميل التقدم...';
        Widget trailingWidget = SizedBox(
          width: 24.w,
          height: 24.h,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          // حالة التحميل
        } else if (snapshot.hasError) {
          subtitleText = 'فشل تحميل التقدم';
          trailingWidget = const Icon(Icons.error, color: Colors.red);
        } else if (snapshot.hasData) {
          final summary = snapshot.data!;
          final total = summary['total_attempts'];
          final accuracy = summary['accuracy'];

          subtitleText = 'المحاولات: $total | الدقة: ${accuracy.toInt()}%';

          // أيقونة السهم للتفاصيل
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${accuracy.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: AppColors.getPerformanceColor(accuracy),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_ios, size: 16.sp),
            ],
          );
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          child: ListTile(
            onTap: () {
              // الانتقال لشاشة التفاصيل
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudentDetailScreen(student: student),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary.withAlpha(32),
              child: Icon(Icons.person, color: AppColors.primary, size: 24.sp),
            ),
            title: Text(
              student.fullName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(subtitleText, style: TextStyle(fontSize: 13.sp)),
            ),
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
          'طلاب: ${widget.group.name}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'لم ينضم أي طالب لهذه المجموعة بعد.',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(10.w),
            itemCount: students.length,
            itemBuilder: (context, index) {
              return _buildStudentTile(students[index]);
            },
          );
        },
      ),
    );
  }
}
