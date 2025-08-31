import 'package:flutter/material.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/models/journalist.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/widgets/locationDropdown.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/home_screen.dart';
import 'package:pro_2/providers/locale_provider.dart';

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

  bool _obscurePassword = true;
  bool isSignup = false;
  bool _isLoading = false;

  final List<Map<String, String>> _specialties = [
    {"en": "politics", "ar": "سياسة"},
    {"en": "sports", "ar": "رياضة"},
    {"en": "technology", "ar": "تكنولوجيا"},
    {"en": "health", "ar": "صحة"},
    {"en": "other", "ar": "أخرى"},
  ];

  /// ====== SUBMIT LOGIN / SIGNUP ======
  void _submit(String lang) async {
    setState(() => _isLoading = true);

    if (isSignup) {
      final data = {
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "specialty": _selectedSpecialty ?? "",
        "password": _passwordController.text,
        "password2": _confirmPasswordController.text,
      };

      final result = await ApiService.registerAndLogin(data);
      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? 'تم إنشاء الحساب وتسجيل الدخول'
                  : 'Account created & logged in',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(token: result['token'])),
        );
      } else {
        String message = 'حدث خطأ';
        if (result['error'] != null) {
          message = result['error'].toString();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await ApiService.login(email, password);
      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar' ? 'تم تسجيل الدخول' : 'Login successful',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(token: result['data']["token"]),
          ),
        );
      } else {
        String message = 'حدث خطأ';
        if (result['error']?['errors']?['non_field_errors'] != null) {
          message = result['error']['errors']['non_field_errors'][0];
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
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
                  boxShadow: [
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
                                lang,
                              )
                            : AppLocalizations.getText('login_welcome', lang),
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
                            labelText: lang == 'ar'
                                ? 'الاسم الأول'
                                : 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: lang == 'ar'
                                ? 'اسم العائلة'
                                : 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// === Specialty Dropdown ===
                        SpecialtyDropdown(
                          specialties: _specialties,
                          defaultValue: _selectedSpecialty,
                          lang: lang,
                          color: Colors.black45,
                          backgroundColor: Colors.white12,
                          onSpecialtyChanged: (val) {
                            setState(() => _selectedSpecialty = val);
                          },
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: lang == 'ar'
                                ? 'البريد الإلكتروني'
                                : 'Email',
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
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: lang == 'ar'
                                ? 'كلمة المرور'
                                : 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: lang == 'ar'
                                ? 'تأكيد كلمة المرور'
                                : 'Confirm Password',
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
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: lang == 'ar'
                                ? 'البريد الإلكتروني'
                                : 'Email',
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
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: lang == 'ar'
                                ? 'كلمة المرور'
                                : 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _submit(lang),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E27FB),
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
                                    ? (lang == 'ar' ? 'إنشاء حساب' : 'Sign Up')
                                    : (lang == 'ar' ? 'تسجيل الدخول' : 'Login'),
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
                              ? (lang == 'ar'
                                    ? 'لديك حساب بالفعل؟'
                                    : 'Already have an account?')
                              : (lang == 'ar' ? 'إنشاء حساب' : 'Sign Up'),
                          style: const TextStyle(
                            color: Color(0xFF4A47A3),
                            fontWeight: FontWeight.w600,
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
