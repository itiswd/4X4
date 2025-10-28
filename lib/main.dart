// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'data/models/auth_state_model.dart';
import 'presentation/screens/auth/auth_gate_screen.dart';

// 🔐 Supabase Configuration

const supaBaseUrl = 'https://nopmggwpncgezhbiahhi.supabase.co';
const supaBaseUrlAnon =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcG1nZ3dwbmNnZXpoYmlhaGhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0OTY2MDUsImV4cCI6MjA3NzA3MjYwNX0.z2qgdfilN_Aj18Lyi4h4o-GDhySVQ2RfdnsVnrW-gsc';

// Global Supabase Client
final supabase = Supabase.instance.client;

// 🚀 Main Entry Point

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(url: supaBaseUrl, anonKey: supaBaseUrlAnon);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthStateModel(),
      child: const MyApp(),
    ),
  );
}

// 🎨 Main App Widget

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X base size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'التطبيق التعليمي',
          debugShowCheckedModeBanner: false,

          // ✨ استخدام الثيمات من ملف منفصل
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // يتبع إعدادات النظام
          // 📱 إعدادات التطبيق
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).size.width > 600 ? 1.1 : 1.0,
                  ),
                ),
                child: child!,
              ),
            );
          },

          // 🏠 الشاشة الرئيسية
          home: const AuthGateScreen(),
        );
      },
    );
  }
}
