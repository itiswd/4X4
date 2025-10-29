// lib/presentation/screens/student/student_home_screen.dart
import 'package:educational_app/presentation/screens/student/student_quizzes_list_screen.dart';
import 'package:educational_app/presentation/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import '../../../data/services/group_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final GroupService _groupService = GroupService();
  String? _groupName;
  bool _isGroupDataLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData();
    });
  }

  Future<void> _loadGroupData() async {
    if (!mounted) return;

    final authState = context.read<AuthStateModel>();
    final groupId = authState.currentProfile?.groupId;

    if (groupId != null) {
      final name = await _groupService.getGroupNameById(groupId);

      if (mounted) {
        setState(() {
          _groupName = name;
          _isGroupDataLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _groupName = null;
          _isGroupDataLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<AuthStateModel>().reloadProfile();

    if (!mounted) return;

    await _loadGroupData();
  }

  Widget _buildNoGroupState(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 80,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 20),
        Text(
          'حسابك غير مرتبط بمجموعة!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'الرجاء التواصل مع المدرس لتحديد مجموعتك. (لست بحاجة للاختيار مجدداً)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildGroupSelectedState(BuildContext context, String groupId) {
    if (_isGroupDataLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayGroupName = _groupName ?? 'غير معروفة';
    final fullName =
        context.read<AuthStateModel>().currentProfile?.fullName ??
        'عزيزي الطالب';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'مرحباً بك، $fullName!',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_rounded, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'مجموعتك الحالية: $displayGroupName',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // استبدل الزر الحالي بهذا:
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    StudentQuizzesListScreen(groupId: groupId),
              ),
            );
          },
          icon: Icon(Icons.quiz_rounded, size: 28.sp),
          label: Text(
            'عرض الكويزات المتاحة',
            style: TextStyle(fontSize: 18.sp),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          ),
        ),
        // const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _handleRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('تحديث بيانات المجموعة'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateModel>();
    final profile = authState.currentProfile;

    if (profile == null || authState.isLoadingSession) {
      return const LoadingScreen();
    }

    final hasGroup = profile.groupId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم الطالب',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      // ضيف هذا بعد body: وقبل قفل الـ Scaffold
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),

        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => context.read<AuthStateModel>().signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            icon: Icon(Icons.logout_rounded, size: 24.sp),
            label: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasGroup)
                _buildNoGroupState(context)
              else
                _buildGroupSelectedState(context, profile.groupId!),
            ],
          ),
        ),
      ),
    );
  }
}
