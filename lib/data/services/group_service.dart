// lib/data/services/group_service.dart
import '../../main.dart'; // للوصول إلى supabase client
import '../models/group.dart';
import '../models/profile.dart';

class GroupService {
  Future<String?> getGroupNameById(String groupId) async {
    final response = await supabase
        .from('groups')
        .select('name')
        .eq('id', groupId)
        .maybeSingle();

    if (response != null && response['name'] is String) {
      return response['name'] as String;
    }
    return null;
  }

  // ✅ هذه هي الدالة المسؤولة عن جلب المجموعات المتاحة
  Future<List<Group>> getAllGroups() async {
    final List<Map<String, dynamic>> response = await supabase
        .from('groups')
        .select(
          '*, admin_name', // ✅ جلب admin_name مباشرة
        )
        .order('name', ascending: true);

    return response.map((map) => Group.fromMap(map)).toList();
  }

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

  Future<List<Profile>> getStudentsInGroup(String groupId) async {
    final List<Map<String, dynamic>> response = await supabase
        .from('profiles')
        .select()
        .eq('role', 'student')
        .eq('group_id', groupId);

    return response.map((map) => Profile.fromMap(map)).toList();
  }

  Future<void> createGroup({required String name}) async {
    final String? adminId = supabase.auth.currentUser?.id;
    if (adminId == null) {
      throw Exception('Admin user not logged in.');
    }

    await supabase.from('groups').insert({'name': name, 'admin_id': adminId});
  }

  Future<void> updateGroup({
    required String id,
    required String newName,
  }) async {
    await supabase.from('groups').update({'name': newName}).eq('id', id);
  }

  Future<void> deleteGroup({required String id}) async {
    await supabase.from('groups').delete().eq('id', id);
  }
}
