import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final List<String> locations;
  final void Function(String) onLocationChanged;
  final String? defaultValue;

  const LocationDropdown({
    required this.locations,
    required this.onLocationChanged,
    this.defaultValue,
    Key? key,
  }) : super(key: key);

  @override
  LocationDropdownState createState() => LocationDropdownState();
}

class LocationDropdownState extends State<LocationDropdown> {
  String? selectedLocation;

  static const primaryColor = Color(0xFF8185E2);

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedLocation,
      items: widget.locations
          .map((location) => DropdownMenuItem(
                value: location,
                child: Text(
                  location,
                  style: const TextStyle(color: primaryColor),
                ),
              ))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Select Location',
        labelStyle: const TextStyle(color: primaryColor),
        hintText: 'Choose your location',
        prefixIcon: const Icon(Icons.location_on, color: primaryColor),
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
      onChanged: (newValue) {
        setState(() {
          selectedLocation = newValue;
        });
        widget.onLocationChanged(newValue!);
      },
    );
  }
}
