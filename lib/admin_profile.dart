import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'user_profile.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey400 = Color(0xFFB0B0B0);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _redBadge = Color(0xFFE53935); // Warna lencana merah notifikasi

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    UserProfile.isAdmin = false;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Admin Profile",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(color: _grey200, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Color(0xFFB0B0B0),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserProfile.name.isEmpty ? 'Super Admin' : UserProfile.name,
                            style: const TextStyle(
                              color: _black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            UserProfile.email.isEmpty ? 'admin@cosvoria.com' : UserProfile.email,
                            style: const TextStyle(
                              color: _grey500,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: _grey200, height: 1, thickness: 1),
              
              // ── Deretan Menu yang Sudah Ditambahkan Fitur Lencana Notifikasi ──
              _MenuTile(icon: Icons.storefront_outlined, title: "Store Settings", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1, indent: 20, endIndent: 20),
              
              _MenuTile(icon: Icons.people_outline, title: "Manage Users", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1, indent: 20, endIndent: 20),
              
              _MenuTile(icon: Icons.account_balance_outlined, title: "Payout & Financials", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1, indent: 20, endIndent: 20),

              // MENU BARU 1: Identity Verification dengan angka penanda 4 merah
              _MenuTile(icon: Icons.gpp_good_outlined, title: "Identity Verification", badgeCount: "4", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1, indent: 20, endIndent: 20),

              // MENU BARU 2: Voucher & Point
              _MenuTile(icon: Icons.confirmation_number_outlined, title: "Voucher & Point", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1, indent: 20, endIndent: 20),

              // MENU BARU 3: Notification Settings
              _MenuTile(icon: Icons.notifications_none_outlined, title: "Notification Settings", onTap: () {}),
              const Divider(color: _grey200, height: 1, thickness: 1),

              const SizedBox(height: 32),
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
              Center(
                child: Text(
                  "Cosvoria Admin v1.0.0",
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

// ── Widget Kustom Menu Tile yang Sudah Ditambahkan Fitur Lencana Bulat ──
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badgeCount; // Ditambahkan parameter opsional untuk penanda angka
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.badgeCount, // Default-nya null kalau tidak diisi
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
            // Jika badgeCount diisi, maka kotak merah notifikasi akan muncul di sini
            if (badgeCount != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.12), // Merah transparan lembut
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount!,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
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