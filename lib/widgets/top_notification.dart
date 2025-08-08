import 'package:flutter/material.dart';

enum NotificationType { success, error, warning }

class TopNotification {
  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.success,
  }) {
    final overlay = Overlay.of(context);
    final Color primaryColor = const Color(0xFF8185E2);

    IconData icon;
    Color backgroundColor;

    switch (type) {
      case NotificationType.success:
        icon = Icons.check_circle_outline;
        backgroundColor = primaryColor;
        break;
      case NotificationType.error:
        icon = Icons.error_outline;
        backgroundColor = Colors.redAccent;
        break;
      case NotificationType.warning:
        icon = Icons.warning_amber_outlined;
        backgroundColor = Colors.orange;
        break;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SlideDownNotification(
        icon: icon,
        message: message,
        backgroundColor: backgroundColor.withOpacity(0.92), // ✨ شفافية
        onClose: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // الإغلاق التلقائي بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _SlideDownNotification extends StatefulWidget {
  final IconData icon;
  final String message;
  final Color backgroundColor;
  final VoidCallback onClose;

  const _SlideDownNotification({
    Key? key,
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_SlideDownNotification> createState() => _SlideDownNotificationState();
}

class _SlideDownNotificationState extends State<_SlideDownNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
