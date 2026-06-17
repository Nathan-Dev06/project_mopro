import 'package:flutter/material.dart';
import 'admin_store_settings.dart'; 
import 'admin_manage_users_page.dart';
import 'admin_payout_page.dart'; 
import 'admin_identity_verification_page.dart';
import 'admin_voucher_point_page.dart'; 

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // ── JUDUL HALAMAN ──
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

              // ── 1. PROFIL HEADER ADMIN ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.account_box_rounded, color: _grey500, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Admin",
                          style: TextStyle(
                            color: _black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Admin@gmail.com",
                          style: TextStyle(
                            color: _grey500,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Divider(color: _grey200, height: 1),

              // ── 2. DAFTAR MENU OPSI ──
              
              // Menu 1: Store Settings
              _buildMenuRow(
                icon: Icons.store_outlined,
                title: "Store Settings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StoreSettingsPage()),
                  );
                },
              ),

              // Menu 2: Manage Users 
              _buildMenuRow(
                icon: Icons.people_outline,
                title: "Manage Users",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminManageUsersPage()),
                  );
                },
              ),

              // Menu 3: Payout & Financials
              _buildMenuRow(
                icon: Icons.account_balance_outlined,
                title: "Payout & Financials",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPayoutPage()),
                  );
                },
              ),

              // Menu 4: Identity Verification
              _buildMenuRow(
                icon: Icons.gpp_good_outlined,
                title: "Identity Verification",
                badgeCount: 4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminIdentityVerificationPage()),
                  );
                },
              ),

              // Menu 5: Voucher
              _buildMenuRow(
                icon: Icons.confirmation_number_outlined,
                title: "Voucher & Point",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminVoucherPointPage()),
                  );
                },
              ),

              // Menu 6: Notification Settings
              _buildMenuRow(
                icon: Icons.notifications_none_outlined,
                title: "Notification Settings",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Pengaturan Notifikasi segera hadir!')),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ── 3. TOMBOL LOG OUT ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil keluar dari akun Admin!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, 
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.transparent, 
            border: Border(bottom: BorderSide(color: _grey200, width: 1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _black, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (badgeCount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), 
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.red, 
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right, color: _grey500, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}