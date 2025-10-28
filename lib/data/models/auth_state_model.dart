import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../services/auth_service.dart';

class AuthStateModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Session? _session;
  String? _userRole; // 'admin' or 'student'
  // **متغير جديد لتتبع حالة تحميل الجلسة الأولية**
  bool _isLoadingSession = true;

  AuthStateModel() {
    _initAuthListener();
  }

  // Getter للوصول للحالة من أي مكان
  bool get isLoggedIn => _session != null;
  bool get isAdmin => _userRole == 'admin';
  bool get isStudent => _userRole == 'student';
  // **Getter عام جديد للوصول لحالة تحميل الجلسة**
  bool get isLoadingSession => _isLoadingSession;

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

      if (_isLoadingSession) {
        // بمجرد أن نتلقى أول حدث، نعلم أن الجلسة الأولية قد تم تحميلها
        _isLoadingSession = false;
      }

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        if (session != null) {
          await _fetchUserProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  // الدالة الخاصة (Private) التي تقوم بالجلب الفعلي
  Future<void> _fetchUserProfile() async {
    try {
      final profileMap = await _authService.getCurrentUserProfile();
      _userRole = profileMap['role'];
    } catch (e) {
      _userRole = null;
      debugPrint('Error fetching user profile: $e');
    }
  }

  // تحديث الدالة لتسجيل الخروج
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
