import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/services/token_manager.dart';
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
  String? _profileImageUrl; // رابط الصورة من السيرفر
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _mediaRole;
  bool _isLoading = false;
  String? _token;

  final specialties = [
    {"en": "politics", "ar": "سياسة"},
    {"en": "economy", "ar": "اقتصاد"},
    {"en": "sports", "ar": "رياضة"},
    {"en": "culture", "ar": "ثقافة"},
    {"en": "technology", "ar": "تكنولوجيا"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTokenAndProfile();
    });
  }

  Future<void> _loadTokenAndProfile() async {
    setState(() {
      _isLoading = true;
    });

    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      TopNotification.show(
        context,
        "User not logged in",
        type: NotificationType.error,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _token = token;

    final result = await ApiService.getProfile();

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final data = result['data'];

      setState(() {
        _firstName = data['first_name'];
        _lastName = data['last_name'];
        _email = data['email'];
        _mediaRole = data['specialty'];
        _profileImageUrl = data['profile_picture'];
      });
    } else {
      TopNotification.show(
        context,
        "Failed to load profile: ${result['error']}",
        type: NotificationType.error,
      );
    }
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
    if (_token == null || _token!.isEmpty) {
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
      firstName: _firstName,
      lastName: _lastName,
      specialization: _mediaRole,
      image: _profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final lang = localeProvider.locale.languageCode;

    if (result["success"]) {
      TopNotification.show(
        context,
        AppLocalizations.getText('profile_save_success', lang),
        type: NotificationType.success,
      );
      await _loadTokenAndProfile();
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

    return Directionality(
      textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
                                : (_profileImageUrl != null
                                      ? NetworkImage(
                                          "http://192.168.1.102:8000${_profileImageUrl!}",
                                        )
                                      : const AssetImage('assets/logo.png')
                                            as ImageProvider),
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
                    SpecialtyDropdown(
                      specialties: specialties,
                      lang: lang,
                      defaultValue: _mediaRole,
                      label: AppLocalizations.getText(
                        'profile_media_role',
                        lang,
                      ),
                      color: primaryColor,
                      onSpecialtyChanged: (value) {
                        setState(() {
                          _mediaRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
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
      ),
    );
  }
}
