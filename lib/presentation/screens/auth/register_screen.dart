// lib/presentation/screens/register_screen.dart
import 'package:educational_app/data/models/group.dart';
import 'package:educational_app/data/services/auth_service.dart';
import 'package:educational_app/data/services/group_service.dart';
import 'package:educational_app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  final AuthService _authService = AuthService(client: supabase);
  final GroupService _groupService = GroupService();

  String? _selectedRole;
  String? _selectedGroupId;
  List<Group> _availableGroups = [];

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      final groups = await _groupService.getAllGroups();
      if (mounted) {
        setState(() {
          _availableGroups = groups;
          // تعيين أول مجموعة كقيمة افتراضية للطالب عند التحميل
          if (_availableGroups.isNotEmpty) {
            if (_selectedRole == 'student' || _selectedRole == null) {
              _selectedGroupId = _availableGroups.first.id;
            }
          }
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ RLS: فشل جلب المجموعات. تحقق من سياسة RLS لجدول groups. ${e.message}',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل جلب المجموعات: ${e.toString()}',
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      return;
    }

    if (_selectedRole == 'student' &&
        (_selectedGroupId == null || _availableGroups.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار مجموعة للطالب.',
            textAlign: TextAlign.right,
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. تسجيل المستخدم في نظام المصادقة (يتم إنشاء ملف تعريف بقيم افتراضية)
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole!,
      );

      // 2. تحديث جدول profiles بالاسم الكامل ومعرف المجموعة
      final currentUser = _authService.client.auth.currentUser;
      if (currentUser != null) {
        await _authService.client
            .from('profiles')
            .update({
              'full_name': _fullNameController.text.trim(),
              'group_id': _selectedRole == 'student' ? _selectedGroupId : null,
            })
            .eq('id', currentUser.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل حسابك بنجاح. يمكنك الآن تسجيل الدخول.',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) {
        String errorMsg = e.message ?? 'حدث خطأ أثناء التسجيل.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, textAlign: TextAlign.right),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        String errorMsg = e.message ?? 'حدث خطأ أثناء تحديث بياناتك.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تحديث البيانات: $errorMsg. تحقق من سياسة RLS لجدول profiles (UPDATE).',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل التسجيل: $errorMsg.',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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
                  children: [
                    Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 30),

                    // حقل الاسم الكامل
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسمك الكامل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // حقول البريد الإلكتروني وكلمة المرور
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

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
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // اختيار الدور
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'نوع الحساب',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      initialValue: _selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('طالب')),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('مدرس / مسؤول'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          if (value == 'student' &&
                              _availableGroups.isNotEmpty) {
                            _selectedGroupId = _availableGroups.first.id;
                          } else {
                            _selectedGroupId = null;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار نوع الحساب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // اختيار المجموعة (للطالب فقط)
                    if (_selectedRole == 'student')
                      _availableGroups.isEmpty && !_isLoading
                          ? const Center(
                              child: Text('لا توجد مجموعات متاحة حالياً.'),
                            )
                          : DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'اختيار المجموعة',
                                prefixIcon: Icon(Icons.group),
                              ),
                              initialValue: _selectedGroupId,
                              items: _availableGroups.map((group) {
                                return DropdownMenuItem(
                                  value: group.id,
                                  child: Text(group.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGroupId = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedRole == 'student' &&
                                    value == null) {
                                  return 'الرجاء اختيار المجموعة';
                                }
                                return null;
                              },
                            ),

                    if (_selectedRole == 'student') const SizedBox(height: 20),

                    // زر تسجيل الحساب
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('تسجيل الحساب'),
                    ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        'هل لديك حساب بالفعل؟ تسجيل الدخول',
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
