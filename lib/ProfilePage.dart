import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/AuthProvider.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/widgets/buildTextfield.dart';
import 'package:pro_2/widgets/ActionButton.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:pro_2/widgets/locationDropdown.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/providers/locale_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  String? _mediaRole;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final specialties = [
    {"en": "Politics", "ar": "سياسة"},
    {"en": "Economy", "ar": "اقتصاد"},
    {"en": "Sports", "ar": "رياضة"},
    {"en": "Culture", "ar": "ثقافة"},
    {"en": "Technology", "ar": "تكنولوجيا"},
  ];

  @override
  void initState() {
    super.initState();

    // جلب بيانات المستخدم عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        setState(() {
          _firstName = user.firstName;
          _lastName = user.lastName;
          _email = user.email;
          _mediaRole = user.specialty;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || authProvider.accessToken == null) {
      TopNotification.show(
        context,
        "User not logged in",
        type: NotificationType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.updateProfile(
      token: authProvider.accessToken!,
      firstName: _firstName ?? '',
      lastName: _lastName ?? '',
      specialization: _mediaRole ?? '',
      image: _profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      // تحديث نسخة المستخدم في الـ Provider
      final updatedUser = authProvider.user?.copyWith(
        firstName: _firstName,
        lastName: _lastName,
        specialty: _mediaRole,
        avatarUrl: result["data"]["avatar_url"],
      );

      if (updatedUser != null) {
        authProvider.updateUser(updatedUser);
      }

      TopNotification.show(
        context,
        "Profile updated successfully",
        type: NotificationType.success,
      );
    } else {
      TopNotification.show(
        context,
        "Failed to update profile: ${result["error"]}",
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.getText('profile', lang),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // صورة البروفايل
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 88,
                        backgroundColor: primaryColor.withOpacity(0.4),
                        child: CircleAvatar(
                          radius: 85,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (user?.avatarUrl != null
                                        ? NetworkImage(user!.avatarUrl!)
                                        : const AssetImage('assets/logo.png'))
                                    as ImageProvider,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                          size: 30,
                        ),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // الاسم الأول
                  buildTextField(
                    label: AppLocalizations.getText('profile_first_name', lang),
                    hintText: AppLocalizations.getText(
                      'profile_first_name',
                      lang,
                    ),
                    icon: Icons.person_3_rounded,
                    initialValue: _firstName ?? '',
                    onChanged: (value) => _firstName = value,
                    context: context,
                  ),
                  const SizedBox(height: 30),

                  // الاسم الأخير
                  buildTextField(
                    label: AppLocalizations.getText('profile_last_name', lang),
                    hintText: AppLocalizations.getText(
                      'profile_last_name',
                      lang,
                    ),
                    icon: Icons.person_3_rounded,
                    initialValue: _lastName ?? '',
                    onChanged: (value) => _lastName = value,
                    context: context,
                  ),
                  const SizedBox(height: 30),

                  // البريد الإلكتروني (غير قابل للتعديل)
                  buildTextField(
                    label: AppLocalizations.getText('profile_email', lang),
                    hintText: AppLocalizations.getText('profile_email', lang),
                    icon: Icons.email,
                    initialValue: _email ?? '',
                    onChanged: (value) => _email = value,
                    context: context,
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),

                  // كلمة المرور (اختياري تغييرها)
                  TextFormField(
                    initialValue: _password ?? '',
                    obscureText: !_isPasswordVisible,
                    onChanged: (value) => _password = value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getText(
                        'profile_password',
                        lang,
                      ),
                      hintText: AppLocalizations.getText(
                        'profile_password',
                        lang,
                      ),
                      prefixIcon: Icon(Icons.lock, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // التخصص
                  SpecialtyDropdown(
                    specialties: specialties,
                    lang: lang,
                    defaultValue: _mediaRole,
                    label: AppLocalizations.getText('profile_role', lang),
                    color: primaryColor,
                    onSpecialtyChanged: (value) {
                      setState(() {
                        _mediaRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // زر الحفظ
                  ActionButton(
                    color: primaryColor,
                    icon: Icons.save,
                    label: AppLocalizations.getText('save', lang),
                    onPressed: _saveProfile,
                    height: 55,
                    fontSize: 20,
                  ),
                ],
              ),
            ),
    );
  }
}
