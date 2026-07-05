import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
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
  static const Color _primaryPurple = Color(0xFF6A11CB);
  static const Color _primaryBlue = Color(0xFF2575FC);
  static const Color _accentOrange = Color(0xFFFF6B00);
  static const Color _accentGreen = Color(0xFF22C55E);

  static const int _itemsPerPage = 5;
  int _currentPage = 0;

  String _currency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  void _openReportPreview() {
    _showFilterDialog();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  'Select Print Filter',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    fontFamily: 'Inter', color: _black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the report time range you wish to print',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888), fontFamily: 'Inter'),
                ),
                const SizedBox(height: 20),
                _FilterOption(
                  icon: Icons.calendar_month,
                  title: 'Monthly',
                  subtitle: 'Print report for a specific month',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickMonth();
                  },
                ),
                const SizedBox(height: 12),
                _FilterOption(
                  icon: Icons.calendar_today_outlined,
                  title: 'Yearly',
                  subtitle: 'Print report for a specific year',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickYear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickMonth() {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;
    final years = List.generate(DateTime.now().year - 2019, (i) => 2020 + i);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              title: const Text('Select Month', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),
                    onChanged: (v) => setDialogState(() => selectedMonth = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (v) => setDialogState(() => selectedYear = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _black),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final start = DateTime(selectedYear, selectedMonth, 1);
                    final end = (selectedMonth == 12) ? DateTime(selectedYear + 1, 1, 1) : DateTime(selectedYear, selectedMonth + 1, 1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminFinancialReportPreviewPage(
                          filterType: 'month',
                          filterLabel: '${months[selectedMonth - 1]} $selectedYear',
                          startDate: start,
                          endDate: end,
                        ),
                      ),
                    );
                  },
                  child: const Text('Print', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickYear() {
    int selectedYear = DateTime.now().year;
    final years = List.generate(DateTime.now().year - 2019, (i) => 2020 + i);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              title: const Text('Select Year', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              content: DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: 'Year'),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                onChanged: (v) => setDialogState(() => selectedYear = v!),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _black),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final start = DateTime(selectedYear, 1, 1);
                    final end = DateTime(selectedYear + 1, 1, 1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminFinancialReportPreviewPage(
                          filterType: 'year',
                          filterLabel: 'Year $selectedYear',
                          startDate: start,
                          endDate: end,
                        ),
                      ),
                    );
                  },
                  child: const Text('Print', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Financial Report',
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
            onPressed: _openReportPreview,
            tooltip: 'Print Report',
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Rental>>(
          valueListenable: RentalManager.instance.rentalsNotifier,
          builder: (context, rentals, child) {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);
            final todayEnd = todayStart.add(const Duration(days: 1));
            
            // Calculate today's revenue dynamically
            final todayIncome = rentals
                .where((r) => !r.startDate.isBefore(todayStart) && r.startDate.isBefore(todayEnd))
                .fold<int>(0, (sum, r) => sum + (r.totalRentPrice ?? 0) + (r.deposit ?? 0));

            // Calculate this month's revenue dynamically
            final monthStart = DateTime(now.year, now.month, 1);
            final monthEnd = (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
            final monthIncome = rentals
                .where((r) => !r.startDate.isBefore(monthStart) && r.startDate.isBefore(monthEnd))
                .fold<int>(0, (sum, r) => sum + (r.totalRentPrice ?? 0) + (r.deposit ?? 0));

            // Calculate total revenue dynamically
            final totalIncome = rentals
                .fold<int>(0, (sum, r) => sum + (r.totalRentPrice ?? 0) + (r.deposit ?? 0));

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Quick Stats Grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              label: 'Today\'s Revenue',
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
                              label: 'This Month\'s Revenue',
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
                              label: 'Total Revenue',
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
                  ),
              const SizedBox(height: 32),

              // Riwayat Transaksi Rental
              const Text(
                'Rental Transaction History',
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
                  final monetaryRentals =
                      RentalManager.instance.monetaryRentals;
                  if (monetaryRentals.isEmpty) {
                    return _EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'No rental transactions yet',
                    );
                  }

                  // Calculate pagination
                  final totalPages =
                      (monetaryRentals.length / _itemsPerPage).ceil();
                  final startIndex = _currentPage * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage)
                      .clamp(0, monetaryRentals.length);
                  final pageRentals =
                      monetaryRentals.sublist(startIndex, endIndex);

                  return Column(
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageRentals.length,
                        separatorBuilder: (context, index) => const Divider(
                            color: Colors.transparent, height: 12),
                        itemBuilder: (context, index) {
                          final rental = pageRentals[index];
                          final totalAmount = (rental.totalRentPrice ?? 0) +
                              (rental.deposit ?? 0);
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
                      ),
                      const SizedBox(height: 20),
                      if (totalPages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: _currentPage > 0
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              color: _primaryPurple,
                            ),
                            Text(
                              '${_currentPage + 1} / $totalPages',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: _black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: _currentPage < totalPages - 1
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                              color: _primaryPurple,
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
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

class AdminFinancialReportPreviewPage extends StatelessWidget {
  final String filterType;
  final String filterLabel;
  final DateTime startDate;
  final DateTime endDate;

  const AdminFinancialReportPreviewPage({
    super.key,
    required this.filterType,
    required this.filterLabel,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFF8F9FA);
    const Color black = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report: $filterLabel',
          style: const TextStyle(
            color: black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => _generateReportPdf(format),
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: pdf.PdfPageFormat.a4,
      ),
    );
  }

  Future<Uint8List> _generateReportPdf(pdf.PdfPageFormat format) async {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Filter rentals by date range
    final allRentals = RentalManager.instance.monetaryRentals;
    final rentals = allRentals.where((rental) {
      return !rental.startDate.isBefore(startDate) &&
          rental.startDate.isBefore(endDate);
    }).toList();

    // Calculate filtered income
    int filteredIncome = 0;
    for (final rental in rentals) {
      filteredIncome += (rental.totalRentPrice ?? 0) + (rental.deposit ?? 0);
    }

    final pdfDoc = pw.Document();

    pdfDoc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text('Financial Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Period: $filterLabel',
                style: pw.TextStyle(fontSize: 12)),
            pw.Text('Printed: ${dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: pdf.PdfColors.grey600)),
            pw.SizedBox(height: 18),
            _buildPdfStatTile(
                'Total Revenue ($filterLabel)',
                currencyFormat.format(filteredIncome),
                pdf.PdfColors.green100),
            pw.SizedBox(height: 8),
            pw.Text('Number of Transactions: ${rentals.length}',
                style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 24),
            pw.Text('Transaction Details',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            if (rentals.isEmpty)
              pw.Text(
                  'No transactions in this period.',
                  style: pw.TextStyle(fontSize: 12))
            else
              pw.Table.fromTextArray(
                headers: ['ID', 'Item', 'Period', 'Amount'],
                data: rentals.map((rental) {
                  final amount =
                      (rental.totalRentPrice ?? 0) + (rental.deposit ?? 0);
                  return [
                    rental.transactionId,
                    rental.costumeName,
                    '${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}',
                    currencyFormat.format(amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration:
                    const pw.BoxDecoration(color: pdf.PdfColors.grey300),
                cellHeight: 24,
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(2.5),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
              ),
          ];
        },
      ),
    );

    return pdfDoc.save();
  }
}

pw.Widget _buildPdfStatTile(
    String label, String value, pdf.PdfColor backgroundColor) {
  return pw.Container(
    width: 150,
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
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

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}
