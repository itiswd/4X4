// lib/presentation/screens/student/student_home_screen.dart
import 'package:educational_app/presentation/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import '../../../data/services/group_service.dart';
import 'quiz_screen.dart';

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

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

        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizScreen(groupId: groupId),
              ),
            );
          },
          icon: Icon(Icons.play_circle_filled_rounded, size: 28.sp),
          label: Text(
            'ابدأ حل الأسئلة الآن',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthStateModel>().signOut(),
            tooltip: 'تسجيل الخروج',
          ),
          const SizedBox(width: 8),
        ],
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
