// lib/main.dart
import 'package:educational_app/data/models/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  await Supabase.initialize(url: supaBaseUrl, anonKey: supaBaseUrlAnon);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthStateModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // ✅ إضافة
      ],
      child: const MyApp(),
    ),
  );
}

// 🎨 Main App Widget

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'التطبيق التعليمي',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode, // ✅ استخدام ThemeProvider
          builder: (context, child) {
            // 🔧 تخصيص الـ System UI Overlay
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // شريط الحالة شفاف
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarColor:
                    Colors.transparent, // شريط التنقل شفاف
                systemNavigationBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );

            // 🎯 تفعيل وضع Edge-to-Edge
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
