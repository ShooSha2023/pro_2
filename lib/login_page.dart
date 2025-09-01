import 'package:flutter/material.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/services/token_manager.dart';
import 'package:pro_2/home_screen.dart';
import 'package:pro_2/widgets/locationDropdown.dart';

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
  String? _mediaRole; // قيمة الاختصاص بالإنكليزي
  bool _obscurePassword = true;
  bool isSignup = false;
  bool _isLoading = false;

  final String lang = 'en';
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot Password'),
        content: TextFormField(
          controller: _forgotEmailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        isSignup ? 'Create an account' : 'Welcome back',
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
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SpecialtyDropdown(
                          specialties: _specialties,
                          lang: lang,
                          defaultValue: _mediaRole,
                          label: 'Specialty',
                          color: primaryColor,
                          onSpecialtyChanged: (value) {
                            setState(() {
                              _mediaRole = value; // يخزن code بالإنكليزي
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                            labelText: 'Password',
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
                            labelText: 'Confirm Password',
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
                            labelText: 'Email',
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
                            labelText: 'Password',
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
                                isSignup ? 'Sign Up' : 'Login',
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
                              ? 'Already have an account?'
                              : 'Create account',
                        ),
                      ),
                      if (!isSignup)
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
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
