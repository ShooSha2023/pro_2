import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  required BuildContext context,
  TextEditingController? controller,
  required String label,
  required String hintText,
  required IconData icon,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? initialValue,
  void Function(String)? onChanged,
  bool? enabled,
  bool? readOnly,
}) {
  controller ??= TextEditingController(text: initialValue);

  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;

  return TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: primaryColor),
      hintText: hintText,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor, // نفس لون خلفية كلمة السر
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    onChanged: onChanged,
  );
}
