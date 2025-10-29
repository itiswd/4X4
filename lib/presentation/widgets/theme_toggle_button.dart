import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/models/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: 24.sp,
      ),
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: themeProvider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
    );
  }
}
