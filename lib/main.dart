import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosvoria — Premium Cosplay Rental',
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

  // ── Pages displayed for each tab ──
  static const List<Widget> _pages = <Widget>[
    MainHomePage(), // Index 0: Home
    SearchPage(), // Index 1: Search
    ProfilePage(), // Index 2: Profile
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
            // ── Home: outline → filled on active ──
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
            // ── Search: outline → filled on active ──
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
            // ── Profile: outline → filled on active ──
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

// =============================================
// Placeholder: Search Page
// English dummy for Advanced Search & Filters
// =============================================
class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          "Search",
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Advanced Search",
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Search costumes by name, series,\ncategory, or size — coming soon.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
// Placeholder: Profile Page
// English dummy for Account Management
// (Rental History / My Rentals will be moved here later)
// =============================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile avatar ring
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Icon(Icons.person_rounded,
                    size: 40, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Cosplayer",
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "cosplayer@cosvoria.app",
              style: TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            // Placeholder features notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Text(
                "Account management & rental history\nwill be available here soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
