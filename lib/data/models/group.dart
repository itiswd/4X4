class Group {
  final String id;
  final String name;
  final String adminId;
  final String? adminName;

  Group({
    required this.id,
    required this.name,
    required this.adminId,
    this.adminName,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    String? adminName;

    // ✅ معالجة محسّنة لبيانات المدرس
    if (map['admin'] != null) {
      final admin = map['admin'];
      if (admin is Map<String, dynamic>) {
        adminName = admin['full_name'] as String?;
      } else if (admin is List && admin.isNotEmpty) {
        final adminData = admin.first as Map<String, dynamic>;
        adminName = adminData['full_name'] as String?;
      }
    }

    // ✅ محاولة بديلة (للتوافق مع الكود القديم)
    if (adminName == null && map['profiles'] != null) {
      final profiles = map['profiles'];
      if (profiles is Map<String, dynamic>) {
        adminName = profiles['full_name'] as String?;
      } else if (profiles is List && profiles.isNotEmpty) {
        final profile = profiles.first as Map<String, dynamic>;
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

  Map<String, dynamic> toMap() {
    return {'name': name, 'admin_id': adminId};
  }
}
