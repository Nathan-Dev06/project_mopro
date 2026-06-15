import 'package:flutter/material.dart';
import 'services/report_service.dart';
import 'user_profile.dart';
import 'manage_orders_page.dart';
import 'manage_costumes_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ── Design Tokens ──
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayIncome = ReportService.incomeForDay(today);
<<<<<<< HEAD
    final monthIncome = ReportService.incomeForMonth(today.year, today.month);
    final top = ReportService.topCostumes(limit: 5);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            color: _black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, ${UserProfile.name.isEmpty ? 'Admin' : UserProfile.name}',
                          style: const TextStyle(
                            color: _grey500,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                        border: Border.all(color: _grey200),
                      ),
                      child: const Icon(Icons.person_outline, color: _black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Summary Cards ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _SummaryCard(
                      title: 'Today Income',
                      value: ReportService.formatCurrency(todayIncome),
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      title: 'This Month',
                      value: ReportService.formatCurrency(monthIncome),
                      icon: Icons.account_balance_wallet_outlined,
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
                      title: 'Active Rentals',
                      value: '12',
                      icon: Icons.local_mall_outlined,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      title: 'Pending Verify',
                      value: '4',
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // ── Top Rented Section ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Top Rented Costumes',
                  style: TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
=======
    final monthIncome =
        ReportService.incomeForMonth(today.year, today.month);

    final top = ReportService.topCostumes(limit: 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${UserProfile.name.isEmpty ? 'Admin' : UserProfile.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _SummaryCard(
                  title: 'Today Income',
                  value: ReportService.formatCurrency(todayIncome),
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: 'This Month',
                  value: ReportService.formatCurrency(monthIncome),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Admin Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ==========================
            // MANAGE ORDERS
            // ==========================
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Manage Orders'),
                subtitle: const Text('Manage customer rentals'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageOrdersPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ==========================
            // MANAGE COSTUMES
            // ==========================
            Card(
              child: ListTile(
                leading: const Icon(Icons.checkroom),
                title: const Text('Manage Costumes'),
                subtitle: const Text('Manage rental costumes'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageCostumesPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Top Rented Costumes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
>>>>>>> 92ab908a9b9199733eee0ec4d3861d9cb1c89b35
                itemCount: top.keys.length,
                separatorBuilder: (context, index) => Divider(color: _grey200, height: 1),
                itemBuilder: (context, index) {
                  final key = top.keys.elementAt(index);
                  final count = top[key]!;

                  return ListTile(
<<<<<<< HEAD
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: _black,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      key,
                      style: const TextStyle(
                        color: _black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                    subtitle: Text(
                      '$count rentals this month',
                      style: const TextStyle(
                        color: _grey500,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0B0B0)),
=======
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(key),
                    subtitle: Text('$count sewa'),
                    trailing: Text('$count times'),
>>>>>>> 92ab908a9b9199733eee0ec4d3861d9cb1c89b35
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
<<<<<<< HEAD
    required this.icon,
=======
>>>>>>> 92ab908a9b9199733eee0ec4d3861d9cb1c89b35
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
<<<<<<< HEAD
          border: Border.all(color: const Color(0xFFE8E8E8)),
=======
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
            ),
          ],
>>>>>>> 92ab908a9b9199733eee0ec4d3861d9cb1c89b35
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            Icon(icon, color: const Color(0xFFB0B0B0), size: 22),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
=======
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
>>>>>>> 92ab908a9b9199733eee0ec4d3861d9cb1c89b35
              ),
            ),
          ],
        ),
      ),
    );
  }
}