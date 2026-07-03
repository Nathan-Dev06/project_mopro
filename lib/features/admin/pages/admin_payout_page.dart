import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class AdminPayoutPage extends StatefulWidget {
  const AdminPayoutPage({Key? key}) : super(key: key);

  @override
  State<AdminPayoutPage> createState() => _AdminPayoutPageState();
}

class _AdminPayoutPageState extends State<AdminPayoutPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _cardBg = Color(0xFFF9FAFB); 

  String _currency(int value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy').format(value.toDate());
    }
    return 'Baru saja';
  }

  void _showTarikDanaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Penarikan', 
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah anda yakin ingin menarik saldo ini ke rekening BCA terdaftar?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: _grey500)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseSyncService.createPayoutRequest(
                amount: 500000,
                title: 'Penarikan ke BCA',
              );

              final current = await FirebaseSyncService.financialSummaryDoc().get();
              final data = current.data() ?? FirebaseSyncService.defaultFinancialSummary();
              final available = (data['availableBalance'] ?? 0) as int;
              final withdrawn = (data['totalWithdrawn'] ?? 0) as int;

              await FirebaseSyncService.saveFinancialSummary({
                'availableBalance': (available - 500000).clamp(0, 1 << 31),
                'totalIncome': data['totalIncome'] ?? 0,
                'totalWithdrawn': withdrawn + 500000,
              });

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permintaan penarikan dana berhasil diproses! 💸')),
              );
            },
            child: const Text('Tarik', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payout & Financials",
          style: TextStyle(
            color: _black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseSyncService.financialSummaryDoc().snapshots(),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data?.data() ?? FirebaseSyncService.defaultFinancialSummary();
            final availableBalance = (summary['availableBalance'] ?? 0) as int;
            final totalIncome = (summary['totalIncome'] ?? 0) as int;
            final totalWithdrawn = (summary['totalWithdrawn'] ?? 0) as int;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseSyncService.payoutRequestsCollection().orderBy('createdAt', descending: true).snapshots(),
              builder: (context, payoutSnapshot) {
                final payouts = payoutSnapshot.data?.docs ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _grey200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Saldo Tersedia",
                              style: TextStyle(
                                color: _grey500,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currency(availableBalance),
                              style: const TextStyle(
                                color: _black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => _showTarikDanaDialog(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _black, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Tarik Dana",
                                  style: TextStyle(
                                    color: _black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _grey200, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 18),
                                      SizedBox(width: 4),
                                      Text("Total Pendapatan", style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currency(totalIncome),
                                    style: const TextStyle(color: _black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _grey200, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.arrow_downward_rounded, color: Colors.orange, size: 18),
                                      SizedBox(width: 4),
                                      Text("Sudah Ditarik", style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currency(totalWithdrawn),
                                    style: const TextStyle(color: _black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Riwayat Payout",
                        style: TextStyle(
                          color: _black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (payouts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Belum ada riwayat payout.',
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: payouts.length,
                          itemBuilder: (context, index) {
                            final item = payouts[index].data();
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: _grey200, width: 1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item['title'] ?? 'Payout').toString(),
                                        style: const TextStyle(
                                          color: _black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dateLabel(item['createdAt']),
                                        style: const TextStyle(
                                          color: _grey500,
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _currency((item['amount'] ?? 0) as int),
                                    style: const TextStyle(
                                      color: _black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}