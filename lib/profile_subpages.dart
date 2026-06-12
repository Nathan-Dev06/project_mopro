import 'package:flutter/material.dart';
import 'user_profile.dart';

// =============================================
// PROFILE SUBPAGES — Kick Avenue Clean Minimalist
// All pages: white Scaffold, white AppBar, elevation 0
// =============================================

// ── Shared Design Tokens ──
class _K {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey800 = Color(0xFF333333);
  static const Color grey500 = Color(0xFF888888);
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey300 = Color(0xFFD5D5D5);
  static const Color grey200 = Color(0xFFE8E8E8);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF22C55E);
  static const Color greenBg = Color(0xFFDCFCE7);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFFFEF3C7);
  static const Color red = Color(0xFFEF4444);
  static const Color redBg = Color(0xFFFEE2E2);
}

/// Reusable minimalist AppBar for all subpages
PreferredSizeWidget _minimalAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: _K.bg,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      color: _K.black,
      onPressed: () => Navigator.pop(context),
    ),
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        color: _K.black,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.1,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  1. MY RENTALS PAGE — Tabbed (Active / Completed / Canceled)
// ═══════════════════════════════════════════════════════════════
class MyRentalsPage extends StatelessWidget {
  const MyRentalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _K.bg,
        appBar: AppBar(
          backgroundColor: _K.bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: _K.black,
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "My Rentals",
            style: TextStyle(
              color: _K.black,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          bottom: TabBar(
            labelColor: _K.black,
            unselectedLabelColor: _K.grey400,
            indicatorColor: _K.black,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── TAB 1: ACTIVE ──
            _ActiveRentalsTab(),

            // ── TAB 2: COMPLETED ──
            _EmptyStateTab(
              icon: Icons.check_circle_outline_rounded,
              title: "No completed rentals",
              subtitle: "Your completed rental history\nwill appear here.",
            ),

            // ── TAB 3: CANCELED ──
            _EmptyStateTab(
              icon: Icons.cancel_outlined,
              title: "No canceled rentals",
              subtitle: "You haven't canceled\nany rental yet.",
            ),
          ],
        ),
      ),
    );
  }
}

/// Active tab — shows a dummy rental card
class _ActiveRentalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Rental Card ──
          Container(
            decoration: BoxDecoration(
              color: _K.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _K.grey200, width: 1),
            ),
            child: Column(
              children: [
                // ── Card Header: Order ID + Status Badge ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _K.grey100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order ID
                      const Text(
                        "ORD-CSV-20260611",
                        style: TextStyle(
                          color: _K.grey500,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _K.greenBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Renting",
                          style: TextStyle(
                            color: _K.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Card Body: Costume Info ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail placeholder
                      Container(
                        width: 64,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _K.grey100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _K.grey200),
                        ),
                        child: const Icon(
                          Icons.checkroom_outlined,
                          color: _K.grey400,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Monkey D. Luffy (Wano)",
                              style: TextStyle(
                                color: _K.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "One Piece • Size L",
                              style: TextStyle(
                                color: _K.grey500,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Date range
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 13, color: _K.grey400),
                                const SizedBox(width: 6),
                                Text(
                                  "11 Jun – 14 Jun 2026",
                                  style: TextStyle(
                                    color: _K.grey500,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Remaining days
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 13, color: _K.amber),
                                const SizedBox(width: 6),
                                Text(
                                  "3 days remaining",
                                  style: TextStyle(
                                    color: _K.amber,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Card Footer: Total + Action ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _K.grey200, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Paid",
                            style: TextStyle(
                              color: _K.grey500,
                              fontSize: 11,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Rp 210.000",
                            style: TextStyle(
                              color: _K.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      // Detail button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _K.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget used in Completed and Canceled tabs
class _EmptyStateTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: _K.grey300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _K.grey800,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _K.grey400,
              fontSize: 13,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  2. IDENTITY VERIFICATION PAGE
// ═══════════════════════════════════════════════════════════════
class IdentityVerificationPage extends StatelessWidget {
  const IdentityVerificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Identity Verification"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Verified badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _K.greenBg,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 40,
                  color: _K.green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Identity Verified",
                style: TextStyle(
                  color: _K.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your identity has been verified.\nYou can rent costumes without restrictions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _K.grey500,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Upload button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file_outlined, size: 20),
                  label: const Text(
                    "Upload KTP / Kartu Pelajar",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _K.black,
                    side: const BorderSide(color: _K.black, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

// ═══════════════════════════════════════════════════════════════
//  3. SIZE PROFILE PAGE — Height & Weight input
// ═══════════════════════════════════════════════════════════════
class SizeProfilePage extends StatefulWidget {
  const SizeProfilePage({Key? key}) : super(key: key);

  @override
  State<SizeProfilePage> createState() => _SizeProfilePageState();
}

class _SizeProfilePageState extends State<SizeProfilePage> {
  final _heightController = TextEditingController(text: "170");
  final _weightController = TextEditingController(text: "65");

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "My Size Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Text(
              "Save your body measurements so we can\nrecommend the best costume size for you.",
              style: TextStyle(
                color: _K.grey500,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // Height
            const Text(
              "Height",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_heightController, "cm", Icons.height_rounded),
            const SizedBox(height: 20),

            // Weight
            const Text(
              "Weight",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
                _weightController, "kg", Icons.monitor_weight_outlined),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Size profile saved!"),
                      backgroundColor: _K.black,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _K.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Profile",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String suffix, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _K.grey200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: _K.black,
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _K.grey400, size: 20),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: _K.grey400,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  4. MY VOUCHERS PAGE — Empty state
// ═══════════════════════════════════════════════════════════════
class MyVouchersPage extends StatelessWidget {
  const MyVouchersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "My Vouchers"),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_num_outlined,
                size: 56, color: _K.grey300),
            const SizedBox(height: 16),
            const Text(
              "No active vouchers",
              style: TextStyle(
                color: _K.grey800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vouchers you receive from promos\nor events will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _K.grey400,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  5. WISHLIST PAGE — Empty state
// ═══════════════════════════════════════════════════════════════
class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Wishlist"),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded, size: 56, color: _K.grey300),
            const SizedBox(height: 16),
            const Text(
              "Your wishlist is empty",
              style: TextStyle(
                color: _K.grey800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the ♡ icon on any costume\nto save it for later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _K.grey400,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  6. SETTINGS PAGE — Empty state
// ═══════════════════════════════════════════════════════════════
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Settings"),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_outlined, size: 56, color: _K.grey300),
            const SizedBox(height: 16),
            const Text(
              "Settings",
              style: TextStyle(
                color: _K.grey800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "App preferences, notifications,\nand account settings — coming soon.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _K.grey400,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  7. EDIT PROFILE PAGE
// ═══════════════════════════════════════════════════════════════
class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const EditProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final result = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };
    UserProfile.updateFromMap(result);
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Edit Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Text(
              "Update your personal information.",
              style: TextStyle(
                color: _K.grey500,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // Name
            const Text(
              "Full Name",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_nameController, Icons.person_outline),
            const SizedBox(height: 20),

            // Email
            const Text(
              "Email Address",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_emailController, Icons.email_outlined,
                inputType: TextInputType.emailAddress),
            const SizedBox(height: 20),

            // Phone
            const Text(
              "Phone Number",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_phoneController, Icons.phone_outlined,
                inputType: TextInputType.phone),
            const SizedBox(height: 20),

            // Address
            const Text(
              "Address",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_addressController, Icons.home_outlined),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _K.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _K.grey200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(
          color: _K.black,
          fontSize: 15,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _K.grey400, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
