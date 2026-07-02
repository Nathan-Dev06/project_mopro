import 'package:flutter/material.dart';
import 'package:project_mopro/firebase_options.dart';
import 'package:project_mopro/features/auth/pages/splash_screen.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
import 'package:project_mopro/features/customer/pages/profile_page.dart';
import 'package:project_mopro/features/customer/pages/search_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosvoria â€” Premium Cosplay Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF111111),
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// =============================================
// Main Navigation Wrapper
// Centralized Bottom Navigation Bar controller
// 3 Tabs: Home (0), Search (1), Profile (2)
// =============================================
class MainNavigationWrapper extends StatefulWidget {
  /// Optional [initialIndex] allows other pages to programmatically
  /// route to a specific tab (e.g., deep-link to Profile).
  final int initialIndex;

  const MainNavigationWrapper({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _selectedIndex;

  // â”€â”€ Pages displayed for each tab â”€â”€
  late final List<Widget> _pages = <Widget>[
    MainHomePage(onProfileTapped: () => _onTabTapped(2)), // Index 0: Home
    const SearchPage(), // Index 1: Search
    const ProfilePage(), // Index 2: Profile
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('main_navigation_scaffold'),
      // IndexedStack preserves page state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          key: const Key('main_bottom_nav'),
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          // Active tab: solid black | Inactive tab: muted grey
          selectedItemColor: const Color(0xFF111111),
          unselectedItemColor: const Color(0xFFB0B0B0),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          onTap: _onTabTapped,
          items: const [
            // â”€â”€ Home: outline â†’ filled on active â”€â”€
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.home_filled),
              ),
              label: "Home",
            ),
            // â”€â”€ Search: outline â†’ filled on active â”€â”€
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.search_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.search_rounded),
              ),
              label: "Search",
            ),
            // â”€â”€ Profile: outline â†’ filled on active â”€â”€
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.person_outline_rounded),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.person_rounded),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

