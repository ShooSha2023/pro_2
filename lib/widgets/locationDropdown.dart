import 'package:flutter/material.dart';

class SpecialtyDropdown extends StatelessWidget {
  final List<Map<String, String>> specialties;
  final String lang; // "en" أو "ar"
  final String? defaultValue; // دايمًا code بالإنكليزي (مثال: "sports")
  final String label;
  final Color color;
  final Function(String) onSpecialtyChanged;

  const SpecialtyDropdown({
    super.key,
    required this.specialties,
    required this.lang,
    required this.defaultValue,
    required this.label,
    required this.color,
    required this.onSpecialtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: defaultValue, // code EN
          items: specialties.map((spec) {
            return DropdownMenuItem<String>(
              value: spec["en"], // ✅ القيمة المخزنة دايمًا EN
              child: Text(
                spec[lang] ?? spec["en"]!, // ✅ العرض حسب اللغة
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onSpecialtyChanged(value); // بيرجع code EN
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: color),
        ),
      ],
    );
  }
}
