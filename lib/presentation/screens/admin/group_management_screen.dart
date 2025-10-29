import 'package:educational_app/config/app_colors.dart';
import 'package:educational_app/data/models/group.dart';
import 'package:educational_app/data/models/theme_provider.dart';
import 'package:educational_app/main.dart';
import 'package:educational_app/presentation/screens/admin/quiz_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../data/services/group_service.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final GroupService _groupService = GroupService();
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupService.getAdminGroups();
  }

  void _reloadGroups() {
    setState(() {
      _groupsFuture = _groupService.getAdminGroups();
    });
  }

  void _showGroupDialog({Group? group}) {
    final isEditing = group != null;
    final controller = TextEditingController(text: isEditing ? group.name : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'تعديل المجموعة' : 'إضافة مجموعة جديدة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم المجموعة',
              hintText: 'مثال: الصف الأول الابتدائي',
            ),
            // autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                try {
                  if (isEditing) {
                    await _groupService.updateGroup(
                      id: group.id,
                      newName: controller.text.trim(),
                    );
                  } else {
                    await _groupService.createGroup(
                      name: controller.text.trim(),
                    );
                  }
                  _reloadGroups();
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'تعديل' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(String groupId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذه المجموعة؟\nسيتم حذف جميع الأسئلة المرتبطة بها.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupService.deleteGroup(id: groupId);
        _reloadGroups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المجموعة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString()}')));
        }
      }
    }
  }

  Widget _buildGroupCard(Group group) {
    return FutureBuilder<Map<String, int>>(
      future: _getGroupStats(group.id),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'questions': 0, 'quizzes': 0, 'students': 0};
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => QuizManagementScreen(group: group),
                    ),
                  )
                  .then((_) => _reloadGroups());
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان والأزرار
                  Row(
                    children: [
                      // أيقونة المجموعة
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(179),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(64),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.folder_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // اسم المجموعة
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (isLoading)
                              SizedBox(
                                height: 16.h,
                                width: 16.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 1,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${stats['students']} ${stats['students'] == 1 ? 'طالب' : 'طلاب'}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // أزرار التحكم
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 24.sp),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showGroupDialog(group: group);
                          } else if (value == 'delete') {
                            _deleteGroup(group.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8.w),
                                const Text('تعديل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8.w),
                                const Text('حذف'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // إحصائيات المجموعة
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: context.watch<ThemeProvider>().isDarkMode
                          ? AppColors.grey900
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.watch<ThemeProvider>().isDarkMode
                            ? AppColors.grey900
                            : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // عدد الكويزات
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.quiz_rounded,
                            label: 'كويز',
                            value: stats['quizzes']!,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: AppColors.borderLight,
                        ),
                        // عدد الأسئلة
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.help_outline_rounded,
                            label: 'سؤال',
                            value: stats['questions']!,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // زر الدخول للكويزات
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha(25),
                          Theme.of(context).colorScheme.primary.withAlpha(51),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'عرض وإدارة الكويزات',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: color),
        SizedBox(height: 4.h),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ✅ دالة جلب إحصائيات المجموعة
  Future<Map<String, int>> _getGroupStats(String groupId) async {
    try {
      // عدد الكويزات
      final quizzesResponse = await supabase
          .from('quizzes')
          .select('id')
          .eq('group_id', groupId);
      final quizzesCount = (quizzesResponse as List).length;

      // عدد الأسئلة
      final questionsResponse = await supabase
          .from('questions')
          .select('id')
          .eq('group_id', groupId);
      final questionsCount = (questionsResponse as List).length;

      // عدد الطلاب
      final studentsResponse = await supabase
          .from('profiles')
          .select('id')
          .eq('role', 'student')
          .eq('group_id', groupId);
      final studentsCount = (studentsResponse as List).length;

      return {
        'quizzes': quizzesCount,
        'questions': questionsCount,
        'students': studentsCount,
      };
    } catch (e) {
      return {'quizzes': 0, 'questions': 0, 'students': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المجموعات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text('خطأ في تحميل المجموعات'),
                  SizedBox(height: 8.h),
                  ElevatedButton.icon(
                    onPressed: _reloadGroups,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد مجموعات بعد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط على الزر أدناه لإضافة مجموعة جديدة',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadGroups(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 92.h),
              itemCount: groups.length,
              itemBuilder: (context, index) => _buildGroupCard(groups[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showGroupDialog(),
        icon: const Icon(Icons.add_box, color: AppColors.white),
        label: const Text(
          'إضافة مجموعة',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
