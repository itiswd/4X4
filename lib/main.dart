// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/models/auth_state_model.dart';
import 'presentation/screens/auth/auth_gate_screen.dart';

// تعريف الـ URL والـ Key
const supaBaseUrl = 'https://nopmggwpncgezhbiahhi.supabase.co';
const supaBaseUrlAnon =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcG1nZ3dwbmNnZXpoYmlhaGhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0OTY2MDUsImV4cCI6MjA3NzA3MjYwNX0.z2qgdfilN_Aj18Lyi4h4o-GDhySVQ2RfdnsVnrW-gsc';

// تعريف متغير Supabase Client
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supaBaseUrl, anonKey: supaBaseUrlAnon);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthStateModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان الاحترافية (Dark Teal/Green و Amber/Gold)
    const Color primaryColor = Color(0xFF004D40);
    const Color secondaryColor = Color(0xFFFFB300);

    return MaterialApp(
      title: 'Educational App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // استخدام Material 3
        useMaterial3: true,
        // ✅ تحديد الخط العربي (يجب التأكد من إضافة هذا الخط في ملف pubspec.yaml)
        fontFamily: 'Cairo',
        // تحديد الـ Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          // تصميم حدود حقول الإدخال
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // تصميم الزر الرئيسي
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      // ✅ فرض الاتجاه من اليمين لليسار (RTL) على جميع الشاشات
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const AuthGateScreen(),
    );
  }
}
