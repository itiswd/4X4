class Group {
  final String id;
  final String name;
  final String adminId;

  Group({required this.id, required this.name, required this.adminId});

  // لتحويل البيانات من Supabase (JSON/Map) إلى كائن Group
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      // عند القراءة من Supabase، نحصل على ID
      id: map['id'] as String,
      name: map['name'] as String,
      adminId: map['admin_id'] as String,
    );
  }

  // لتحويل كائن Group إلى Map لإرساله إلى Supabase (لعمليات الإنشاء/التحديث)
  // لا نرسل الـ ID هنا عادةً لأنه يتم إنشاؤه تلقائيًا
  Map<String, dynamic> toMap() {
    return {'name': name, 'admin_id': adminId};
  }
}
