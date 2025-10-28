// lib/presentation/screens/register_screen.dart
import 'package:educational_app/main.dart';
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
  final AuthService _authService = AuthService(client: supabase);

  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: _selectedRole,
        groupId: null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم التسجيل بنجاح كـ ${_selectedRole == 'admin' ? 'مدير' : 'طالب'}!\n'
            'الرجاء تسجيل الدخول الآن.',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, textAlign: TextAlign.right),
          backgroundColor: Theme.of(context).colorScheme.error,
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
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
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
                  children: <Widget>[
                    Icon(
                      Icons.person_add_alt_1,
                      size: 70,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 15),

                    Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 30),

                    // حقل البريد الإلكتروني
                    TextFormField(
                      controller: emailController,
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
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // حقل كلمة المرور
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      textDirection: TextDirection.ltr,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: 'يجب أن تكون 6 أحرف على الأقل',
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
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24.0),

                    // اختيار الدور (في بطاقة أنيقة)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16.0,
                              top: 8.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              'التسجيل كـ:',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          RadioListTile<String>(
                            title: const Text('طالب'),
                            subtitle: const Text('للدخول وحل الأسئلة'),
                            value: 'student',
                            groupValue: _selectedRole,
                            activeColor: Theme.of(context).colorScheme.primary,
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
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() => _selectedRole = value!);
                                  },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // زر التسجيل
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('إنشاء الحساب'),
                    ),

                    const SizedBox(height: 15.0),

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
        ),
      ),
    );
  }
}
