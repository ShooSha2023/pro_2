import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  TextEditingController? controller,
  required String label,
  required String hintText,
  required IconData icon,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? initialValue,
  Function(dynamic value)? onChanged,
  bool? enabled,
}) {
  // تعيين كنترولر افتراضي إذا لم يُمرر
  controller ??= TextEditingController(text: initialValue);

  const primaryColor = Color(0xFF8185E2);

  return TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: const TextStyle(color: primaryColor),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: primaryColor),
      hintText: hintText,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
    onChanged: onChanged,
  );
}
