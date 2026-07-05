import 'package:flutter/material.dart';
import 'package:project_mopro/features/customer/pages/profile_subpages.dart';
import 'package:project_mopro/features/admin/pages/admin_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/features/auth/pages/login_page.dart';
import 'package:project_mopro/features/customer/pages/wallet_pages.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';

// =============================================
// PROFILE PAGE â€” Kick Avenue Clean Minimalist
// White canvas, outline icons, grey dividers
// =============================================

class ProfilePage extends StatefulWidget {
  /// Jumlah rental aktif. Jika > 0, badge hijau "X Active" muncul.
  final int activeRentals;

  const ProfilePage({Key? key, this.activeRentals = 1}) : super(key: key);

  // â”€â”€ Design Tokens (Kick Avenue Monochromatic) â”€â”€
  static const Color bg = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey800 = Color(0xFF333333);
  static const Color grey500 = Color(0xFF888888);
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey200 = Color(0xFFE8E8E8);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color activeGreen = Color(0xFF22C55E);
  static const Color activeGreenBg = Color(0xFFDCFCE7);
  static const Color verifiedGreen = Color(0xFF16A34A);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _userName = 'Guest';
          _userEmail = '';
        });
        return;
      }

      // Pre-populate from firebase auth user as fallback
      setState(() {
        _userName = user.displayName ?? 'User';
        _userEmail = user.email ?? '';
      });

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          _userName = data['name'] ?? user.displayName ?? 'User';
          _userEmail = data['email'] ?? user.email ?? '';
          _userPhone = data['phone'] ?? '';
          _userAddress = data['address'] ?? '';
          _userCity = data['city'] ?? '';
          _userProvince = data['province'] ?? '';
          _userPostal = data['postal'] ?? '';
          _isAdmin = data['isAdmin'] ?? false;
          _depositBalance = (data['deposit_balance'] ?? 0).toInt();
          final statusVal = (data['verificationStatus'] ?? 'unverified').toString();
          final ktpVal = data['ktpNumber']?.toString() ?? '';
          if (ktpVal.trim().isEmpty) {
            _verificationStatus = 'unverified';
          } else {
            _verificationStatus = statusVal;
          }
        });
      } else {
        // If user logged in, but Firestore document doesn't exist, create it!
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'phone': '',
          'address': '',
          'role': 'Customer',
          'isAdmin': false,
          'verificationStatus': 'unverified',
          'deposit_balance': 0,
        });
      }
    } catch (e) {
      debugPrint('Error load profile: $e');
    }
  }

  // — Mutable user biodata —
  String _userName = "";
  String _userEmail = "";
  String _userPhone = "";
  String _userAddress = "";
  String _userCity = "";
  String _userProvince = "";
  String _userPostal = "";
  bool _isAdmin = false;
  int _depositBalance = 0;
  String _verificationStatus = 'unverified';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Shorthand accessors for design tokens
  Color get _bg => ProfilePage.bg;
  Color get _black => ProfilePage.black;
  Color get _grey500 => ProfilePage.grey500;
  Color get _grey400 => ProfilePage.grey400;
  Color get _grey200 => ProfilePage.grey200;
  Color get _grey100 => ProfilePage.grey100;
  Color get _verifiedGreen => ProfilePage.verifiedGreen;

  String get _verificationLabel {
    switch (_verificationStatus) {
      case 'approved':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return 'Unverified';
    }
  }

  Color get _verificationColor {
    switch (_verificationStatus) {
      case 'approved':
        return _verifiedGreen;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return _grey500;
    }
  }

  /// Navigate to EditProfilePage and update state on return
  Future<void> _openEditProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
        name: _userName,
        email: _userEmail,
        phone: _userPhone,
        address: _userAddress,
        city: _userCity,
        province: _userProvince,
        postal: _userPostal,
),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _userEmail = result['email'] ?? _userEmail;
        _userPhone = result['phone'] ?? _userPhone;
        _userAddress = result['address'] ?? _userAddress;
        _userCity = result['city'] ?? _userCity;
        _userProvince = result['province'] ?? _userProvince;
        _userPostal = result['postal'] ?? _userPostal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  HEADER: Title + User Info
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Profile",
                  style: TextStyle(
                    color: _black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // â”€â”€ User Info Row (Tappable â†’ EditProfilePage) â”€â”€
              GestureDetector(
                onTap: FirebaseAuth.instance.currentUser == null
                    ? () async {
                        // Open login when not logged in
                        final res = await Navigator.push<bool?>(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                        if (res == true) {
                          _loadUserData();
                        }
                      }
                    : _openEditProfile,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _grey100,
                          border: Border.all(color: _grey200, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_outlined,
                          color: Color(0xFFB0B0B0),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Name & Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: _black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _userEmail.isEmpty
                                  ? 'Tap to login or register'
                                  : _userEmail,
                              style: TextStyle(
                                color: _grey500,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chevron
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _grey400,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  WALLET CARDS: Deposit + Cosmo Points
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // â”€â”€ Deposit Balance â”€â”€
                    Expanded(
                      child: _WalletCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Deposit Balance",
                        value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_depositBalance),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositBalancePage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  MAIN MENU LIST
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              Divider(color: _grey200, height: 1, thickness: 1),

              // 1. My Rentals
              ValueListenableBuilder<List<Rental>>(
                valueListenable: RentalManager.instance.rentalsNotifier,
                builder: (context, rentals, child) {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  final activeCount = RentalManager.instance.activeRentals
                      .where((r) => r.userId == currentUserId)
                      .length;
                  return _MenuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "My Rentals",
                    trailing: activeCount > 0
                        ? _ActiveBadge(count: activeCount)
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRentalsPage()),
                    ),
                  );
                },
              ),
              Divider(
                  color: _grey200,
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20),

              // 2. Identity Verification
              _MenuTile(
                icon: Icons.verified_user_outlined,
                title: "Identity Verification",
                trailing: Text(
                  _verificationLabel,
                  style: TextStyle(
                    color: _verificationColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const IdentityVerificationPage()),
                ),
              ),
              Divider(
                  color: _grey200,
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20),

              // 3. My Size Profile
              _MenuTile(
                icon: Icons.straighten_outlined,
                title: "My Size Profile",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SizeProfilePage()),
                ),
              ),
              Divider(
                  color: _grey200,
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20),

              // 4. My Vouchers
              _MenuTile(
                icon: Icons.confirmation_num_outlined,
                title: "My Vouchers",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyVouchersPage()),
                ),
              ),
              Divider(
                  color: _grey200,
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20),

              // 5. Wishlist
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                title: "Wishlist",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()),
                ),
              ),
              Divider(
                  color: _grey200,
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20),

              // 6. Settings
              _MenuTile(
                icon: Icons.settings_outlined,
                title: "Settings",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),

              // Admin Dashboard (hanya terlihat jika UserProfile.isAdmin)

              if (_isAdmin) ...[
                Divider(
                    color: _grey200,
                    height: 1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20),
                _MenuTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: "Admin Dashboard",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  ),
                ),
              ],

              Divider(color: _grey200, height: 1, thickness: 1),



              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  HELP CENTER
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Help Center",
                  style: TextStyle(
                    color: _black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // â”€â”€ Contact Row â”€â”€
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    _ContactChip(
                      icon: Icons.email_outlined,
                      label: "cs@cosvoria.com",
                    ),
                    SizedBox(width: 10),
                    _ContactChip(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "WhatsApp",
                    ),
                    SizedBox(width: 10),
                    _ContactChip(
                      icon: Icons.camera_alt_outlined,
                      label: "Instagram",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // â”€â”€ Rental Terms Button â”€â”€
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RentalTermsPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _black,
                      side: BorderSide(color: _black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Rental Terms & Rules",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // â”€â”€ Logout Button â”€â”€
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // â”€â”€ App Version â”€â”€
              Center(
                child: Text(
                  "Cosvoria v1.0.0",
                  style: TextStyle(
                    color: _grey400,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  REUSABLE WIDGETS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// Wallet info card â€” deposit balance or cosmo points
class _WalletCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _WalletCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF111111), size: 20),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu item tile â€” Kick Avenue style ListTile replacement
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF111111), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B0B0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Green "X Active" badge for My Rentals
class _ActiveBadge extends StatelessWidget {
  final int count;
  const _ActiveBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$count Active",
        style: const TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

/// Small contact chip for Help Center
class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF111111), size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
