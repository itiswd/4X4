// lib/presentation/screens/admin/admin_home_screen.dart
import 'package:educational_app/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import '../../widgets/loading_screen.dart';
import 'group_management_screen.dart';
import 'student_progress_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateModel>();
    final profile = authState.userRole;

    if (profile == null || authState.isLoadingSession) {
      return const LoadingScreen();
    }

    final List<Map<String, dynamic>> adminActions = [
      {
        'title': 'إدارة المجموعات والأسئلة',
        'subtitle': 'إنشاء، تعديل، وحذف المجموعات وإضافة أسئلة',
        'icon': Icons.group_work_rounded,
        'color': Theme.of(context).colorScheme.primary,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GroupManagementScreen(),
            ),
          );
        },
      },
      {
        'title': 'متابعة تقدم الطلاب',
        'subtitle': 'عرض الطلاب ومستوى تقدمهم في جميع المجموعات',
        'icon': Icons.bar_chart_rounded,
        'color': Theme.of(context).colorScheme.secondary,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StudentProgressScreen(),
            ),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المدير',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: const [
          ThemeToggleButton(), // ✅ إضافة زر التبديل
        ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الترحيب
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(127),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بك، أيها المدير!',
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'هنا يمكنك إدارة كل شيء يتعلق بمنصتك التعليمية.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'الإجراءات الرئيسية:',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 15.h),

            // قائمة الإجراءات
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminActions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final action = adminActions[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: action['onTap'],
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            action['icon'] as IconData,
                            size: 48.sp,
                            color: action['color'] as Color,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  action['subtitle'] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 24.sp),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
