import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../services/auth_service.dart';

class AuthStateModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Session? _session;
  String? _userRole;
  bool _isLoadingSession = true;

  AuthStateModel() {
    _initAuthListener();
  }

  // Getters
  bool get isLoggedIn => _session != null;
  bool get isAdmin => _userRole == 'admin';
  bool get isStudent => _userRole == 'student';
  bool get isLoadingSession => _isLoadingSession;
  String? get userRole => _userRole;

  // دالة عامة لتحديث الملف الشخصي
  Future<void> reloadProfile() async {
    if (_session != null) {
      await _fetchUserProfile();
      notifyListeners();
    }
  }

  // تهيئة مستمع Supabase
  void _initAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('🔄 Auth Event: $event');

      _session = session;

      // تحديث حالة التحميل
      if (_isLoadingSession) {
        _isLoadingSession = false;
      }

      // التعامل مع الأحداث المختلفة
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        if (session != null) {
          print('✅ Session found - User: ${session.user.email}');
          await _fetchUserProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        print('👋 User signed out');
        _userRole = null;
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        print('🔄 Token refreshed');
      }

      notifyListeners();
    });
  }

  // جلب بيانات المستخدم من قاعدة البيانات
  Future<void> _fetchUserProfile() async {
    try {
      print('📥 جلب الملف الشخصي...');

      final profileMap = await _authService.getCurrentUserProfile();

      _userRole = profileMap['role'] as String?;

      print('✅ تم جلب الملف الشخصي - الدور: $_userRole');

      if (_userRole == null) {
        debugPrint('⚠️ Warning: User role is null');
        // لا نسجل الخروج، ربما الـ role لسه بيتم إنشاؤه
        return;
      }

      // التحقق من صحة الدور
      if (_userRole != 'admin' && _userRole != 'student') {
        debugPrint('⚠️ Warning: Invalid user role: $_userRole');
        _userRole = null;
        await signOut();
        return;
      }

      print('✅ الدور صحيح: $_userRole');
    } catch (e) {
      print('❌ خطأ في جلب الملف الشخصي: $e');

      _userRole = null;

      // التحقق من نوع الخطأ
      final errorString = e.toString();

      if (errorString.contains('الملف الشخصي غير موجود')) {
        debugPrint('❌ الملف الشخصي غير موجود - تسجيل الخروج');
        await signOut();
      } else if (errorString.contains('JWT')) {
        // مشكلة في الـ Token - تسجيل الخروج
        debugPrint('❌ مشكلة في الـ Token - تسجيل الخروج');
        await signOut();
      } else {
        // أخطاء أخرى - نحاول مرة أخرى بعد ثانية
        debugPrint('⚠️ خطأ مؤقت في جلب الملف الشخصي - سيتم إعادة المحاولة');

        await Future.delayed(const Duration(seconds: 1));

        // محاولة إعادة جلب الملف الشخصي مرة واحدة فقط
        try {
          final profileMap = await _authService.getCurrentUserProfile();
          _userRole = profileMap['role'] as String?;
          print('✅ تم جلب الملف الشخصي بنجاح في المحاولة الثانية');
        } catch (retryError) {
          print('❌ فشل في المحاولة الثانية: $retryError');
          await signOut();
        }
      }
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      print('👋 تسجيل الخروج...');
      await _authService.signOut();
      _session = null;
      _userRole = null;
      notifyListeners();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ أثناء تسجيل الخروج: $e');
      // في حالة فشل تسجيل الخروج، نعيد تعيين البيانات يدوياً
      _session = null;
      _userRole = null;
      notifyListeners();
    }
  }
}
