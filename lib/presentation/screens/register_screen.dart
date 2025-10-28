import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _selectedRole = 'student';
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // التحقق من صحة النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم التسجيل بنجاح كـ ${_selectedRole == 'admin' ? 'مدير' : 'طالب'}! يمكنك الآن تسجيل الدخول.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // الانتظار قليلاً ثم العودة لشاشة تسجيل الدخول
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      // استخراج رسالة الخطأ
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب جديد'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // أيقونة تسجيل
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 20),

                // حقل البريد الإلكتروني
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
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
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // حقل كلمة المرور
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'يجب أن تكون 6 أحرف على الأقل',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // اختيار الدور
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'التسجيل كـ:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RadioListTile<String>(
                          title: const Text('طالب'),
                          subtitle: const Text('للدخول وحل الأسئلة'),
                          value: 'student',
                          groupValue: _selectedRole,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() => _selectedRole = value!);
                                },
                        ),
                        RadioListTile<String>(
                          title: const Text('مدير/مدرس'),
                          subtitle: const Text('لإنشاء المجموعات والأسئلة'),
                          value: 'admin',
                          groupValue: _selectedRole,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() => _selectedRole = value!);
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // زر التسجيل
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            'تسجيل حساب جديد',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // زر الانتقال لتسجيل الدخول
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
