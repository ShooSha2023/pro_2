import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed; // 👈 nullable الآن

  const ActionButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
    this.onPressed,
    int? height,
    int? fontSize, // 👈 nullable
  }) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _scale = 0.95),
      onTapUp: isDisabled ? null : (_) => setState(() => _scale = 1.0),
      onTapCancel: isDisabled ? null : () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(widget.icon),
          label: Text(widget.label),
          onPressed: widget.onPressed, // الآن يقبل null
        ),
      ),
    );
  }
}
