import 'package:educational_app/presentation/screens/admin/student_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import 'group_management_screen.dart'; // سننشئها الآن // سننشئها لاحقا

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        actions: [
          // زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthStateModel>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة إدارة المجموعات والأسئلة
            Card(
              child: ListTile(
                leading: const Icon(Icons.group, size: 40, color: Colors.blue),
                title: const Text('إدارة المجموعات والأسئلة'),
                subtitle: const Text(
                  'إنشاء، تعديل، وحذف المجموعات وإضافة أسئلة',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GroupManagementScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // بطاقة عرض الطلاب والتقدم
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.analytics,
                  size: 40,
                  color: Colors.green,
                ),
                title: const Text('متابعة تقدم الطلاب'),
                subtitle: const Text('عرض الطلاب ومستوى تقدمهم في المجموعات'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudentProgressScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
