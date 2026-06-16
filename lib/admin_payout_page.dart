import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _payoutHistory = [
    {'title': 'Penarikan ke BCA', 'date': '10 Jun 2026', 'amount': 'Rp 1.500.000'},
    {'title': 'Penarikan ke BCA', 'date': '28 Mei 2026', 'amount': 'Rp 2.000.000'},
    {'title': 'Penarikan ke BCA', 'date': '15 Mei 2026', 'amount': 'Rp 1.800.000'},
  ];

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
            onPressed: () {
              Navigator.pop(context);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── KARTU UTAMA SALDO ──
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
                    const Text(
                      "Rp 2.450.000",
                      style: TextStyle(
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

              // ── RINGKASAN PENDAPATAN ──
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 18),
                              SizedBox(width: 4),
                              Text("Total Pendapatan", style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter')),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Rp 12,8jt",
                            style: TextStyle(color: _black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward_rounded, color: Colors.orange, size: 18),
                              SizedBox(width: 4),
                              Text("Sudah Ditarik", style: TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter')),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Rp 10,3jt",
                            style: TextStyle(color: _black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
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

              // ── LIST RIWAYAT ──
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _payoutHistory.length,
                itemBuilder: (context, index) {
                  final item = _payoutHistory[index];
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
                              item['title']!,
                              style: const TextStyle(
                                color: _black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: const TextStyle(
                                color: _grey500,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item['amount']!,
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
        ),
      ),
    );
  }
}