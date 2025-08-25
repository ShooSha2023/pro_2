import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/delayed_animation.dart';
import 'package:pro_2/login_page.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
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

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() => setState(() {}));

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

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) async {
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

  Widget get _animatedButtonUI {
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      height: 60,
      width: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          AppLocalizations.getText('splash_cta', lang),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8185E2),
          ),
        ),
      ),
    );
  }

  Widget _languageButtonContent(String lang) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: null, // السيطرة من PopupMenuButton
      icon: const Icon(Icons.arrow_drop_down),
      label: Text(
        lang == 'ar'
            ? AppLocalizations.getText('arabic', 'ar')
            : AppLocalizations.getText('english', 'en'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    // PopupMenuButton مع child مخصص (زر صغير + سهم لتحت)
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (code) => localeProvider.setLocale(Locale(code)),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'ar', child: Text('العربية')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
      color: Colors.white.withOpacity(0.8), // قائمة شفافة
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      // زر بسيط جدا: نص + سهم صغير
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lang == 'ar' ? 'العربية' : 'English',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.white;
    _scale = 1 - _pressController.value;
    final String lang = Localizations.localeOf(context).languageCode;

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
                  AppLocalizations.getText('splash_hi_there', lang),
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
                  AppLocalizations.getText('splash_im_scoopamine', lang),
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
                  AppLocalizations.getText('splash_your_new_personal', lang),
                  style: TextStyle(fontSize: 20.0, color: color),
                ),
              ),
              DelayedAnimation(
                delay: delayedAmount + 3000,
                child: Text(
                  AppLocalizations.getText(
                    'splash_smart_media_assistant',
                    lang,
                  ),
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

              // زر صغير تحت فيه سهم لتحت لتغيير اللغة
              const SizedBox(height: 20),
              DelayedAnimation(
                delay: delayedAmount + 4200,
                child: _buildLanguageSwitcher(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
