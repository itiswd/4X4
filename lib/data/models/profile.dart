class Profile {
  final String id;
  final String email;
  final String role; // 'admin' or 'student'
  final String? groupId; // Null if admin

  Profile({
    required this.id,
    required this.email,
    required this.role,
    this.groupId,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      groupId: map['group_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'role': role, 'group_id': groupId};
  }
}
