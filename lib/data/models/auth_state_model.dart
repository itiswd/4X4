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

      _session = session;

      // تحديث حالة التحميل
      if (_isLoadingSession) {
        _isLoadingSession = false;
      }

      // التعامل مع الأحداث المختلفة
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        if (session != null) {
          await _fetchUserProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _userRole = null;
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        // تحديث التوكن - لا حاجة لفعل شيء
        debugPrint('Token refreshed');
      }

      notifyListeners();
    });
  }

  // جلب بيانات المستخدم من قاعدة البيانات
  Future<void> _fetchUserProfile() async {
    try {
      final profileMap = await _authService.getCurrentUserProfile();
      _userRole = profileMap['role'] as String?;

      if (_userRole == null) {
        debugPrint('Warning: User role is null');
      }
    } catch (e) {
      _userRole = null;
      debugPrint('Error fetching user profile: $e');

      // في حالة عدم وجود ملف شخصي، نسجل الخروج
      if (e.toString().contains('الملف الشخصي غير موجود')) {
        await signOut();
      }
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _session = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      // في حالة فشل تسجيل الخروج، نعيد تعيين البيانات يدوياً
      _session = null;
      _userRole = null;
      notifyListeners();
    }
  }
}
