import 'package:flutter/material.dart';

/// مجموعة الألوان الرئيسية للتطبيق التعليمي
class AppColors {
  AppColors._();

  // ✨ الألوان الأساسية - مناسبة للأطفال
  static const Color primary = Color(0xFF4CAF50); // أخضر مريح للعين
  static const Color primaryLight = Color(0xFF81C784); // أخضر فاتح
  static const Color primaryDark = Color(0xFF388E3C); // أخضر داكن

  static const Color secondary = Color(0xFFFF9800); // برتقالي دافئ
  static const Color secondaryLight = Color(0xFFFFB74D); // برتقالي فاتح
  static const Color secondaryDark = Color(0xFFF57C00); // برتقالي داكن

  static const Color accent = Color(0xFF2196F3); // أزرق سماوي
  static const Color accentLight = Color(0xFF64B5F6); // أزرق فاتح

  // 🎯 ألوان الحالات
  static const Color success = Color(0xFF66BB6A); // أخضر للنجاح
  static const Color warning = Color(0xFFFFA726); // برتقالي للتحذير
  static const Color error = Color(0xFFEF5350); // أحمر للخطأ
  static const Color info = Color(0xFF42A5F5); // أزرق للمعلومات

  // 🎨 الألوان المحايدة
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // 🌈 ألوان إضافية للعناصر التعليمية
  static const Color purple = Color(0xFF9C27B0); // بنفسجي
  static const Color pink = Color(0xFFE91E63); // وردي
  static const Color teal = Color(0xFF009688); // تركواز
  static const Color amber = Color(0xFFFFC107); // كهرماني

  // 📊 ألوان التقييم
  static const Color excellent = Color(0xFF4CAF50); // ممتاز (أخضر)
  static const Color good = Color(0xFF8BC34A); // جيد (أخضر فاتح)
  static const Color average = Color(0xFFFF9800); // متوسط (برتقالي)
  static const Color poor = Color(0xFFFF5722); // ضعيف (برتقالي محمر)

  // 🎭 ألوان الخلفيات
  static const Color backgroundLight = Color(0xFFFFFBF5); // خلفية كريمية فاتحة
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // 📝 ألوان النصوص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // 🔲 ألوان الحدود
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF9E9E9E);

  // 💫 ألوان الظلال
  static Color shadowLight = Colors.black.withAlpha(13);
  static Color shadowMedium = Colors.black.withAlpha(25);
  static Color shadowDark = Colors.black.withAlpha(38);

  // 🎨 Gradients - تدرجات لونية جميلة
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌟 دالة للحصول على لون حسب النسبة المئوية
  static Color getPerformanceColor(double percentage) {
    if (percentage >= 90) return excellent;
    if (percentage >= 75) return good;
    if (percentage >= 50) return average;
    return poor;
  }
}
