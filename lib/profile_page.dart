import 'package:flutter/material.dart';
import 'profile_subpages.dart';
import 'user_profile.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';
import 'services/auth_service.dart';

// =============================================
// PROFILE PAGE — Kick Avenue Clean Minimalist
// White canvas, outline icons, grey dividers
// =============================================

class ProfilePage extends StatefulWidget {
  /// Jumlah rental aktif. Jika > 0, badge hijau "X Active" muncul.
  final int activeRentals;

  const ProfilePage({Key? key, this.activeRentals = 1}) : super(key: key);

  // ── Design Tokens (Kick Avenue Monochromatic) ──
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
  // ── Mutable user biodata ──
  String _userName = "tes_nama";
  String _userEmail = "tes@gmail.com";
  String _userPhone = "";
  String _userAddress = "";

  @override
  void initState() {
    super.initState();
    // Load persisted in-memory profile if available
    if (UserProfile.name.isNotEmpty) {
      _userName = UserProfile.name;
    }
    if (UserProfile.email.isNotEmpty) {
      _userEmail = UserProfile.email;
    }
    if (UserProfile.phone.isNotEmpty) {
      _userPhone = UserProfile.phone;
    }
    if (UserProfile.address.isNotEmpty) {
      _userAddress = UserProfile.address;
    }
  }

  // Refresh local fields from UserProfile
  void _refreshFromProfile() {
    setState(() {
      _userName = UserProfile.name.isNotEmpty ? UserProfile.name : _userName;
      _userEmail = UserProfile.email.isNotEmpty ? UserProfile.email : _userEmail;
      _userPhone = UserProfile.phone.isNotEmpty ? UserProfile.phone : _userPhone;
      _userAddress = UserProfile.address.isNotEmpty ? UserProfile.address : _userAddress;
    });
  }

  // Shorthand accessors for design tokens
  Color get _bg => ProfilePage.bg;
  Color get _black => ProfilePage.black;
  Color get _grey500 => ProfilePage.grey500;
  Color get _grey400 => ProfilePage.grey400;
  Color get _grey200 => ProfilePage.grey200;
  Color get _grey100 => ProfilePage.grey100;
  Color get _verifiedGreen => ProfilePage.verifiedGreen;

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
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _userEmail = result['email'] ?? _userEmail;
        _userPhone = result['phone'] ?? _userPhone;
        _userAddress = result['address'] ?? _userAddress;
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
              // ═══════════════════════════════════════
              //  HEADER: Title + User Info
              // ═══════════════════════════════════════
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

              // ── User Info Row (Tappable → EditProfilePage) ──
              GestureDetector(
                onTap: _userEmail.isEmpty ? () async {
                  // Open login when not logged in
                  final res = await Navigator.push<bool?>(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  if (res == true) {
                    _refreshFromProfile();
                  }
                } : _openEditProfile,
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
                                _userEmail.isEmpty ? 'Tap to login or register' : _userEmail,
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

              // ═══════════════════════════════════════
              //  WALLET CARDS: Deposit + Cosmo Points
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    // ── Deposit Balance ──
                    Expanded(
                      child: _WalletCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Deposit Balance",
                        value: "Rp 150.000",
                      ),
                    ),
                    SizedBox(width: 12),
                    // ── Cosmo Points ──
                    Expanded(
                      child: _WalletCard(
                        icon: Icons.star_outline_rounded,
                        label: "Cosmo Points",
                        value: "450 KP",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════
              //  MAIN MENU LIST
              // ═══════════════════════════════════════
              Divider(color: _grey200, height: 1, thickness: 1),

              // 1. My Rentals
              _MenuTile(
                icon: Icons.shopping_bag_outlined,
                title: "My Rentals",
                trailing: widget.activeRentals > 0
                    ? _ActiveBadge(count: widget.activeRentals)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyRentalsPage()),
                ),
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
                  "Verified",
                  style: TextStyle(
                    color: _verifiedGreen,
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
              if (UserProfile.isAdmin) ...[
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

              const SizedBox(height: 32),

              // ═══════════════════════════════════════
              //  HELP CENTER
              // ═══════════════════════════════════════
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

              // ── Contact Row ──
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

              // ── Rental Terms Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {},
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

              const SizedBox(height: 16),

              // ── App Version ──
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

// ═══════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════

/// Wallet info card — deposit balance or cosmo points
class _WalletCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WalletCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
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
    );
  }
}

/// Menu item tile — Kick Avenue style ListTile replacement
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
