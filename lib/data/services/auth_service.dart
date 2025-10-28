import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';

class AuthService {
  // دالة تسجيل الدخول
  Future<void> signIn({required String email, required String password}) async {
    try {
      print('🔐 محاولة تسجيل الدخول: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      print('✅ تم تسجيل الدخول بنجاح - User ID: ${response.user!.id}');

      // التحقق من وجود الـ Profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profile == null) {
        print('⚠️ الملف الشخصي غير موجود');
        throw Exception('الملف الشخصي غير موجود. يرجى التواصل مع الدعم.');
      }

      print('✅ تم العثور على الملف الشخصي - الدور: ${profile['role']}');
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');

      if (e.message.contains('Invalid login credentials')) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('يرجى تأكيد بريدك الإلكتروني أولاً');
      }

      throw Exception(e.message);
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      rethrow;
    }
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

      print('🚀 بدء عملية التسجيل للبريد: $email بدور: $role');

      // 2. إنشاء المستخدم في Supabase Auth
      // الـ Trigger سيتولى إنشاء الـ profile تلقائياً
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role, // الـ Trigger سيقرأ الـ role من هنا
        },
      );

      // 3. التحقق من نجاح إنشاء المستخدم
      if (response.user == null) {
        throw Exception('فشل في إنشاء المستخدم');
      }

      final String userId = response.user!.id;
      print('✅ تم إنشاء المستخدم: $userId');

      // 4. الانتظار حتى يتم إنشاء الـ profile بواسطة الـ Trigger
      print('⏳ انتظار إنشاء الملف الشخصي...');
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. التحقق من إنشاء الـ Profile
      try {
        final checkProfile = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (checkProfile == null) {
          print('⚠️ لم يتم العثور على الملف الشخصي');
          throw Exception('لم يتم إنشاء الملف الشخصي. يرجى المحاولة مرة أخرى.');
        }

        print('✅ تم التحقق من الملف الشخصي: $checkProfile');

        // التحقق من صحة الدور
        final storedRole = checkProfile['role'] as String?;
        if (storedRole != role) {
          print(
            '⚠️ الدور المُخزن ($storedRole) لا يطابق الدور المطلوب ($role)',
          );
        } else {
          print('✅ الدور صحيح: $storedRole');
        }
      } catch (profileError) {
        print('❌ خطأ في التحقق من الملف الشخصي: $profileError');
        // لا نرمي exception هنا، لأن المستخدم تم إنشاؤه بنجاح
      }

      // 6. تسجيل الخروج بعد التسجيل الناجح
      await supabase.auth.signOut();
      print('✅ تم تسجيل الخروج بعد إنشاء الحساب بنجاح');
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');

      // ترجمة الأخطاء الشائعة
      if (e.message.contains('already registered') ||
          e.message.contains('already exists') ||
          e.message.contains('User already registered')) {
        throw Exception('هذا البريد الإلكتروني مسجل مسبقاً');
      } else if (e.message.contains('Password')) {
        throw Exception('كلمة المرور ضعيفة جداً');
      } else if (e.message.contains('Email')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      throw Exception(e.message);
    } catch (e) {
      print('❌ General Error: $e');
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

      print('✅ تم تحديث المجموعة بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث المجموعة: $e');
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
      print('❌ خطأ في جلب الملف الشخصي: $e');
      rethrow;
    }
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
