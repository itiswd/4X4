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

  // تهيئة مستمع Supabase - محسّن
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

      // ✅ تأكد من استدعاء notifyListeners بعد كل تحديث
      notifyListeners();
    });
  }

  // جلب بيانات المستخدم من قاعدة البيانات - محسّن
  Future<void> _fetchUserProfile() async {
    try {
      print('📥 جلب الملف الشخصي...');

      final profileMap = await _authService.getCurrentUserProfile();
      _userRole = profileMap['role'] as String?;

      print('✅ تم جلب الملف الشخصي - الدور: $_userRole');

      if (_userRole == null) {
        debugPrint('⚠️ Warning: User role is null');
        // ✅ إعادة المحاولة مرة واحدة فقط
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          final retryProfile = await _authService.getCurrentUserProfile();
          _userRole = retryProfile['role'] as String?;

          if (_userRole != null) {
            print(
              '✅ تم جلب الملف الشخصي في المحاولة الثانية - الدور: $_userRole',
            );
          } else {
            print('❌ الدور لا يزال null بعد المحاولة الثانية');
            await signOut();
            return;
          }
        } catch (retryError) {
          print('❌ فشل في المحاولة الثانية: $retryError');
          await signOut();
          return;
        }
      }

      // التحقق من صحة الدور
      if (_userRole != 'admin' && _userRole != 'student') {
        debugPrint('⚠️ Warning: Invalid user role: $_userRole');
        _userRole = null;
        await signOut();
        return;
      }

      print('✅ الدور صحيح: $_userRole');

      // ✅ استدعاء notifyListeners بعد تحديث الدور بنجاح
      notifyListeners();
    } catch (e) {
      print('❌ خطأ في جلب الملف الشخصي: $e');
      _userRole = null;

      final errorString = e.toString();

      if (errorString.contains('الملف الشخصي غير موجود')) {
        debugPrint('❌ الملف الشخصي غير موجود - تسجيل الخروج');
        await signOut();
      } else if (errorString.contains('JWT')) {
        debugPrint('❌ مشكلة في الـ Token - تسجيل الخروج');
        await signOut();
      } else {
        debugPrint('⚠️ خطأ مؤقت في جلب الملف الشخصي');

        // ✅ محاولة واحدة فقط بدلاً من اثنتين
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          final profileMap = await _authService.getCurrentUserProfile();
          _userRole = profileMap['role'] as String?;
          print('✅ تم جلب الملف الشخصي بنجاح في المحاولة الثانية');
          notifyListeners();
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
      _session = null;
      _userRole = null;
      notifyListeners();
    }
  }
}
