import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart'; // للوصول إلى متغير supabase

class AuthService {
  // دالة تسجيل الدخول
  Future<void> signIn({required String email, password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  // دالة تسجيل حساب جديد
  Future<void> signUp({
    required String email,
    required String password,
    required String role, // 'admin' or 'student'
    String? groupId, // يُستخدم فقط إذا كان الدور student
  }) async {
    try {
      // 1. إنشاء المستخدم في Supabase Auth
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final String? userId = response.user?.id;

      if (userId == null) {
        throw Exception('فشل في إنشاء المستخدم. الـ ID مفقود.');
      }

      // 2. إنشاء ملف المستخدم في جدول 'profiles'
      await supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'role': role,
        // group_id يُرسل فقط إذا كان الدور طالبًا
        'group_id': role == 'student' ? groupId : null,
      });
    } on AuthException catch (e) {
      // **طباعة أخطاء المصادقة (مثل كلمة المرور أو البريد الإلكتروني)**
      print('Auth Error during sign up: ${e.message}');
      rethrow;
    } catch (e) {
      // **طباعة أي أخطاء أخرى (مثل أخطاء قاعدة البيانات عند إنشاء Profile)**
      print('General Error during sign up: ${e.toString()}');
      rethrow;
    }
  }

  // دالة تحديث مجموعة الطالب
  Future<void> updateStudentGroup({required String groupId}) async {
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول.');
    }

    await supabase
        .from('profiles')
        .update({'group_id': groupId})
        .eq('id', userId);
  }

  // دالة جلب الملف الشخصي للمستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول.');
    }

    // جلب ملف التعريف من جدول profiles
    final Map<String, dynamic> response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
