import 'package:flutter/material.dart';
import 'package:pro_2/MyFilesPage.dart';
import 'package:pro_2/localization/app_theme.dart';
import 'TranscriptionPage.dart';
import 'SummaryPage.dart';
import 'SearchPage.dart';
import 'MyPostsPage.dart';
import 'SettingsPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  // لا const هنا
  final List<Widget> _pages = [
    // SearchPage(),
    MyFilesPage(),
    SummaryPage(),
    TranscriptionPage(),
    MyPostsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Icons.mic, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: primaryColor,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabIcon(Icons.description_rounded, 0),
                _buildTabIcon(Icons.summarize_outlined, 1),
                const SizedBox(width: 50),
                _buildTabIcon(Icons.people, 3),
                _buildTabIcon(Icons.settings, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    final color = Theme.of(context).colorScheme.onSecondary;

    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        size: isSelected ? 28 : 24,
        color: color.withOpacity(isSelected ? 1.0 : 0.5),
      ),
    );
  }
}
