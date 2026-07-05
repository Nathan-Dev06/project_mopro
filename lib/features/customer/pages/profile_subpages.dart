import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/features/auth/pages/login_page.dart';
import 'package:project_mopro/core/models/user_profile.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';
import 'package:project_mopro/features/customer/pages/detail_costume_page.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';

import 'package:project_mopro/features/customer/pages/pending_payment_page.dart';
import 'package:intl/intl.dart';

// =============================================
// PROFILE SUBPAGES - Kick Avenue Clean Minimalist
// All pages: white Scaffold, white AppBar, elevation 0
// =============================================

// -- Shared Design Tokens --
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
//  1. MY RENTALS PAGE - Tabbed (Active / Completed / Canceled)
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
            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
            final activeRentals = RentalManager.instance.activeRentals
                .where((r) => r.userId == currentUserId)
                .toList();
            final completedRentals = RentalManager.instance.completedRentals
                .where((r) => r.userId == currentUserId)
                .toList();
            final canceledRentals = RentalManager.instance.canceledRentals
                .where((r) => r.userId == currentUserId)
                .toList();

            return TabBarView(
              children: [
                // -- TAB 1: ACTIVE --
                activeRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.shopping_bag_outlined,
                        title: "No active rentals",
                        subtitle: "You don't have any ongoing rentals.",
                      )
                    : _RentalsListTab(rentals: activeRentals),

                // -- TAB 2: COMPLETED --
                completedRentals.isEmpty
                    ? const _EmptyStateTab(
                        icon: Icons.check_circle_outline_rounded,
                        title: "No completed rentals",
                        subtitle:
                            "Your completed rental history\nwill appear here.",
                      )
                    : _RentalsListTab(rentals: completedRentals),

                // -- TAB 3: CANCELED --
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
              // -- Card Header: Order ID + Status Badge --
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
                    _buildStatusBadge(rental),
                  ],
                ),
              ),

              // -- Card Body: Costume Info --
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
                                "${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}",
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
              _buildRentalTimeline(rental),
              _buildCardFooter(context, rental),
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
                      "Cosvoria HQ\nJl. Kemang Raya No. 10, Bangka\nJakarta Selatan, 12730\nPhone: 0812-3456-7890",
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
                      if (rental.status == "Completed") ...[
                        const SizedBox(height: 32),
                        const Text(
                          "Payment & Deposit Summary",
                          style: TextStyle(
                            color: _K.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _K.grey200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDepositRow("Rental Price", rental.totalRentPrice ?? 0),
                              const SizedBox(height: 8),
                              _buildDepositRow("Deposit Paid", rental.deposit ?? 0),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: _K.grey200, height: 1),
                              ),
                              _buildDepositRow("Damage / Late Fee", -(rental.depositDeduction ?? 0), color: const Color(0xFFDC2626)),
                              if (rental.deductionReason != null && rental.deductionReason!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Note: ${rental.deductionReason}",
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFFDC2626), fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: _K.grey200, height: 1),
                              ),
                              _buildDepositRow(
                                "Deposit Refunded",
                                (rental.deposit ?? 0) - (rental.depositDeduction ?? 0),
                                color: const Color(0xFF16A34A),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ] else if (rental.status != "Canceled" && rental.status != "Cancellation Request") ...[
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

  // ── Status Badge Helper ──
  Widget _buildStatusBadge(Rental rental) {
    Color bgColor;
    Color textColor;
    switch (rental.status) {
      case "Pending":
        bgColor = const Color(0xFFFEF08A);
        textColor = const Color(0xFF854D0E);
        break;
      case "Packaging":
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        break;
      case "Shipped":
        bgColor = const Color(0xFFDDD6FE);
        textColor = const Color(0xFF5B21B6);
        break;
      case "Active":
      case "Renting":
        bgColor = _K.greenBg;
        textColor = _K.green;
        break;
      case "Cancellation Request":
        bgColor = const Color(0xFFFFE4E6);
        textColor = const Color(0xFFE11D48);
        break;
      case "Returned":
        bgColor = const Color(0xFFFEF9C3); // yellow-100
        textColor = const Color(0xFFA16207); // yellow-800
        break;
      case "Checking":
        bgColor = const Color(0xFFE0F2FE); // sky-100
        textColor = const Color(0xFF0369A1); // sky-700
        break;
      case "Completed":
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        break;
      case "Canceled":
        bgColor = const Color(0xFFFFE4E6);
        textColor = const Color(0xFFE11D48);
        break;
      default:
        bgColor = _K.grey200;
        textColor = _K.grey500;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rental.status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  // ── Card Footer Builder ──
  Widget _buildCardFooter(BuildContext context, Rental rental) {
    // Pending → Direct cancellation or Payment
    if (rental.status == "Pending") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Cancel Order?", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
                      content: const Text(
                        "Are you sure you want to cancel this unpaid order?",
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF555555), height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("No", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: _K.grey500)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            RentalManager.instance.updateRentalStatus(rental.transactionId, "Canceled");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Order has been canceled.", style: TextStyle(fontFamily: 'Inter')),
                                backgroundColor: Color(0xFFDC2626),
                              ),
                            );
                          },
                          child: const Text("Yes, Cancel", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel Order",
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingPaymentPage(rental: rental),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.payment_rounded, size: 16),
                label: const Text(
                  "Pay Now",
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Packaging → View Details / Request Cancellation
    if (rental.status == "Packaging") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRentalDetails(context, rental),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _K.black,
                  side: const BorderSide(color: _K.grey200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCancellationDialog(context, rental),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text(
                  "Cancel Order",
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Shipped → Confirm Arrival
    if (rental.status == "Shipped") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // blue-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "The package is on its way to your address. Please press the button below ONLY IF you have received the package and checked its condition.",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF1E3A8A), height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Confirm Order Received", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
                        content: const Text(
                          "Have you received the package safely? By pressing this button, your rental period will officially start.",
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF555555), height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Not yet", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: _K.grey500)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              RentalManager.instance.updateRentalStatus(rental.transactionId, "Active");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order received. Rental period started!", style: TextStyle(fontFamily: 'Inter')),
                                  backgroundColor: Color(0xFF16A34A),
                                ),
                              );
                            },
                            child: const Text("Yes, I've received it", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text(
                    "Confirm Item Received",
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Active → Return Info + View Details
    if (rental.status == "Active" || rental.status == "Renting") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4), // green-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)), // green-200
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Your rental period is ongoing. Please return the costume to the admin before the time limit ends to avoid penalties.",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF14532D), height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showReturnInfo(context, rental),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFF86EFAC)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Return Info",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRentalDetails(context, rental),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _K.black,
                        foregroundColor: _K.bg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Details",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Return Costume", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
                        content: const Text(
                          "Have you shipped the costume back to the admin? Please confirm to end your rental period.",
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF555555), height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: _K.grey500)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              RentalManager.instance.updateRentalStatus(rental.transactionId, "Returned");
                            },
                            child: const Text("Yes, Already Returned", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: _K.black)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.keyboard_return_rounded, size: 18),
                  label: const Text(
                    "Return Costume",
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Returned or Checking → Waiting for Admin
    if (rental.status == "Returned" || rental.status == "Checking") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3), // yellow-100
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFEF08A)), // yellow-200
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFFA16207), size: 20), // yellow-800
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rental.status == "Returned" 
                      ? "The costume is on its way back / returned. Waiting for admin to check the quality." 
                      : "Admin is checking the costume's condition. Please wait for the deposit refund process.",
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF713F12), height: 1.5), // yellow-900
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Completed → Write Review
    if (rental.status == "Completed") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deposit Refund Summary
            if (rental.deposit != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // green-50
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)), // green-200
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text("Deposit Refund Info", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDepositRow("Initial Deposit", rental.deposit!),
                    if (rental.depositDeduction != null && rental.depositDeduction! > 0) ...[
                      const SizedBox(height: 4),
                      _buildDepositRow("Penalty Deduction", -rental.depositDeduction!, color: Colors.red),
                      if (rental.deductionReason != null)
                        Text(
                          "Reason: ${rental.deductionReason}",
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.red, fontStyle: FontStyle.italic),
                        ),
                    ],
                    const Divider(height: 16, color: Color(0xFFBBF7D0)),
                    _buildDepositRow(
                      "Total Refund",
                      (rental.deposit!) - (rental.depositDeduction ?? 0),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Show existing review if present
            if (rental.rating != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _K.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          rental.rating!.toInt(),
                          (_) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                        ),
                        ...List.generate(
                          5 - rental.rating!.toInt(),
                          (_) => const Icon(Icons.star_outline_rounded, color: _K.grey300, size: 16),
                        ),
                      ],
                    ),
                    if (rental.reviewText != null && rental.reviewText!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        rental.reviewText!,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _K.grey500, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRentalDetails(context, rental),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _K.black,
                      side: const BorderSide(color: _K.grey200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text(
                      "View Details",
                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                if (rental.rating == null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReviewSheet(context, rental),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _K.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.rate_review_outlined, size: 16),
                      label: const Text(
                        "Write Review",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    // Cancellation Request → Waiting status
    if (rental.status == "Cancellation Request") {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cancellation request is being reviewed by admin.",
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.amber.shade900, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Canceled → no actions
    return const SizedBox.shrink();
  }
  Widget _buildRentalTimeline(Rental rental) {
    if (rental.status == "Canceled" || rental.status == "Cancellation Request" || rental.status == "Pending") {
      return const SizedBox.shrink();
    }

    int currentStep = 0;
    if (rental.status == "Packaging") currentStep = 0;
    else if (rental.status == "Shipped") currentStep = 1;
    else if (rental.status == "Active" || rental.status == "Renting") currentStep = 2;
    else if (rental.status == "Returned" || rental.status == "Checking") currentStep = 3;
    else if (rental.status == "Completed") currentStep = 4;

    final steps = ["Packed", "Shipped", "Rented", "Completed"];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIdx = index ~/ 2;
            final isCompleted = stepIdx < currentStep;
            final isActive = stepIdx == currentStep;
            final color = isCompleted || isActive ? _K.black : _K.grey200;
            
            return SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? _K.black : (isActive ? Colors.white : _K.grey100),
                      border: Border.all(color: color, width: isActive ? 2 : 1),
                    ),
                    child: isCompleted 
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : (isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: _K.black, shape: BoxShape.circle))) : null),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[stepIdx],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isCompleted || isActive ? _K.black : _K.grey400,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final lineIdx = index ~/ 2;
            final isLineCompleted = lineIdx < currentStep;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 11),
                height: 2,
                color: isLineCompleted ? _K.black : _K.grey200,
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildDepositRow(String label, int amount, {Color color = _K.black, bool isBold = false}) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color == _K.black ? _K.grey500 : color,
          ),
        ),
        Text(
          amount < 0 ? "-${currencyFormat.format(amount.abs())}" : currencyFormat.format(amount),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Cancellation Dialog (checks working hours 07:00 - 17:00) ──
  void _showCancellationDialog(BuildContext context, Rental rental) {
    final now = DateTime.now();
    final hour = now.hour;

    // Check working hours
    if (hour < 7 || hour >= 17) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.schedule_rounded, color: Colors.amber.shade700, size: 22),
              const SizedBox(width: 8),
              const Text("Outside Working Hours", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
          content: const Text(
            "Cancellation requests can only be submitted during working hours:\n\n🕖 07:00 AM — 05:00 PM\n\nPlease try again during these hours.",
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF555555), height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Understood", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }

    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 28, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Request Cancellation",
                    style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: _K.black),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: _K.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Order: ${rental.transactionId} — ${rental.costumeName}",
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _K.grey500),
              ),
              const SizedBox(height: 20),
              const Text(
                "Reason for cancellation *",
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Tell us why you want to cancel this order...",
                  hintStyle: const TextStyle(fontFamily: 'Inter', color: _K.grey400, fontSize: 13),
                  filled: true,
                  fillColor: _K.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please provide a reason for cancellation.", style: TextStyle(fontFamily: 'Inter')),
                          backgroundColor: Color(0xFFDC2626),
                        ),
                      );
                      return;
                    }
                    RentalManager.instance.updateRentalStatus(
                      rental.transactionId,
                      "Cancellation Request",
                      cancellationReason: reason,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cancellation request submitted. Awaiting admin approval.", style: TextStyle(fontFamily: 'Inter')),
                        backgroundColor: Color(0xFFF59E0B),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Submit Cancellation Request",
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Review / Complaint Bottom Sheet ──
  void _showReviewSheet(BuildContext context, Rental rental) {
    int selectedRating = 5;
    final reviewController = TextEditingController();
    String? selectedMediaType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 28, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Write Review",
                          style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: _K.black),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: _K.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${rental.costumeName} — ${rental.costumeSeries}",
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _K.grey500),
                    ),
                    const SizedBox(height: 24),

                    // Star Rating
                    const Text(
                      "Rating *",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: index < selectedRating ? const Color(0xFFF59E0B) : _K.grey300,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Review Text
                    const Text(
                      "Your Review / Complaint",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Tell us about your experience, any issues, or compliments...",
                        hintStyle: const TextStyle(fontFamily: 'Inter', color: _K.grey400, fontSize: 13),
                        filled: true,
                        fillColor: _K.grey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Media Attachment
                    const Text(
                      "Attach Photo / Video (optional)",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildMediaOption(
                          icon: Icons.photo_camera_outlined,
                          label: "Photo",
                          isSelected: selectedMediaType == 'image',
                          onTap: () => setSheetState(() {
                            selectedMediaType = selectedMediaType == 'image' ? null : 'image';
                          }),
                        ),
                        const SizedBox(width: 12),
                        _buildMediaOption(
                          icon: Icons.videocam_outlined,
                          label: "Video",
                          isSelected: selectedMediaType == 'video',
                          onTap: () => setSheetState(() {
                            selectedMediaType = selectedMediaType == 'video' ? null : 'video';
                          }),
                        ),
                      ],
                    ),
                    if (selectedMediaType != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _K.greenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedMediaType == 'image' ? Icons.image_rounded : Icons.video_file_rounded,
                              color: _K.green, size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedMediaType == 'image' ? "photo_review.jpg attached" : "video_review.mp4 attached",
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _K.green, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          RentalManager.instance.updateRentalStatus(
                            rental.transactionId,
                            "Completed",
                            rating: selectedRating.toDouble(),
                            reviewText: reviewController.text.trim(),
                            reviewMediaPath: selectedMediaType != null
                                ? (selectedMediaType == 'image' ? 'photo_review.jpg' : 'video_review.mp4')
                                : null,
                            reviewMediaType: selectedMediaType,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Thank you for your review!", style: TextStyle(fontFamily: 'Inter')),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _K.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Submit Review",
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _K.black : _K.grey100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _K.black : _K.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : _K.grey500),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _K.grey500,
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

  Future<bool> _submitKtp(BuildContext context, String ktpNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return false;
    }

    final trimmedKtp = ktpNumber.trim();
    final numericRegex = RegExp(r'^[0-9]+$');
    if (trimmedKtp.length != 16 || !numericRegex.hasMatch(trimmedKtp)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('ID number must be exactly 16 digits and numeric only.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'ktpNumber': trimmedKtp,
        'verificationStatus': 'pending',
        'verificationRequestedAtLabel': DateTime.now().toIso8601String(),
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (!navigator.mounted) return true;

    messenger.showSnackBar(
      const SnackBar(content: Text('ID successfully submitted to admin for verification.')),
    );
    return true;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _verificationStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
  }

  Map<String, Object> _statusInfo(String status) {
    switch (status) {
      case 'approved':
        return {
          'bg': _K.greenBg,
          'icon': _K.green,
          'title': 'Identity Verified',
          'subtitle': 'Your identity has been verified.\nYou can rent costumes without restrictions.',
        };
      case 'rejected':
        return {
          'bg': const Color(0xFFFEE2E2),
          'icon': Colors.red,
          'title': 'Verification Rejected',
          'subtitle': 'Please upload a clearer ID or contact support for review.',
        };
      case 'pending':
        return {
          'bg': const Color(0xFFFFF7ED),
          'icon': const Color(0xFFF59E0B),
          'title': 'Verification Pending',
          'subtitle': 'Your ID is waiting for admin review.\nWe will notify you once approved.',
        };
      default: // 'unverified'
        return {
          'bg': _K.grey100,
          'icon': _K.grey500,
          'title': 'Identity Unverified',
          'subtitle': 'Please upload your KTP / Student ID to verify your identity and start renting costumes.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "Identity Verification"),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _verificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          String status = (data?['verificationStatus'] ?? 'unverified').toString();
          final ktp = data?['ktpNumber']?.toString() ?? '';
          if (ktp.trim().isEmpty) {
            status = 'unverified';
          }
          final info = _statusInfo(status);

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: info['bg'] as Color,
                    ),
                    child: Icon(
                      status == 'approved'
                          ? Icons.verified_rounded
                          : (status == 'rejected'
                              ? Icons.error_outline_rounded
                              : (status == 'pending'
                                  ? Icons.hourglass_empty_rounded
                                  : Icons.info_outline_rounded)),
                      size: 40,
                      color: info['icon'] as Color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    info['title'] as String,
                    style: const TextStyle(
                      color: _K.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info['subtitle'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _K.grey500,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final ktpController = TextEditingController(text: data?['ktpNumber']?.toString() ?? '');

                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            final dialogNavigator = Navigator.of(dialogContext);

                            return AlertDialog(
                              title: const Text('Upload ID / Student Card'),
                              content: TextField(
                                controller: ktpController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'ID / Student Card Number',
                                  hintText: '3175xxxxxxxxxxxx',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final success = await _submitKtp(context, ktpController.text);
                                    if (success && dialogNavigator.mounted) {
                                      dialogNavigator.pop();
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.upload_file_outlined, size: 20),
                      label: const Text(
                        "Upload ID / Student Card",
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
          );
        },
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  3. SIZE PROFILE PAGE - Height & Weight input
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
        content: Text('Failed to save data: $e'),
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
//  4. MY VOUCHERS PAGE - Empty state
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class MyVouchersPage extends StatelessWidget {
  const MyVouchersPage({Key? key}) : super(key: key);

  String _statusLabel(Voucher voucher) {
    if (voucher.isUsed) return 'USED';
    if (voucher.isClaimed) return 'CLAIMED';
    return 'AVAILABLE';
  }

  Color _statusColor(Voucher voucher) {
    if (voucher.isUsed) return _K.grey200;
    if (voucher.isClaimed) return _K.greenBg;
    return const Color(0xFFFFF7ED);
  }

  Color _statusTextColor(Voucher voucher) {
    if (voucher.isUsed) return _K.grey500;
    if (voucher.isClaimed) return _K.green;
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      appBar: _minimalAppBar(context, "My Vouchers"),
      body: ValueListenableBuilder<List<Voucher>>(
        valueListenable: VoucherManager.instance.vouchersNotifier,
        builder: (context, vouchers, child) {
          if (vouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.confirmation_num_outlined,
                      size: 56, color: _K.grey300),
                  SizedBox(height: 16),
                  Text(
                    "No vouchers available",
                    style: TextStyle(
                      color: _K.grey800,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Vouchers created by admin will appear here automatically.",
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
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(voucher),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _statusLabel(voucher),
                                  style: TextStyle(
                                    color: _statusTextColor(voucher),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${voucher.discountPercent}% OFF',
                                style: const TextStyle(
                                  color: _K.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!voucher.isClaimed && !voucher.isUsed)
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await VoucherManager.instance.claimVoucher(voucher.code);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Voucher ${voucher.code} successfully claimed.')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _K.black, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Claim',
                            style: TextStyle(
                              color: _K.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      )
                    else if (voucher.isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _K.greenBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "CLAIMED",
                          style: TextStyle(
                            color: _K.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
//  5. WISHLIST PAGE - Empty state
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
//  6. SETTINGS PAGE - Empty state
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
          content: const Text('Profile updated successfully'),
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
          content: Text('Failed to save profile: $e'),
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
