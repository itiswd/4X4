import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';

class AuthService {
  // دالة تسجيل الدخول
  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  // دالة تسجيل حساب جديد
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    String? groupId,
  }) async {
    try {
      // 1. التحقق من صحة البيانات المدخلة
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      // 2. إنشاء المستخدم في Supabase Auth
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 3. التحقق من نجاح إنشاء المستخدم
      if (response.user == null) {
        throw Exception('فشل في إنشاء المستخدم');
      }

      final String userId = response.user!.id;

      // 4. الانتظار قليلاً للتأكد من إتمام عملية التسجيل
      await Future.delayed(const Duration(milliseconds: 500));

      // 5. إنشاء ملف المستخدم في جدول profiles
      try {
        await supabase.from('profiles').insert({
          'id': userId,
          'email': email,
          'role': role,
          'group_id': role == 'student' ? groupId : null,
        });
      } catch (dbError) {
        // إذا فشل إنشاء الـ Profile، نحاول حذف المستخدم من Auth
        print('خطأ في إنشاء الملف الشخصي: $dbError');

        // محاولة التنظيف (اختياري)
        try {
          await supabase.auth.signOut();
        } catch (_) {}

        throw Exception('فشل في إنشاء الملف الشخصي في قاعدة البيانات');
      }
    } on AuthException catch (e) {
      print('Auth Error: ${e.message}');

      // ترجمة الأخطاء الشائعة
      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        throw Exception('هذا البريد الإلكتروني مسجل مسبقاً');
      } else if (e.message.contains('Password')) {
        throw Exception('كلمة المرور ضعيفة جداً');
      } else if (e.message.contains('Email')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      throw Exception(e.message);
    } catch (e) {
      print('General Error: $e');
      rethrow;
    }
  }

  // دالة تحديث مجموعة الطالب
  Future<void> updateStudentGroup({required String groupId}) async {
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    try {
      await supabase
          .from('profiles')
          .update({'group_id': groupId})
          .eq('id', userId);
    } catch (e) {
      print('خطأ في تحديث المجموعة: $e');
      throw Exception('فشل تحديث المجموعة');
    }
  }

  // دالة جلب الملف الشخصي للمستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception('الملف الشخصي غير موجود');
      }

      return response;
    } catch (e) {
      print('خطأ في جلب الملف الشخصي: $e');
      rethrow;
    }
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
