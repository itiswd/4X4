// lib/data/models/profile.dart

class Profile {
  final String id;
  final String email;
  final String role;
  final String? groupId;
  final String fullName; // ✅ حقل الاسم الكامل

  Profile({
    required this.id,
    required this.email,
    required this.role,
    this.groupId,
    required this.fullName,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      groupId: map['group_id'] as String?,
      fullName: map['full_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'group_id': groupId,
      'full_name': fullName,
    };
  }
}
