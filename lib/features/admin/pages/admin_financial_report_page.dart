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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminFinancialReportPreviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');
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
            onPressed: _openReportPreview,
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
                  final monetaryRentals =
                      RentalManager.instance.monetaryRentals;
                  if (monetaryRentals.isEmpty) {
                    return _EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'Belum ada transaksi sewa',
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
  const AdminFinancialReportPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Laporan PDF'),
      ),
      body: PdfPreview(
        build: (format) => _generateReportPdf(format),
        canChangeOrientation: false,
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: pdf.PdfPageFormat.a4,
      ),
    );
  }

  Future<Uint8List> _generateReportPdf(pdf.PdfPageFormat format) async {
    final now = DateTime.now();
    final todayIncome = ReportService.incomeForDay(now);
    final monthIncome = ReportService.incomeForMonth(now.year, now.month);
    final totalIncome = todayIncome;

    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    final rentals = RentalManager.instance.monetaryRentals;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text('Laporan Keuangan',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Tanggal: ${dateFormat.format(now)}',
                style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 18),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfStatTile('Pendapatan Hari Ini',
                    currencyFormat.format(todayIncome), pdf.PdfColors.blue100),
                _buildPdfStatTile(
                    'Pendapatan Bulan Ini',
                    currencyFormat.format(monthIncome),
                    pdf.PdfColors.orange100),
                _buildPdfStatTile('Total Pendapatan',
                    currencyFormat.format(totalIncome), pdf.PdfColors.green100),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('Detail Transaksi',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            if (rentals.isEmpty)
              pw.Text('Tidak ada transaksi dengan nilai yang bisa dicetak.',
                  style: pw.TextStyle(fontSize: 12))
            else
              pw.Table.fromTextArray(
                headers: ['ID', 'Item', 'Periode', 'Jumlah'],
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

    return doc.save();
  }
}

pw.Widget _buildPdfStatTile(
    String label, String value, pdf.PdfColor backgroundColor) {
  return pw.Container(
    width: 150,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(value,
            style: const pw.TextStyle(
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
