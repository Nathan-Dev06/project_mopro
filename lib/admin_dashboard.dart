import 'package:flutter/material.dart';
import 'services/report_service.dart';
import 'user_profile.dart';
import 'manage_orders_page.dart';
import 'manage_costumes_page.dart';

class AdminDashboard extends StatefulWidget {
  // Ditambahkan parameter penampung fungsi supaya terhubung ke navigasi utama
  final VoidCallback? onSeeAllPressed;

  const AdminDashboard({Key? key, this.onSeeAllPressed}) : super(key: key);

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
                        const Text("Dashboard", style: TextStyle(color: _black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter', letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text('Welcome back, ${UserProfile.name.isEmpty ? 'Admin' : UserProfile.name}', style: const TextStyle(color: _grey500, fontSize: 14, fontFamily: 'Inter')),
                      ],
                    ),
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle, border: Border.all(color: _grey200)), child: const Icon(Icons.person_outline, color: _black)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Summary Cards ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _SummaryCard(title: 'Today Income', value: ReportService.formatCurrency(todayIncome), icon: Icons.payments_outlined),
                    const SizedBox(width: 12),
                    _SummaryCard(title: 'This Month', value: ReportService.formatCurrency(monthIncome), icon: Icons.account_balance_wallet_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    _SummaryCard(title: 'Active Rentals', value: '12', icon: Icons.local_mall_outlined),
                    SizedBox(width: 12),
                    _SummaryCard(title: 'Pending Verify', value: '4', icon: Icons.verified_user_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // ── Top Rented Section ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20), 
                child: Text('Admin Menu', style: TextStyle(color: _black, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'))
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), 
                child: Card(
                  elevation: 0, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _grey200)), 
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: _black), 
                    title: const Text('Manage Orders', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: _grey500), 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageOrdersPage())),
                  )
                )
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), 
                child: Card(
                  elevation: 0, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _grey200)), 
                  child: ListTile(
                    leading: const Icon(Icons.checkroom, color: _black), 
                    title: const Text('Manage Costumes', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)), 
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: _grey500), 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCostumesPage())),
                  )
                )
              ),

              const SizedBox(height: 32),
              
              // ── Top Rented + Lihat Semua ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Top Rented Costumes', style: TextStyle(color: _black, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                    
                    // ── BAGIAN MOUSE REGION YANG SUDAH BUBUP TAMBAHKAN ──
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onSeeAllPressed != null) {
                            widget.onSeeAllPressed!();
                          }
                        },
                        child: const Text('Lihat semua', style: TextStyle(color: _grey500, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
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
                separatorBuilder: (context, index) => const Divider(color: _grey200, height: 1),
                itemBuilder: (context, index) {
                  final key = top.keys.elementAt(index);
                  final count = top[key]!;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('#${index + 1}', style: const TextStyle(color: _black, fontWeight: FontWeight.w800, fontFamily: 'Inter')))),
                    title: Text(key, style: const TextStyle(color: _black, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                    subtitle: Text('$count rentals this month', style: const TextStyle(color: _grey500, fontSize: 12, fontFamily: 'Inter')),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0B0B0)),
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
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFB0B0B0), size: 22),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Color(0xFF888888), fontSize: 12, fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
