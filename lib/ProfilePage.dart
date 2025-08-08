import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pro_2/widgets/buildTextfield.dart';
import 'package:pro_2/widgets/locationDropdown.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String? _firstName = 'Shaza';
  String? _lastName = 'Safi';
  final String _phoneNumber = '0999999999';
  String? _government = 'Damascus';
  String? _locationDescription = 'Al_Tadamon';
  final bool _isLoading = false;

  final Color primaryColor = const Color(0xFF8185E2);

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
    int _currentIndex = 1;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                          radius: 78,
                          backgroundColor: primaryColor.withOpacity(0.4),
                          child: CircleAvatar(
                            radius: 75,
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
                    const SizedBox(height: 32),
                    buildTextField(
                      label: 'First Name',
                      hintText: 'Enter your first name',
                      icon: Icons.person_3_rounded,
                      initialValue: _firstName ?? '',
                      onChanged: (value) => _firstName = value,
                    ),
                    const SizedBox(height: 18),
                    buildTextField(
                      label: 'Last Name',
                      hintText: 'Enter your last name',
                      icon: Icons.person_3_rounded,
                      initialValue: _lastName ?? '',
                      onChanged: (value) => _lastName = value,
                    ),
                    const SizedBox(height: 18),
                    buildTextField(
                      label: 'Phone Number',
                      hintText: 'Your phone number',
                      icon: Icons.phone,
                      initialValue: _phoneNumber ?? '',
                      enabled: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: null,
                    ),
                    const SizedBox(height: 18),
                    LocationDropdown(
                      locations: [
                        'Damascus',
                        'Homs',
                        'Hama',
                        'Tartus',
                        'Latakia',
                        'Aleppo',
                        'Al_Sweida',
                        'Daraa',
                        'Idlib',
                        'Qunaitera',
                        'Al_Hasaka',
                        'Al_Raqqa',
                        'Daer_AlZor',
                      ],
                      defaultValue: _government,
                      onLocationChanged: (selectedLocation) {
                        setState(() {
                          _government = selectedLocation;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    buildTextField(
                      label: 'Location Description',
                      hintText: 'Enter a description for your location',
                      icon: Icons.description,
                      initialValue: _locationDescription ?? '',
                      onChanged: (value) => _locationDescription = value,
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ElevatedButton(
                        onPressed: () {
                          showNotification('Profile data saved (Mock)');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void showNotification(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
