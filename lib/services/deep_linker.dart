// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pro_2/ResetPassword.dart';

// class DeepLinkHandler extends StatefulWidget {
//   final Widget child;
//   const DeepLinkHandler({required this.child});

//   @override
//   State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
// }

// class _DeepLinkHandlerState extends State<DeepLinkHandler>
//     with WidgetsBindingObserver {
//   static const platform = MethodChannel('myapp/deeplink');

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _checkInitialLink();
//     platform.setMethodCallHandler(_handleLinkFromNative);
//   }

//   Future<void> _checkInitialLink() async {
//     if (Platform.isAndroid) {
//       final link = await platform.invokeMethod<String>('getInitialLink');
//       if (link != null) _handleLink(link);
//     }
//     // iOS يمكن إضافة مشابه
//   }

//   Future<void> _handleLinkFromNative(MethodCall call) async {
//     if (call.method == 'onLink') {
//       _handleLink(call.arguments as String);
//     }
//   }

//   void _handleLink(String link) {
//     final uri = Uri.parse(link);
//     if (uri.host == 'reset-password') {
//       final uid = uri.queryParameters['uid'];
//       final token = uri.queryParameters['token'];
//       if (uid != null && token != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ResetPasswordPage(uid: uid, token: token),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) => widget.child;
// }
