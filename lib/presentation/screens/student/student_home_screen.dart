// lib/presentation/screens/student/student_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
// لا نحتاج لاستيراد Profile أو AuthService هنا لأننا نستخدم الـ Model مباشرة
import '../loading_screen.dart';
import 'group_selection_screen.dart';
import 'quiz_screen.dart';

// ✅ تحويل الشاشة إلى StatelessWidget للاعتماد على Provider بشكل كامل
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  // دالة بناء الواجهة في حالة عدم وجود مجموعة
  Widget _buildNoGroupState(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.group_off_rounded, size: 80, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(
          'لم تنضم إلى أي مجموعة بعد!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'الرجاء اختيار مجموعة للبدء في حل الأسئلة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () async {
            // الانتقال لشاشة الاختيار
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroupSelectionScreen(),
              ),
            );
            // ✅ إعادة تحميل الملف الشخصي بعد العودة لتحديث الشاشة فوراً
            if (context.mounted) {
              context.read<AuthStateModel>().reloadProfile();
            }
          },
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('اختيار مجموعة الآن'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }

  // دالة بناء الواجهة في حالة وجود مجموعة
  Widget _buildGroupSelectedState(BuildContext context, String groupId) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة المجموعة الحالية (UI احترافي)
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.group_rounded, size: 40, color: secondaryColor),
            title: const Text(
              'مجموعتك الحالية',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
            subtitle: Text(
              groupId, // نستخدم الـ ID حالياً، يمكن استبدالها بالاسم لاحقاً
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
        const SizedBox(height: 40),

        // زر بدء الاختبار (الزر الرئيسي والأكثر بروزاً)
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizScreen(groupId: groupId),
              ),
            );
          },
          icon: const Icon(Icons.play_circle_filled_rounded, size: 28),
          label: const Text(
            'ابدأ حل الأسئلة الآن',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            elevation: 8,
            shadowColor: secondaryColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 20),

        // زر تغيير المجموعة
        TextButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroupSelectionScreen(),
              ),
            );
            // ✅ إعادة تحميل الملف الشخصي
            if (context.mounted) {
              context.read<AuthStateModel>().reloadProfile();
            }
          },
          icon: const Icon(Icons.shuffle_rounded),
          label: const Text('تغيير المجموعة'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة حالة المصادقة والملف الشخصي من الـ Model
    final authState = context.watch<AuthStateModel>();
    final profile = authState.currentProfile;

    // 1. معالجة حالة التحميل أو عدم وجود ملف شخصي
    if (profile == null || authState.isLoadingSession) {
      return const LoadingScreen();
    }

    final hasGroup = profile.groupId != null;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
      // 2. استخدام RefreshIndicator للتحميل اليدوي
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<AuthStateModel>().reloadProfile(), // دالة التحديث
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الترحيب (UI احترافي)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك!',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'أهلاً بك في منصتك التعليمية. يمكنك الآن البدء بحل الأسئلة.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // عرض حالة المجموعة (تلقائياً)
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
