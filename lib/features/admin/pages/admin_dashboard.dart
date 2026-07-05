import 'package:flutter/material.dart';
import 'package:project_mopro/core/services/report_service.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:project_mopro/core/models/user_profile.dart';
import 'package:project_mopro/features/admin/pages/manage_orders_page.dart';
import 'package:project_mopro/features/admin/pages/manage_costumes_page.dart';
import 'package:project_mopro/features/admin/pages/admin_walkin_order_page.dart';
import 'package:project_mopro/features/admin/pages/admin_financial_report_page.dart';
import 'package:project_mopro/core/services/firebase_sync_service.dart';
import 'package:project_mopro/features/admin/pages/admin_identity_verification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onSeeAllPressed;
  final VoidCallback? onProfilePressed;

  const AdminDashboard({
    Key? key,
    this.onSeeAllPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  // Tema Cosvoria - Warna menarik
  static const Color _primaryDark = Color(0xFF1E1E1E);
  static const Color _primaryPurple = Color(0xFF6A11CB);
  static const Color _primaryBlue = Color(0xFF2575FC);
  static const Color _accentOrange = Color(0xFFFF6B00);
  static const Color _accentGreen = Color(0xFF22C55E);
  static const Color _accentPink = Color(0xFFE91E8C);

  @override
  Widget build(BuildContext context) {
    final top = ReportService.topCostumes(limit: 10);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header dengan Desain Cosvoria ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("COSVORIA ADMIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                  letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text(
                              'Welcome back, ${UserProfile.name.isEmpty ? 'Admin' : UserProfile.name}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: 'Inter')),
                        ],
                      ),

                      // ── LOGO ADMIN PROFIL INTERAKTIF ──
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (widget.onProfilePressed != null) {
                              widget.onProfilePressed!();
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2575FC).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_outline,
                                color: Colors.white, size: 26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Summary Cards ──
              // ── Summary Cards ──
              ValueListenableBuilder<List<Rental>>(
                valueListenable: RentalManager.instance.rentalsNotifier,
                builder: (context, rentals, child) {
                  final now = DateTime.now();
                  final todayStart = DateTime(now.year, now.month, now.day);
                  final todayEnd = todayStart.add(const Duration(days: 1));
                  
                  // Calculate income dynamically from all rentals where start date is today
                  final todayIncome = rentals
                      .where((r) => !r.startDate.isBefore(todayStart) && r.startDate.isBefore(todayEnd))
                      .fold<int>(0, (sum, r) => sum + (r.totalRentPrice ?? 0) + (r.deposit ?? 0));

                  // Calculate income dynamically from all rentals where start date is within current month
                  final monthStart = DateTime(now.year, now.month, 1);
                  final monthEnd = (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
                  final monthIncome = rentals
                      .where((r) => !r.startDate.isBefore(monthStart) && r.startDate.isBefore(monthEnd))
                      .fold<int>(0, (sum, r) => sum + (r.totalRentPrice ?? 0) + (r.deposit ?? 0));

                  // Calculate active rentals dynamically
                  final activeRentalsCount = RentalManager.instance.activeRentals.length;

                  // Calculate pending orders (Pending verification status) dynamically
                  final pendingCount = rentals.where((r) => r.status == 'Pending').length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _SummaryCard(
                              title: 'Today Income',
                              value: ReportService.formatCurrency(todayIncome),
                              icon: Icons.payments_outlined,
                              gradientColors: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminFinancialReportPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              title: 'This Month',
                              value: ReportService.formatCurrency(monthIncome),
                              icon: Icons.account_balance_wallet_outlined,
                              gradientColors: const [Color(0xFFFF6B00), Color(0xFFE91E8C)],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminFinancialReportPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _SummaryCard(
                              title: 'Ongoing Orders',
                              value: '$activeRentalsCount',
                              icon: Icons.local_mall_outlined,
                              gradientColors: const [
                                Color(0xFF22C55E),
                                Color(0xFF16A34A)
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ManageOrdersPage(initialFilter: 'Ongoing'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseSyncService.usersCollection()
                                  .where('verificationStatus', isEqualTo: 'pending')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.docs.length ?? 0;
                                return _SummaryCard(
                                  title: 'Pending Verify',
                                  value: '$count',
                                  icon: Icons.verified_user_outlined,
                                  gradientColors: const [
                                    Color(0xFFEF4444),
                                    Color(0xFFDC2626)
                                  ],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdminIdentityVerificationPage(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── Admin Menu ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Admin Menu',
                  style: TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _MenuCard(
                      title: 'Financial Report',
                      subtitle: 'View complete financial reports',
                      icon: Icons.bar_chart_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminFinancialReportPage(),
                          ),
                        );
                      },
                      gradientColors: const [
                        Color(0xFF6A11CB),
                        Color(0xFF2575FC)
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MenuCard(
                      title: 'Create Walk-in Order',
                      subtitle: 'Manual order for direct customers',
                      icon: Icons.person_add_alt_1_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminWalkinOrderPage(),
                          ),
                        );
                      },
                      gradientColors: const [
                        Color(0xFFFF6B00),
                        Color(0xFFE91E8C)
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MenuCard(
                      title: 'Manage Orders',
                      subtitle: 'Manage customer rentals',
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageOrdersPage(),
                          ),
                        );
                      },
                      gradientColors: const [
                        Color(0xFF1E1E1E),
                        Color(0xFF3A3A3A)
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MenuCard(
                      title: 'Manage Costumes',
                      subtitle: 'Manage rental costumes',
                      icon: Icons.checkroom_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageCostumesPage(),
                          ),
                        );
                      },
                      gradientColors: const [
                        Color(0xFF6A11CB),
                        Color(0xFF2575FC)
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Top Rented Section ──
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Top Rented Costumes',
                      style: TextStyle(
                          color: _black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter'))),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _grey200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.receipt_long, color: Colors.white),
                    ),
                    title: const Text('Manage Orders',
                        style: TextStyle(
                            fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: _grey500),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ManageOrdersPage())),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _grey200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFE91E8C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.checkroom, color: Colors.white),
                    ),
                    title: const Text('Manage Costumes',
                        style: TextStyle(
                            fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: _grey500),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ManageCostumesPage())),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Top Rented + Lihat Semua ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Most Popular',
                        style: TextStyle(
                            color: _black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter')),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onSeeAllPressed != null) {
                            widget.onSeeAllPressed!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('View All',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top.keys.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: _grey200, height: 1),
                itemBuilder: (context, index) {
                  final key = top.keys.elementAt(index);
                  final count = top[key]!;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: index % 2 == 0
                                      ? const [
                                          Color(0xFF6A11CB),
                                          Color(0xFF2575FC)
                                        ]
                                      : const [
                                          Color(0xFFFF6B00),
                                          Color(0xFFE91E8C)
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                                child: Text('#${index + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Inter')))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(key,
                                  style: const TextStyle(
                                      color: _black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      fontFamily: 'Inter')),
                              const SizedBox(height: 4),
                              Text('$count rentals this month',
                                  style: const TextStyle(
                                      color: _grey500,
                                      fontSize: 12,
                                      fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: _grey500),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const _MenuCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right,
                  color: Color(0xFF888888), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 14),
                Text(title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
