import '../../main.dart'; // للوصول إلى متغير supabase
import '../models/group.dart';
import '../models/profile.dart'; // نحتاج لنموذج Profile لجلب الطلاب

class GroupService {
  // الحصول على جميع المجموعات التي أنشأها المدرس الحالي
  Future<List<Group>> getAdminGroups() async {
    final String? adminId = supabase.auth.currentUser?.id;
    if (adminId == null) {
      throw Exception('Admin user not logged in.');
    }

    final List<Map<String, dynamic>> response = await supabase
        .from('groups')
        .select()
        .eq('admin_id', adminId);

    return response.map((map) => Group.fromMap(map)).toList();
  }

  // دالة جديدة: الحصول على جميع المجموعات (للطالب والمدرس)
  Future<List<Group>> getAllGroups() async {
    // RLS تضمن أن المستخدمين الموثقين فقط يمكنهم الرؤية
    final List<Map<String, dynamic>> response = await supabase
        .from('groups')
        .select()
        .order('name', ascending: true);

    return response.map((map) => Group.fromMap(map)).toList();
  }

  // دالة جديدة: جلب جميع الطلاب في مجموعة معينة
  Future<List<Profile>> getStudentsInGroup(String groupId) async {
    // جلب ملفات التعريف التي دورها طالب والمنضمة لهذه المجموعة
    final List<Map<String, dynamic>> response = await supabase
        .from('profiles')
        .select()
        .eq('role', 'student')
        .eq('group_id', groupId);

    return response.map((map) => Profile.fromMap(map)).toList();
  }

  // إنشاء مجموعة جديدة
  Future<void> createGroup({required String name}) async {
    final String? adminId = supabase.auth.currentUser?.id;
    if (adminId == null) {
      throw Exception('Admin user not logged in.');
    }

    final Group newGroup = Group(
      id: '', // سيتم إنشاؤه في قاعدة البيانات
      name: name,
      adminId: adminId,
    );

    // استخدام toMap لتضمين admin_id
    await supabase.from('groups').insert(newGroup.toMap());
  }

  // تعديل مجموعة موجودة
  Future<void> updateGroup({
    required String id,
    required String newName,
  }) async {
    await supabase.from('groups').update({'name': newName}).eq('id', id);
  }

  // حذف مجموعة
  Future<void> deleteGroup({required String id}) async {
    await supabase.from('groups').delete().eq('id', id);
  }
}
