// lib/data/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  // ✅ التعديل هنا: يجب أن تكون الدالة البانية تستقبل 'client' كمعامل مُسمّى مطلوب
  AuthService({required SupabaseClient client}) : _client = client;

  // Getter لحل مشكلة 'client' المستخدم في AuthStateModel
  SupabaseClient get client => _client;

  // دالة تسجيل الدخول
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception('الملف الشخصي غير موجود. يرجى التواصل مع الدعم.');
      }
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة 🔒');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('يرجى تأكيد بريدك الإلكتروني أولاً 📧');
      }
      throw Exception(e.message);
    } catch (e) {
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
      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }

      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء المستخدم');
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      await _client.auth.signOut();
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        throw Exception('هذا البريد الإلكتروني مسجل مسبقاً');
      }
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  // دالة جلب الملف الشخصي للمستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لا يوجد مستخدم مسجل الدخول');

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) throw Exception('الملف الشخصي غير موجود');
    return response;
  }

  // دالة تحديث مجموعة الطالب
  Future<void> updateStudentGroup({required String groupId}) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لا يوجد مستخدم مسجل الدخول');

    await _client
        .from('profiles')
        .update({'group_id': groupId})
        .eq('id', userId);
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
