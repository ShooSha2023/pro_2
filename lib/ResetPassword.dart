// import 'package:flutter/material.dart';
// import 'package:pro_2/services/api.dart';
// import 'package:pro_2/localization/app_localizations.dart';
// import 'package:pro_2/login_page.dart'; // تأكد من استيراد صفحة تسجيل الدخول الصحيحة

// class ResetPasswordPage extends StatefulWidget {
//   final String uid;
//   final String token;

//   const ResetPasswordPage({Key? key, required this.uid, required this.token})
//     : super(key: key);

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   void _submit(String lang) async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final data = {
//       "uid": widget.uid,
//       "token": widget.token,
//       "password": _passwordController.text,
//       "password2": _confirmPasswordController.text,
//     };

//     final result = await ApiService.resetPassword(data);

//     setState(() => _isLoading = false);

//     if (result['success']) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             lang == 'ar'
//                 ? 'تم تغيير كلمة المرور بنجاح'
//                 : 'Password changed successfully',
//           ),
//         ),
//       );

//       // الرجوع مباشرة لصفحة تسجيل الدخول بعد النجاح
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//         (route) => false,
//       );
//     } else {
//       String message = 'حدث خطأ';
//       if (result['error'] != null && result['error']['errors'] != null) {
//         final errors = result['error']['errors'];
//         if (errors['password'] != null)
//           message = errors['password'][0];
//         else if (errors['token'] != null)
//           message = errors['token'][0];
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final lang = Localizations.localeOf(context).languageCode;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(lang == 'ar' ? 'إعادة تعيين كلمة السر' : 'Reset Password'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: lang == 'ar'
//                         ? 'كلمة المرور الجديدة'
//                         : 'New Password',
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//                       onPressed: () =>
//                           setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                   ),
//                   validator: (value) => value!.isEmpty
//                       ? (lang == 'ar'
//                             ? 'الرجاء إدخال كلمة المرور'
//                             : 'Enter password')
//                       : null,
//                 ),
//                 const SizedBox(height: 15),
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: lang == 'ar'
//                         ? 'تأكيد كلمة المرور'
//                         : 'Confirm Password',
//                     border: const OutlineInputBorder(),
//                   ),
//                   validator: (value) => value != _passwordController.text
//                       ? (lang == 'ar'
//                             ? 'كلمتا المرور غير متطابقتين'
//                             : 'Passwords do not match')
//                       : null,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : () => _submit(lang),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(lang == 'ar' ? 'تأكيد' : 'Confirm'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
