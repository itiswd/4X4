import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/auth_state_model.dart';
import 'admin/admin_home_screen.dart';
import 'loading_screen.dart';
import 'login_screen.dart';
import 'student/student_home_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateModel>();

    // إذا كانت حالة تحميل الجلسة الأولية لا تزال نشطة، اعرض شاشة التحميل.
    if (authState.isLoadingSession) {
      return const LoadingScreen();
    }

    if (!authState.isLoggedIn) {
      // إذا لم يكن مسجل الدخول، انتقل إلى شاشة تسجيل الدخول
      return const LoginScreen();
    }

    // إذا كان مسجل الدخول، توجه حسب الدور
    if (authState.isAdmin) {
      return const AdminHomeScreen();
    } else if (authState.isStudent) {
      return const StudentHomeScreen();
    } else {
      // حالة إذا كان مسجل الدخول ولكن الدور غير معروف (يحدث فقط إذا لم يتم التحميل بالكامل)
      return const LoadingScreen();
    }
  }
}
