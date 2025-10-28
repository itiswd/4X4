import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    // التحقق من صحة النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔐 محاولة تسجيل الدخول للبريد: ${_emailController.text.trim()}');

      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('✅ تم تسجيل الدخول بنجاح');

      // الانتظار قليلاً للتأكد من تحديث الـ AuthStateModel
      await Future.delayed(const Duration(milliseconds: 500));

      // AuthStateModel سيقوم بالتوجيه التلقائي عبر AuthGateScreen
      // لا حاجة للـ Navigation هنا
    } on Exception catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');

      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        // ترجمة الأخطاء الشائعة
        if (errorMsg.contains('Invalid login credentials')) {
          errorMsg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (errorMsg.contains('Email not confirmed')) {
          errorMsg = 'يرجى تأكيد بريدك الإلكتروني أولاً';
        } else if (errorMsg.contains('Invalid email')) {
          errorMsg = 'البريد الإلكتروني غير صحيح';
        }

        setState(() {
          _errorMessage = errorMsg;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      print('❌ خطأ غير متوقع: $error');

      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // أيقونة تسجيل الدخول
                const Icon(Icons.login, size: 80, color: Colors.blue),
                const SizedBox(height: 20),

                // عنوان
                const Text(
                  'مرحباً بك',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'سجل دخولك للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // عرض رسالة الخطأ إن وجدت
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // حقل البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // حقل كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: '••••••',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 32),

                // زر تسجيل الدخول
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // زر الانتقال للتسجيل
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    'ليس لديك حساب؟ تسجيل جديد',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
