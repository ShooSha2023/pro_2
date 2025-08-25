import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final List<String> locations;
  final void Function(String) onLocationChanged;
  final String? defaultValue;
  final String? label;
  final String? hint;

  const LocationDropdown({
    required this.locations,
    required this.onLocationChanged,
    this.defaultValue,
    this.label,
    this.hint,
    Key? key,
  }) : super(key: key);

  @override
  LocationDropdownState createState() => LocationDropdownState();
}

class LocationDropdownState extends State<LocationDropdown> {
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.scaffoldBackgroundColor;

    return DropdownButtonFormField<String>(
      value: selectedLocation,
      items: widget.locations
          .map(
            (location) => DropdownMenuItem(
              value: location,
              child: Text(location, style: TextStyle(color: primaryColor)),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: widget.label ?? 'المجال الإعلامي',
        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        hintText: widget.hint ?? 'اختر المجال',
        prefixIcon: Icon(Icons.location_on, color: primaryColor),
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
          selectedLocation = newValue;
        });
        if (newValue != null) widget.onLocationChanged(newValue);
      },
    );
  }
}
