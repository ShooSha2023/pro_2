import 'package:flutter/material.dart';

class SpecialtyDropdown extends StatefulWidget {
  final List<Map<String, String>> specialties;
  final void Function(String) onSpecialtyChanged;
  final String? defaultValue;
  final String? label;
  final String? hint;
  final String lang;
  final Color? color;
  final Color? backgroundColor;

  const SpecialtyDropdown({
    required this.specialties,
    required this.onSpecialtyChanged,
    required this.lang,
    this.defaultValue,
    this.label,
    this.hint,
    this.color,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  SpecialtyDropdownState createState() => SpecialtyDropdownState();
}

class SpecialtyDropdownState extends State<SpecialtyDropdown> {
  String? selectedSpecialty;

  @override
  void initState() {
    super.initState();
    // تحقق من أن القيمة موجودة في القائمة، وإلا خلي null
    selectedSpecialty =
        widget.specialties.any((e) {
          final val = widget.lang == 'ar' ? e['ar'] : e['en'];
          return val == widget.defaultValue;
        })
        ? widget.defaultValue
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;
    final cardColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return DropdownButtonFormField<String>(
      value: selectedSpecialty,
      items: widget.specialties.map((specialty) {
        final val = widget.lang == 'ar' ? specialty['ar']! : specialty['en']!;
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val, style: TextStyle(color: primaryColor)),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText:
            widget.label ?? (widget.lang == 'ar' ? 'التخصص' : 'Specialty'),
        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        hintText:
            widget.hint ??
            (widget.lang == 'ar' ? 'اختر التخصص' : 'Choose specialty'),
        prefixIcon: Icon(Icons.work, color: primaryColor),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      onChanged: (newValue) {
        setState(() {
          selectedSpecialty = newValue;
        });
        if (newValue != null) widget.onSpecialtyChanged(newValue);
      },
    );
  }
}
