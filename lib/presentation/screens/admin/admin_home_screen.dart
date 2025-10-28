// lib/presentation/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthStateModel>().signOut(),
            tooltip: 'تسجيل الخروج',
          ),
          const SizedBox(width: 8),
        ],
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
            const SizedBox(height: 15),

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
                            size: 35,
                            color: action['color'] as Color,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  action['subtitle'] as String,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18),
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
