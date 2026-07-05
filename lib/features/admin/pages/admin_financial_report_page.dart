import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/core/services/report_service.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:project_mopro/core/services/firebase_sync_service.dart';

class AdminFinancialReportPage extends StatefulWidget {
  const AdminFinancialReportPage({super.key});

  @override
  State<AdminFinancialReportPage> createState() =>
      _AdminFinancialReportPageState();
}

class _AdminFinancialReportPageState extends State<AdminFinancialReportPage> {
  // Tema Cosvoria Colors
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _primaryPurple = Color(0xFF6A11CB);
  static const Color _primaryBlue = Color(0xFF2575FC);
  static const Color _accentOrange = Color(0xFFFF6B00);
  static const Color _accentGreen = Color(0xFF22C55E);

  String _currency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy').format(value.toDate());
    }
    return DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur cetak laporan sedang dikembangkan! 🖨️'),
        backgroundColor: _primaryPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');
    final monthFormat = DateFormat('MMMM yyyy');
    final todayIncome = ReportService.incomeForDay(now);
    final monthIncome = ReportService.incomeForMonth(now.year, now.month);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: _black),
            onPressed: _printReport,
            tooltip: 'Cetak Laporan',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Quick Stats Grid
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseSyncService.financialSummaryDoc().snapshots(),
                builder: (context, summarySnapshot) {
                  final summary = summarySnapshot.data?.data() ??
                      FirebaseSyncService.defaultFinancialSummary();
                  final totalIncome = (summary['totalIncome'] ?? 0) as int;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              label: 'Pendapatan Hari Ini',
                              value: _currency(todayIncome),
                              icon: Icons.calendar_today,
                              gradientColors: const [
                                _primaryPurple,
                                _primaryBlue
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStatCard(
                              label: 'Pendapatan Bulan Ini',
                              value: _currency(monthIncome),
                              icon: Icons.calendar_month,
                              gradientColors: const [
                                _accentOrange,
                                Color(0xFFE91E8C)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              label: 'Total Pendapatan',
                              value: _currency(totalIncome),
                              icon: Icons.trending_up,
                              gradientColors: const [
                                _accentGreen,
                                Color(0xFF16A34A)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Riwayat Transaksi Rental
              const Text(
                'Riwayat Transaksi Sewa',
                style: TextStyle(
                  color: _black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List<Rental>>(
                valueListenable: RentalManager.instance.rentalsNotifier,
                builder: (context, rentals, child) {
                  if (rentals.isEmpty) {
                    return _EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'Belum ada transaksi sewa',
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rentals.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.transparent, height: 12),
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      final totalAmount =
                          (rental.totalRentPrice ?? 0) + (rental.deposit ?? 0);
                      final isWalkin = rental.userId == 'walkin-customer';

                      return _TransactionCard(
                        title: rental.transactionId,
                        subtitle: rental.costumeName,
                        date:
                            '${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}',
                        amount: _currency(totalAmount),
                        isWalkin: isWalkin,
                        isPayout: false,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? date;
  final String amount;
  final bool isWalkin;
  final bool isPayout;

  const _TransactionCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isWalkin = false,
    this.isPayout = false,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    const Color _black = Color(0xFF111111);
    const Color _grey500 = Color(0xFF888888);
    const Color _grey200 = Color(0xFFE8E8E8);
    const Color _primaryPurple = Color(0xFF6A11CB);
    const Color _accentOrange = Color(0xFFFF6B00);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  (isPayout ? _accentOrange : _primaryPurple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPayout ? Icons.account_balance_wallet : Icons.receipt_long,
              color: isPayout ? _accentOrange : _primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isWalkin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Walk-in',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _primaryPurple,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  date ?? subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _grey500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isPayout ? const Color(0xFFEF4444) : _black,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const Color _grey500 = Color(0xFF888888);
    const Color _grey200 = Color(0xFFE8E8E8);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _grey200),
      ),
      child: Column(
        children: [
          Icon(icon, color: _grey500, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: _grey500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
