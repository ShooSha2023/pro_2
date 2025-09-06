import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/services/token_manager.dart';
import 'package:pro_2/home_screen.dart';
import 'package:pro_2/widgets/locationDropdown.dart';
import 'package:pro_2/providers/locale_provider.dart'; // تأكد من مسار البروفايدر

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedSpecialty;
  String? _mediaRole;
  bool _obscurePassword = true;
  bool isSignup = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF2E27FB);

  final List<Map<String, String>> _specialties = [
    {"en": "politics", "ar": "سياسة"},
    {"en": "sports", "ar": "رياضة"},
    {"en": "technology", "ar": "تكنولوجيا"},
    {"en": "health", "ar": "صحة"},
    {"en": "other", "ar": "أخرى"},
  ];

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    if (isSignup) {
      final registerResult = await ApiService.registerUser(
        first_name: _firstNameController.text,
        last_name: _lastNameController.text,
        email: _emailController.text,
        specialty: _mediaRole ?? '',
        password: _passwordController.text,
        password2: _confirmPasswordController.text,
      );

      if (registerResult['success']) {
        final loginResult = await ApiService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (loginResult['success'] && loginResult['data'] != null) {
          final token = await TokenManager.getToken();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(token: token ?? '')),
          );
        } else {
          print("Login after register failed: ${loginResult['error']}");
        }
      } else {
        print("Register failed: ${registerResult['error']}");
      }
    } else {
      final loginResult = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (loginResult['success'] && loginResult['data'] != null) {
        final token = await TokenManager.getToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(token: token ?? '')),
        );
      } else {
        print("Login failed: ${loginResult['error']}");
      }
    }

    setState(() => _isLoading = false);
  }

  void _showForgotPasswordDialog() {
    final _forgotEmailController = TextEditingController();
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.getText('forgot_password', locale.languageCode),
        ),
        content: TextFormField(
          controller: _forgotEmailController,
          decoration: InputDecoration(
            labelText: AppLocalizations.getText('email', locale.languageCode),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.getText('cancel', locale.languageCode),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _forgotEmailController.text;
              if (email.isNotEmpty) {
                final result = await ApiService.forgotPassword(email: email);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Done')),
                );
              }
            },
            child: Text(AppLocalizations.getText('save', locale.languageCode)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locale = Provider.of<LocaleProvider>(context).locale;

    return Scaffold(
      backgroundColor: const Color(0xFF8185E2),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.02,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF4A47A3),
                radius: size.width * 0.18,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    width: size.width * 0.35,
                    height: size.width * 0.35,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ScooPamine',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: size.width > 600 ? 500 : double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isSignup
                            ? AppLocalizations.getText(
                                'signup_create_account',
                                locale.languageCode,
                              )
                            : AppLocalizations.getText(
                                'login_welcome',
                                locale.languageCode,
                              ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isSignup) ...[
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'profile_first_name',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'profile_last_name',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SpecialtyDropdown(
                          specialties: _specialties,
                          lang: locale.languageCode,
                          defaultValue: _mediaRole,
                          label: AppLocalizations.getText(
                            'profile_media_role',
                            locale.languageCode,
                          ),
                          color: primaryColor,
                          onSpecialtyChanged: (value) {
                            setState(() {
                              _mediaRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'email',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'password',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'confirm_password',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'email',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.getText(
                              'password',
                              locale.languageCode,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isSignup
                                    ? AppLocalizations.getText(
                                        'signup',
                                        locale.languageCode,
                                      )
                                    : AppLocalizations.getText(
                                        'login',
                                        locale.languageCode,
                                      ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() => isSignup = !isSignup),
                        child: Text(
                          isSignup
                              ? AppLocalizations.getText(
                                  'already_have_account',
                                  locale.languageCode,
                                )
                              : AppLocalizations.getText(
                                  'signup_create_account',
                                  locale.languageCode,
                                ),
                        ),
                      ),
                      if (!isSignup)
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            AppLocalizations.getText(
                              'forgot_password',
                              locale.languageCode,
                            ),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
