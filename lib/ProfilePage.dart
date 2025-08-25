import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pro_2/widgets/buildTextfield.dart';
import 'package:pro_2/widgets/locationDropdown.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:pro_2/widgets/ActionButton.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/locale_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String? _firstName = '';
  String? _lastName = '';
  String? _email = '';
  String? _password = '';
  String? _mediaRole = 'مراسل';
  final bool _isLoading = false;

  bool _isPasswordVisible = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.getText('profile', lang),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                                : const AssetImage('assets/logo.png')
                                      as ImageProvider,
                            backgroundColor: Colors.white,
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
                      label: AppLocalizations.getText(
                        'profile_first_name',
                        lang,
                      ),
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

                    // الاسم الثاني
                    buildTextField(
                      label: AppLocalizations.getText(
                        'profile_last_name',
                        lang,
                      ),
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

                    // البريد الإلكتروني
                    buildTextField(
                      label: AppLocalizations.getText('profile_email', lang),
                      hintText: AppLocalizations.getText('profile_email', lang),
                      icon: Icons.email,
                      initialValue: _email ?? '',
                      onChanged: (value) => _email = value,
                      context: context,
                    ),
                    const SizedBox(height: 30),

                    // كلمة المرور
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
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
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
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Dropdown خاص بالمجال الإعلامي
                    LocationDropdown(
                      locations: [
                        AppLocalizations.getText('profile_role_reporter', lang),
                        AppLocalizations.getText('profile_role_editor', lang),
                        AppLocalizations.getText(
                          'profile_role_presenter',
                          lang,
                        ),
                        AppLocalizations.getText(
                          'profile_role_commentator',
                          lang,
                        ),
                      ],
                      defaultValue: AppLocalizations.getText(
                        'profile_role_reporter',
                        lang,
                      ),
                      onLocationChanged: (selectedRole) {
                        setState(() {
                          _mediaRole = selectedRole;
                        });
                      },
                    ),
                    const SizedBox(height: 40),

                    // زر الحفظ باستخدام ActionButton
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ActionButton(
                        color: primaryColor,
                        icon: Icons.save,
                        label: AppLocalizations.getText('save', lang),
                        onPressed: () {
                          TopNotification.show(
                            context,
                            AppLocalizations.getText(
                              'profile_save_success',
                              lang,
                            ),
                            type: NotificationType.success,
                          );
                        },
                        height: 55,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
