import 'package:flutter/material.dart';
import 'package:project_mopro/features/admin/pages/admin_dashboard.dart';
import 'package:project_mopro/features/admin/pages/admin_orders.dart';
import 'package:project_mopro/features/admin/pages/admin_catalog.dart';
import 'package:project_mopro/features/admin/pages/admin_profile.dart';

// =============================================
// Admin Navigation Wrapper
// Centralized Bottom Navigation Bar for Admin
// 4 Tabs: Dashboard, Orders, Catalog, Profile
// =============================================
class AdminNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const AdminNavigationWrapper({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  State<AdminNavigationWrapper> createState() => _AdminNavigationWrapperState();
}

class _AdminNavigationWrapperState extends State<AdminNavigationWrapper> {
  late int _selectedIndex;

  List<Widget> get _pages => [
    AdminDashboard(
      onSeeAllPressed: () {
        _onTabTapped(2); // Index 2: Catalog
      },
      onProfilePressed: () {
        _onTabTapped(3); // Index 3: Profile
      },
    ), 
    const AdminOrdersPage(),   // Index 1: Orders
    const AdminCatalogPage(),  // Index 2: Catalog
    const AdminProfilePage(),  // Index 3: Profile
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
      key: const Key('admin_navigation_scaffold'),
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
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
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
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.dashboard_rounded),
              ),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.receipt_long_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.receipt_long_rounded),
              ),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.checkroom_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.checkroom_rounded),
              ),
              label: "Catalog",
            ),
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