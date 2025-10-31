class Group {
  final String id;
  final String name;
  final String adminId;
  final String? adminName; // ✅ اسم المدرس

  Group({
    required this.id,
    required this.name,
    required this.adminId,
    this.adminName,
  });

  // لتحويل البيانات من Supabase (JSON/Map) إلى كائن Group
  factory Group.fromMap(Map<String, dynamic> map) {
    // ✅ معالجة بيانات المدرس بشكل آمن
    String? adminName;

    if (map['profiles'] != null) {
      if (map['profiles'] is Map<String, dynamic>) {
        adminName =
            (map['profiles'] as Map<String, dynamic>)['full_name'] as String?;
      } else if (map['profiles'] is List &&
          (map['profiles'] as List).isNotEmpty) {
        // في بعض الحالات يرجع Supabase array
        final profile = (map['profiles'] as List).first as Map<String, dynamic>;
        adminName = profile['full_name'] as String?;
      }
    }

    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      adminId: map['admin_id'] as String,
      adminName: adminName,
    );
  }

  // لتحويل كائن Group إلى Map لإرساله إلى Supabase
  Map<String, dynamic> toMap() {
    return {'name': name, 'admin_id': adminId};
  }
}
