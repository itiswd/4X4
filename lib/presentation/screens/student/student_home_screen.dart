import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/auth_state_model.dart';
import '../../../data/services/group_service.dart';
import '../loading_screen.dart';
import 'group_selection_screen.dart';
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
    // ✅ نبدأ بتحميل بيانات المجموعة فقط إذا كانت الشاشة لا تزال في شجرة الـ widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData();
    });
  }

  // ✅ دالة جديدة: لجلب اسم المجموعة باستخدام الـ ID
  Future<void> _loadGroupData() async {
    // يجب فحص mounted قبل استخدام context إذا كانت الدالة تُستدعى خارج initState
    if (!mounted) return;

    final authState = context.read<AuthStateModel>();
    final groupId = authState.currentProfile?.groupId;

    if (groupId != null) {
      final name = await _groupService.getGroupNameById(groupId);

      // ✅ فحص mounted قبل استخدام setState
      if (mounted) {
        setState(() {
          _groupName = name;
          _isGroupDataLoading = false;
        });
      }
    } else {
      // ✅ فحص mounted قبل استخدام setState
      if (mounted) {
        setState(() {
          _groupName = null;
          _isGroupDataLoading = false;
        });
      }
    }
  }

  // ✅ دالة التحديث المخصصة للـ RefreshIndicator
  Future<void> _handleRefresh() async {
    // 1. تحديث ملف تعريف المستخدم
    await context.read<AuthStateModel>().reloadProfile();

    // ✅ فحص mounted قبل الاستمرار في تحديث الحالة المحلية
    if (!mounted) return;

    // 2. إعادة تحميل بيانات المجموعة بناءً على الـ ID الجديد
    await _loadGroupData();
  }

  // -------------------------------------------------------------------
  // دوال بناء الواجهة
  // -------------------------------------------------------------------

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
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroupSelectionScreen(),
              ),
            );
            if (context.mounted) {
              await _handleRefresh(); // استخدام دالة التحديث الجديدة
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

  Widget _buildGroupSelectedState(BuildContext context, String groupId) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // حالة التحميل أثناء جلب اسم المجموعة
    if (_isGroupDataLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // اسم المجموعة المعروض
    final displayGroupName =
        _groupName ?? 'غير معروفة (${groupId.substring(0, 4)}...)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة المجموعة الحالية (عرض الاسم بدلاً من الـ ID)
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.group_rounded, size: 40, color: secondaryColor),
            title: const Text(
              'مجموعتك الحالية:',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            ),
            subtitle: Text(
              displayGroupName, // ✅ عرض الاسم
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 20,
              ),
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
        const SizedBox(height: 40),

        // زر بدء الاختبار
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
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
            if (context.mounted) {
              await _handleRefresh(); // استخدام دالة التحديث الجديدة
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
    // مراقبة حالة المصادقة والملف الشخصي من الـ Model
    final authState = context.watch<AuthStateModel>();
    final profile = authState.currentProfile;

    // 1. معالجة حالة التحميل
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
        onRefresh: _handleRefresh, // ربط دالة التحديث الجديدة
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
