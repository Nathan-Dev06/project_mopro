import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'detail_costume_page.dart';
import 'wishlist_manager.dart';
import 'voucher_manager.dart';
import 'rental_manager.dart';
import 'package:intl/intl.dart';

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
          bottom: const TabBar(
            labelColor: _K.black,
            unselectedLabelColor: _K.grey400,
            indicatorColor: _K.black,
            indicatorWeight: 2.5,
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: ValueListenableBuilder<List<Rental>>(
          valueListenable: RentalManager.instance.rentalsNotifier,
          builder: (context, rentals, child) {
            final activeRentals = RentalManager.instance.activeRentals;
            final completedRentals = RentalManager.instance.completedRentals;
            final canceledRentals = RentalManager.instance.canceledRentals;

            return TabBarView(
              children: [
                // ── TAB 1: ACTIVE ──
                activeRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.shopping_bag_outlined,
                        title: "No active rentals",
                        subtitle: "You don't have any ongoing rentals.",
                      )
                    : _RentalsListTab(rentals: activeRentals),

                // ── TAB 2: COMPLETED ──
                completedRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.check_circle_outline_rounded,
                        title: "No completed rentals",
                        subtitle:
                            "Your completed rental history\nwill appear here.",
                      )
                    : _RentalsListTab(rentals: completedRentals),

                // ── TAB 3: CANCELED ──
                canceledRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.cancel_outlined,
                        title: "No canceled rentals",
                        subtitle: "You haven't canceled\nany rental yet.",
                      )
                    : _RentalsListTab(rentals: canceledRentals),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RentalsListTab extends StatelessWidget {
  final List<Rental> rentals;

  const _RentalsListTab({required this.rentals});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: rentals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final rental = rentals[index];
        final isFinished =
            rental.status == "Completed" || rental.status == "Canceled";
        final daysRemaining = rental.endDate.difference(DateTime.now()).inDays;

        return Container(
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
                decoration: const BoxDecoration(
                  color: _K.grey100,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order ID
                    Text(
                      rental.transactionId,
                      style: const TextStyle(
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
                        color: rental.status == "Completed"
                            ? _K.greenBg
                            : (rental.status == "Canceled"
                                ? const Color(0xFFFFE4E6)
                                : _K.greenBg),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rental.status,
                        style: TextStyle(
                          color: rental.status == "Completed"
                              ? _K.green
                              : (rental.status == "Canceled"
                                  ? const Color(0xFFE11D48)
                                  : _K.green),
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
                    // Thumbnail
                    Container(
                      width: 64,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _K.grey100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _K.grey200),
                        image: DecorationImage(
                          image: AssetImage(rental.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rental.costumeName,
                            style: const TextStyle(
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
                            "${rental.costumeSeries} • Size ${rental.size}",
                            style: const TextStyle(
                              color: _K.grey500,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Date range
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: _K.grey400),
                              const SizedBox(width: 6),
                              Text(
                                "${dateFormat.format(rental.startDate)} – ${dateFormat.format(rental.endDate)}",
                                style: const TextStyle(
                                  color: _K.grey500,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Remaining days (hanya jika aktif)
                          if (!isFinished && daysRemaining >= 0)
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 13, color: _K.amber),
                                const SizedBox(width: 6),
                                Text(
                                  "$daysRemaining days remaining",
                                  style: const TextStyle(
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

              // ── Card Footer: Action Buttons ──
              if (!isFinished)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Row(
                    children: [
                      // Return Button (Outlined)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showReturnInfo(context, rental),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _K.black,
                            side: const BorderSide(color: _K.grey200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Return Info",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Detail Button (Filled)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRentalDetails(context, rental),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _K.black,
                            foregroundColor: _K.bg,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showReturnInfo(BuildContext context, Rental rental) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _K.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Return Instructions",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _K.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: _K.black),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Step 1
                _buildReturnStep(
                  icon: Icons.inventory_2_outlined,
                  title: "1. Pack the Costume Safely",
                  subtitle:
                      "Ensure all accessories are included. Use the original box or a secure package to prevent damage during transit.",
                ),
                const SizedBox(height: 20),
                // Step 2
                _buildReturnStep(
                  icon: Icons.local_shipping_outlined,
                  title: "2. Ship via Courier",
                  subtitle:
                      "Use any trusted courier (JNE, Sicepat, J&T). The shipping cost is covered by you.",
                ),
                const SizedBox(height: 20),
                // Step 3
                _buildReturnStep(
                  icon: Icons.location_on_outlined,
                  title: "3. Send to Our Address",
                  subtitle:
                      "Cosvoria Studio\nJl. Meruya Selatan No. 12, Kembangan\nJakarta Barat, 11650\nPhone: 0812-3456-7890",
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _K.black,
                      foregroundColor: _K.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "I Understand",
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
      },
    );
  }

  Widget _buildReturnStep(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _K.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _K.black, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _K.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: _K.grey500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRentalDetails(BuildContext context, Rental rental) {
    final dateFormat = DateFormat('dd MMM yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: _K.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _K.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rental Details",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _K.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: _K.black),
                    ),
                  ],
                ),
              ),
              const Divider(color: _K.grey200),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge & Order ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _K.greenBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              rental.status.toUpperCase(),
                              style: const TextStyle(
                                color: _K.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            rental.transactionId,
                            style: const TextStyle(
                              color: _K.grey500,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Item Card
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _K.grey100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _K.grey200),
                              image: DecorationImage(
                                image: AssetImage(rental.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rental.costumeName,
                                  style: const TextStyle(
                                    color: _K.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${rental.costumeSeries} • Size ${rental.size}",
                                  style: const TextStyle(
                                    color: _K.grey500,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Rental Period
                      const Text(
                        "Rental Period",
                        style: TextStyle(
                          color: _K.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDateBox("Start Date",
                              dateFormat.format(rental.startDate)),
                          const SizedBox(width: 16),
                          const Icon(Icons.arrow_forward_rounded,
                              color: _K.grey400, size: 20),
                          const SizedBox(width: 16),
                          _buildDateBox(
                              "Return By", dateFormat.format(rental.endDate)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Important Notes
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB), // Light amber
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: _K.amber, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Please ensure the costume is shipped back before the return date to avoid late fees. Keep your receipt of shipping.",
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateBox(String label, String date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _K.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _K.grey500,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                color: _K.black,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
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
                decoration: const BoxDecoration(
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
              const Text(
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
            const Text(
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
          suffixStyle: const TextStyle(
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
      body: ValueListenableBuilder<List<Voucher>>(
        valueListenable: VoucherManager.instance.vouchersNotifier,
        builder: (context, vouchers, child) {
          final claimedVouchers = vouchers.where((v) => v.isClaimed).toList();

          if (claimedVouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.confirmation_num_outlined,
                      size: 56, color: _K.grey300),
                  SizedBox(height: 16),
                  Text(
                    "No active vouchers",
                    style: TextStyle(
                      color: _K.grey800,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 8),
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claimedVouchers.length,
            itemBuilder: (context, index) {
              final voucher = claimedVouchers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _K.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _K.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _K.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: _K.bg,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.code,
                            style: const TextStyle(
                              color: _K.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            voucher.description,
                            style: const TextStyle(
                              color: _K.grey500,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (voucher.isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _K.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "USED",
                          style: TextStyle(
                            color: _K.grey500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                  ],
                ),
              );
            },
          );
        },
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
      body: ValueListenableBuilder<List<String>>(
        valueListenable: WishlistManager.instance.wishlistNotifier,
        builder: (context, wishlist, _) {
          if (wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite_border_rounded,
                      size: 56, color: _K.grey300),
                  SizedBox(height: 16),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(
                      color: _K.grey800,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 8),
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
            );
          }

          // Filter costumes
          final List<CostumeData> results =
              kCostumes.where((c) => wishlist.contains(c.title)).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.62,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildWishlistCard(context, results[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, CostumeData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCostumePage(costumeData: data.toMap()),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: _K.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _K.grey100,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFFBBBBBB),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.isReady ? _K.greenBg : _K.redBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.isReady ? "Ready" : "Rented",
                        style: TextStyle(
                          color: data.isReady ? _K.green : _K.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        WishlistManager.instance.toggleWishlist(data.title);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.series,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _K.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _K.grey500,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Rp ${data.price} / 3 Days",
            style: const TextStyle(
              color: _K.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
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
          children: const [
            Icon(Icons.settings_outlined, size: 56, color: _K.grey300),
            SizedBox(height: 16),
            Text(
              "Settings",
              style: TextStyle(
                color: _K.grey800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 8),
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

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final result = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(result);

      await user.updateDisplayName(
        _nameController.text.trim(),
      );

      UserProfile.updateFromMap(result);

      if (!mounted) return;

      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profile: $e'),
        ),
      );
    }
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
            const Text(
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
