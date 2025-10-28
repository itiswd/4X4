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

  // دالة تسجيل حساب جديد - محسّنة
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    String? groupId,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      print('🚀 بدء عملية التسجيل للبريد: $email بدور: $role');

      // إنشاء المستخدم في Supabase Auth
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء المستخدم');
      }

      final String userId = response.user!.id;
      print('✅ تم إنشاء المستخدم: $userId');

      // ✅ تقليل وقت الانتظار من 1500ms إلى 500ms
      print('⏳ انتظار إنشاء الملف الشخصي...');
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ محاولة التحقق من الـ Profile مع إعادة المحاولة
      int attempts = 0;
      Map<String, dynamic>? checkProfile;

      while (attempts < 3 && checkProfile == null) {
        try {
          checkProfile = await supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

          if (checkProfile != null) {
            print('✅ تم التحقق من الملف الشخصي: $checkProfile');

            final storedRole = checkProfile['role'] as String?;
            if (storedRole == role) {
              print('✅ الدور صحيح: $storedRole');
            } else {
              print(
                '⚠️ الدور المُخزن ($storedRole) لا يطابق الدور المطلوب ($role)',
              );
            }
            break;
          }
        } catch (e) {
          print('⚠️ محاولة ${attempts + 1}: فشل التحقق من الملف الشخصي');
        }

        attempts++;
        if (checkProfile == null && attempts < 3) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (checkProfile == null) {
        print('⚠️ لم يتم العثور على الملف الشخصي بعد 3 محاولات');
        // لا نرمي exception، المستخدم تم إنشاؤه بنجاح
      }

      // تسجيل الخروج بعد التسجيل الناجح
      await supabase.auth.signOut();
      print('✅ تم تسجيل الخروج بعد إنشاء الحساب بنجاح');
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');

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

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
