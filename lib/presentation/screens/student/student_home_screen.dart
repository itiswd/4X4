import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/auth_service.dart';
import 'group_selection_screen.dart';
import 'quiz_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AuthService _authService = AuthService();
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  // جلب ملف التعريف لتحديث الـ groupId
  Future<Profile> _loadProfile() async {
    final map = await _authService.getCurrentUserProfile();
    return Profile.fromMap(map);
  }

  // دالة لإعادة تحميل الملف الشخصي
  void _reloadProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
    // **التعديل هنا:** استخدام الدالة العامة الجديدة
    context.read<AuthStateModel>().reloadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الطالب'),
        actions: [
          // زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthStateModel>().signOut(),
          ),
        ],
      ),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ في تحميل الملف الشخصي: ${snapshot.error}'),
            );
          }

          final profile = snapshot.data!;
          final hasGroup = profile.groupId != null;

          if (!hasGroup) {
            // إذا لم يختر مجموعة، وجهه لصفحة الاختيار
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'الرجاء اختيار مجموعة للبدء.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // الانتقال إلى شاشة اختيار المجموعة
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GroupSelectionScreen(),
                        ),
                      );
                      _reloadProfile(); // إعادة تحميل بعد العودة للتأكد من اختيار المجموعة
                    },
                    child: const Text('اختيار مجموعة'),
                  ),
                ],
              ),
            );
          } else {
            // إذا اختار مجموعة، يمكنه بدء الاختبار
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'مرحباً بك!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'مجموعتك الحالية: ${profile.groupId}',
                    style: const TextStyle(fontSize: 16),
                  ), // سنستبدل الـ ID بالاسم لاحقاً
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              QuizScreen(groupId: profile.groupId!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'ابدأ حل الأسئلة الآن',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GroupSelectionScreen(),
                        ),
                      );
                      _reloadProfile();
                    },
                    child: const Text('تغيير المجموعة'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
