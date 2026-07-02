import 'package:flutter/material.dart';
import 'package:project_mopro/features/admin/pages/admin_create_voucher_page.dart';

class AdminVoucherPointPage extends StatefulWidget {
  const AdminVoucherPointPage({Key? key}) : super(key: key);

  @override
  State<AdminVoucherPointPage> createState() => _AdminVoucherPointPageState();
}

class _AdminVoucherPointPageState extends State<AdminVoucherPointPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _cardBg = Color(0xFFF9FAFB);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  final List<Map<String, String>> _vouchers = [
    {
      'code': 'NEWUSER20',
      'desc': 'Diskon 20% untuk pengguna baru, maks Rp 20.000',
      'used': '142x',
      'exp': '31 Jul 2026'
    },
    {
      'code': 'WEEKENDSTAY',
      'desc': 'Potongan harga Rp 50.000 khusus booking di hari Sabtu-Minggu',
      'used': '98x',
      'exp': '15 Aug 2026'
    }
  ];

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _grey200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _black, size: 22),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: _grey500, fontSize: 13, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: _black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
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
          "Voucher & Point",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.confirmation_number_outlined,
                      title: "Voucher Aktif",
                      value: _vouchers.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.percent_outlined,
                      title: "Total Terpakai",
                      value: "312x",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  const Text(
                    "Voucher Aktif",
                    style: TextStyle(
                      color: _black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminCreateVoucherPage()),
                      );

                      if (!mounted) return;

                      if (result != null && result is Map<String, String>) {
                        setState(() {
                          _vouchers.insert(0, {
                            'code': result['code']!,
                            'desc': result['desc']!,
                            'used': '0x',
                            'exp': result['exp']!,
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Voucher ${result['code']} Berhasil Dibuat! ðŸŽ‰'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: _black),
                    label: const Text(
                      "Buat",
                      style: TextStyle(color: _black, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _black, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final item = _vouchers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _grey200, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['code']!,
                            style: const TextStyle(
                              color: _black,
                              fontSize: 18,
                              fontWeight: FontWeight.w800, 
                              fontFamily: 'Inter',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              color: _grey500,
                              fontSize: 13,
                              fontFamily: 'Inter',
                              height: 1.4,
                    ),
                          ),
                          const SizedBox(height: 14),
                          Container(height: 1, color: _grey200),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              Text(
                                "Terpakai: ${item['used']}",
                                style: const TextStyle(color: _black, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                              ),
                              Text(
                                "Exp: ${item['exp']}",
                                style: const TextStyle(color: _grey500, fontSize: 12, fontFamily: 'Inter'),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}