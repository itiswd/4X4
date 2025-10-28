import 'package:educational_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/auth_state_model.dart';
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

  // يجب أن يتم تهيئة AuthService هنا لاستخدامها داخل الـ State
  final AuthService _authService = AuthService(
    client: supabase,
  ); // افترض أن supabase متاح

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. محاولة تسجيل الدخول
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ فحص mounted: إذا تم إلغاء تثبيت الـ Widget أثناء الانتظار، نخرج فوراً
      if (!mounted) return;

      // 2. تحديث حالة Provider (سيؤدي هذا إلى التوجيه)
      await context.read<AuthStateModel>().reloadProfile();
    } on Exception catch (e) {
      // ✅ فحص mounted: قبل استخدام context لعرض SnackBar
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        // تنسيق رسائل الأخطاء
        if (errorMsg.contains('Invalid login credentials')) {
          errorMsg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔒';
        } else if (errorMsg.contains('Email not confirmed')) {
          errorMsg = 'يرجى تأكيد بريدك الإلكتروني أولاً 📧';
        } else if (errorMsg.contains('Invalid email')) {
          errorMsg = 'البريد الإلكتروني غير صحيح';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, textAlign: TextAlign.right),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // ✅ فحص mounted: قبل استخدام setState لإيقاف مؤشر التحميل
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل الدخول',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            // استخدام بطاقة احترافية
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 70,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 15),

                    Text(
                      'مرحباً بك مجدداً',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'أدخل بياناتك للمتابعة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

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
                    const SizedBox(height: 20),

                    // حقل كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textDirection: TextDirection.ltr,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: '••••••',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
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

                    const SizedBox(height: 30),

                    // زر تسجيل الدخول
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                    ),

                    const SizedBox(height: 15),

                    // زر التسجيل الجديد
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
                      child: Text(
                        'ليس لديك حساب؟ تسجيل جديد',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
