import 'package:flutter/material.dart';
import 'package:project_mopro/features/admin/pages/admin_create_voucher_page.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';

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

  Future<void> _showEditVoucherDialog(Voucher voucher) async {
    final descriptionController = TextEditingController(text: voucher.description);
    final discountController = TextEditingController(text: voucher.discountPercent.toString());

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diskon (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await VoucherManager.instance.updateVoucher(
                  code: voucher.code,
                  description: descriptionController.text.trim(),
                  discountPercent: int.tryParse(discountController.text.trim()) ?? voucher.discountPercent,
                  discountType: 'Persentase',
                  expiresAt: null,
                );

                if (!mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voucher ${voucher.code} berhasil diperbarui.')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVoucher(Voucher voucher) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Voucher'),
          content: Text('Hapus voucher ${voucher.code}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await VoucherManager.instance.deleteVoucher(voucher.code);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voucher ${voucher.code} dihapus.')),
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
              
              ValueListenableBuilder<List<Voucher>>(
                valueListenable: VoucherManager.instance.vouchersNotifier,
                builder: (context, vouchers, _) {
                  int usedCount = 0;
                  for (var v in vouchers) {
                    usedCount += v.usageCount;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.confirmation_number_outlined,
                          title: "Voucher Aktif",
                          value: vouchers.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.percent_outlined,
                          title: "Total Terpakai",
                          value: '${usedCount}x',
                        ),
                      ),
                    ],
                  );
                },
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
                child: ValueListenableBuilder<List<Voucher>>(
                  valueListenable: VoucherManager.instance.vouchersNotifier,
                  builder: (context, vouchers, _) {
                    if (vouchers.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada voucher.',
                          style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: vouchers.length,
                      itemBuilder: (context, index) {
                        final item = vouchers[index];
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
                                item.code,
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
                                item.description,
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
                                    "Terpakai: ${item.usageCount}x",
                                    style: const TextStyle(color: _black, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                                  ),
                                  Text(
                                    item.isClaimed ? 'Claimed' : 'Belum diklaim',
                                    style: const TextStyle(color: _grey500, fontSize: 12, fontFamily: 'Inter'),
                                  ),
                                ],
                              )
                              ,
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showEditVoucherDialog(item),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: _black, width: 1.2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: _black, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _deleteVoucher(item),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red, width: 1.2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
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