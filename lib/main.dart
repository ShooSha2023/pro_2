import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pro_2/delayed_animation.dart';
import 'package:pro_2/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final int delayedAmount = 500;
  late double _scale;
  late AnimationController _pressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pressController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
          lowerBound: 0.0,
          upperBound: 0.1,
        )..addListener(() {
          setState(() {});
        });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    _pressController.reverse();
    await _fadeController.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const LoginPage(),
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
    height: 60,
    width: 270,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100.0),
      color: Colors.white,
    ),
    child: const Center(
      child: Text(
        'Hi ScooPamine',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8185E2),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.white;
    _scale = 1 - _pressController.value;

    return Scaffold(
      backgroundColor: const Color(0xFF8185E2),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                endRadius: 120,
                duration: const Duration(milliseconds: 1000),
                glowColor: Colors.white24,
                repeat: true,
                repeatPauseDuration: const Duration(seconds: 1),
                startDelay: const Duration(seconds: 1),
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        width: 145,
                        height: 145,
                      ),
                    ),
                    radius: 70.0,
                  ),
                ),
              ),
              DelayedAnimation(
                delay: delayedAmount + 1000,
                child: Text(
                  "Hi There",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35.0,
                    color: color,
                  ),
                ),
              ),
              DelayedAnimation(
                delay: delayedAmount + 2000,
                child: Text(
                  "I'm ScooPamine",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35.0,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              DelayedAnimation(
                delay: delayedAmount + 3000,
                child: Text(
                  "Your New Personal",
                  style: TextStyle(fontSize: 20.0, color: color),
                ),
              ),
              DelayedAnimation(
                delay: delayedAmount + 3000,
                child: Text(
                  "smart media assistant",
                  style: TextStyle(fontSize: 20.0, color: color),
                ),
              ),
              const SizedBox(height: 50.0),
              DelayedAnimation(
                delay: delayedAmount + 4000,
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  child: Transform.scale(
                    scale: _scale,
                    child: _animatedButtonUI,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
