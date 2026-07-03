import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/features/auth/pages/login_page.dart';
import 'package:project_mopro/core/models/user_profile.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
import 'package:project_mopro/features/customer/pages/detail_costume_page.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:intl/intl.dart';

// =============================================
// PROFILE SUBPAGES â€” Kick Avenue Clean Minimalist
// All pages: white Scaffold, white AppBar, elevation 0
// =============================================

// â”€â”€ Shared Design Tokens â”€â”€
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  1. MY RENTALS PAGE â€” Tabbed (Active / Completed / Canceled)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
                // â”€â”€ TAB 1: ACTIVE â”€â”€
                activeRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.shopping_bag_outlined,
                        title: "No active rentals",
                        subtitle: "You don't have any ongoing rentals.",
                      )
                    : _RentalsListTab(rentals: activeRentals),

                // â”€â”€ TAB 2: COMPLETED â”€â”€
                completedRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.check_circle_outline_rounded,
                        title: "No completed rentals",
                        subtitle:
                            "Your completed rental history\nwill appear here.",
                      )
                    : _RentalsListTab(rentals: completedRentals),

                // â”€â”€ TAB 3: CANCELED â”€â”€
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
              // â”€â”€ Card Header: Order ID + Status Badge â”€â”€
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

              // â”€â”€ Card Body: Costume Info â”€â”€
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
                            "${rental.costumeSeries} â€¢ Size ${rental.size}",
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
                                "${dateFormat.format(rental.startDate)} â€“ ${dateFormat.format(rental.endDate)}",
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

              // â”€â”€ Card Footer: Action Buttons â”€â”€
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
                                  "${rental.costumeSeries} â€¢ Size ${rental.size}",
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  2. IDENTITY VERIFICATION PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  3. SIZE PROFILE PAGE â€” Height & Weight input
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class SizeProfilePage extends StatefulWidget {
  const SizeProfilePage({Key? key}) : super(key: key);

  @override
  State<SizeProfilePage> createState() => _SizeProfilePageState();
}

class _SizeProfilePageState extends State<SizeProfilePage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSizeProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadSizeProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      _heightController.text =
          (data['height'] ?? '').toString();

      _weightController.text =
          (data['weight'] ?? '').toString();

      setState(() {});
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> _saveSizeProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'height': int.tryParse(_heightController.text) ?? 0,
      'weight': int.tryParse(_weightController.text) ?? 0,
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Size profile saved!'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan data: $e'),
      ),
    );
  }
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
                onPressed: _saveSizeProfile,
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  4. MY VOUCHERS PAGE â€” Empty state
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  5. WISHLIST PAGE â€” Empty state
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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
                    "Tap the â™¡ icon on any costume\nto save it for later.",
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  6. SETTINGS PAGE â€” Empty state
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Settings"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionHeader("Account & Security"),
            _buildListTile("Change Password", Icons.lock_outline, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
            }),
            _buildListTile("Delete Account", Icons.person_remove_outlined, isDestructive: true, onTap: () {
              _showDeleteAccountDialog();
            }),
            const SizedBox(height: 20),
            _buildSectionHeader("App Preferences"),
            _buildListTile("Language", Icons.language_outlined, trailingText: "English"),
            _buildListTile("Clear Cache", Icons.cleaning_services_outlined, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cache cleared successfully.")));
            }),
            const SizedBox(height: 20),
            _buildSectionHeader("Legal & About"),
            _buildListTile("Store Info & Location", Icons.storefront_outlined, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreInfoPage()));
            }),
            _buildListTile("Privacy Policy", Icons.privacy_tip_outlined, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
            }),
            _buildListTile("Terms of Service", Icons.description_outlined, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RentalTermsPage()));
            }),
            _buildListTile("Rate App", Icons.star_border_rounded, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to App Store...")));
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _K.grey500,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {VoidCallback? onTap, bool isDestructive = false, String? trailingText}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _K.grey200, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDestructive ? _K.red : _K.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? _K.red : _K.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  color: _K.grey400,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            if (trailingText == null && onTap != null)
              const Icon(Icons.chevron_right_rounded, size: 20, color: _K.grey300),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _K.bg,
        title: const Text("Delete Account", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone.", style: TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel", style: TextStyle(color: _K.black))),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Delete user data from Firestore
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  // Delete auth account
                  await user.delete();
                  
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("For security reasons, please log out and log back in before deleting your account.")));
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Failed to delete account")));
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: _K.red)),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  7. EDIT PROFILE PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String province;
  final String postal;

  const EditProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
    required this.postal,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _cityController = TextEditingController(text: widget.city);
    _provinceController = TextEditingController(text: widget.province);
    _postalController = TextEditingController(text: widget.postal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalController.dispose();
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
        'city': _cityController.text.trim(),
        'province': _provinceController.text.trim(),
        'postal': _postalController.text.trim(),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

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

            // City
            const Text(
              "City / Regency",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              _cityController,
              Icons.location_city_outlined,
            ),

            const SizedBox(height: 20),

            // Province
            const Text(
              "Province",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              _provinceController,
              Icons.map_outlined,
            ),

            const SizedBox(height: 20),

            // Postal Code
            const Text(
              "Postal Code",
              style: TextStyle(
                color: _K.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              _postalController,
              Icons.markunread_mailbox_outlined,
              inputType: TextInputType.number,
            ),
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

// =============================================
// RENTAL TERMS & RULES PAGE
// =============================================
class RentalTermsPage extends StatelessWidget {
  const RentalTermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Rental Terms & Rules"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Deposit Requirement"),
            _buildSectionText(
                "A deposit is required for all costume rentals. The deposit amount varies depending on the costume's value and tier. This deposit will be fully refunded within 1-2 business days after the costume is returned in good condition."),
            const SizedBox(height: 20),
            
            _buildSectionTitle("2. Rental Duration"),
            _buildSectionText(
                "The standard rental duration starts from the moment the costume is delivered until the end of the rental period specified in your booking. Late returns will be subject to a daily penalty of 10% from the total rental cost."),
            const SizedBox(height: 20),
            
            _buildSectionTitle("3. Costume Condition & Care"),
            _buildSectionText(
                "Please treat the costumes with respect. Do not wash, alter, or iron the costumes using high heat. Minor wear and tear are expected, but any permanent stains, rips, or missing accessories will incur deduction from your deposit."),
            const SizedBox(height: 20),

            _buildSectionTitle("4. Cancellations"),
            _buildSectionText(
                "Cancellations made 7 days prior to the rental date will receive a full refund. Cancellations made within 3 days will receive a 50% refund. No refunds will be issued for cancellations made within 24 hours of the rental date."),
            const SizedBox(height: 20),

            _buildSectionTitle("5. Shipping & Return"),
            _buildSectionText(
                "You are responsible for safely returning the costume using a trackable shipping method or returning it directly to our physical store. Please ensure the costume is packed securely to prevent any damage during transit."),
            const SizedBox(height: 40),

            const Center(
              child: Text(
                "Last updated: June 2026",
                style: TextStyle(
                  color: _K.grey400,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _K.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _K.grey800,
        fontSize: 14,
        height: 1.6,
        fontFamily: 'Inter',
      ),
    );
  }
}

// =============================================
// PRIVACY POLICY PAGE
// =============================================
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Privacy Policy"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                color: _K.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildText("At Cosvoria, we are committed to protecting your privacy and personal data. This Privacy Policy outlines how we collect, use, and safeguard your information when you use our application."),
            const SizedBox(height: 20),
            
            _buildTitle("1. Information We Collect"),
            _buildText("We collect information you provide directly to us, such as your name, email address, phone number, physical address, and payment information when you make a booking or create an account."),
            const SizedBox(height: 20),
            
            _buildTitle("2. How We Use Your Information"),
            _buildText("We use the information we collect to process your transactions, communicate with you regarding your rentals, send you promotional offers (if you have opted in), and improve our application's overall performance."),
            const SizedBox(height: 20),
            
            _buildTitle("3. Data Security"),
            _buildText("We implement a variety of security measures to maintain the safety of your personal information. Your data is contained behind secured networks and is only accessible by a limited number of persons who have special access rights."),
            const SizedBox(height: 40),

            const Center(
              child: Text(
                "Last updated: June 2026",
                style: TextStyle(
                  color: _K.grey400,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _K.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _K.grey800,
        fontSize: 14,
        height: 1.6,
        fontFamily: 'Inter',
      ),
    );
  }
}

// =============================================
// CHANGE PASSWORD PAGE
// =============================================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final oldPass = _oldPassController.text;
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New passwords do not match")));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPass);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully!")));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = e.message ?? "Failed to update password";
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = "Kata sandi saat ini salah.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Change Password"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a new password",
              style: TextStyle(
                color: _K.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your new password must be different from previous used passwords.",
              style: TextStyle(
                color: _K.grey500,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 32),
            _buildPasswordField("Current Password", _oldPassController, _obscureOld, () {
              setState(() => _obscureOld = !_obscureOld);
            }),
            const SizedBox(height: 20),
            _buildPasswordField("New Password", _newPassController, _obscureNew, () {
              setState(() => _obscureNew = !_obscureNew);
            }),
            const SizedBox(height: 20),
            _buildPasswordField("Confirm New Password", _confirmPassController, _obscureConfirm, () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            }),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _K.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Password",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _K.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _K.grey200, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(
              color: _K.black,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: _K.grey400, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _K.grey400, size: 20),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================
// STORE INFO & LOCATION PAGE
// =============================================
class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Store Info & Location"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Hero/Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Background Circles
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 60,
                    bottom: -40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "COSVORIA STUDIO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Premium Cosplay Rental",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              "Full Address",
              style: TextStyle(
                color: _K.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _K.grey200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _K.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on_rounded, color: _K.black, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cosvoria HQ",
                          style: TextStyle(
                            color: _K.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Jl. Kemang Raya No. 10, RT.1/RW.7\nBangka, Kec. Mampang Prpt.\nJakarta Selatan, DKI Jakarta 12730",
                          style: TextStyle(
                            color: _K.grey500,
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              "Location Map",
              style: TextStyle(
                color: _K.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            
            // Map Preview
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE5E3DF), // Standard map bg color
                border: Border.all(color: _K.grey200),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // A subtle grid to look like a map placeholder
                  CustomPaint(
                    painter: _MapGridPainter(),
                    size: Size.infinite,
                  ),
                  // Fake pin
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Text(
                            "Cosvoria Studio",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.location_on, color: Colors.red, size: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Opening Google Maps..."))
                   );
                },
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text(
                  "Open in Google Maps",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _K.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0;

    const double step = 20.0;
    
    // Draw vertical lines
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw some fake roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
      
    canvas.drawLine(Offset(size.width * 0.2, -10), Offset(size.width * 0.3, size.height + 10), roadPaint);
    canvas.drawLine(Offset(-10, size.height * 0.4), Offset(size.width + 10, size.height * 0.5), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
