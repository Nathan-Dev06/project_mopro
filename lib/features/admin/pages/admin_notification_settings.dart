import 'package:flutter/material.dart';

class AdminNotificationSettingsPage extends StatefulWidget {
  const AdminNotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationSettingsPage> createState() => _AdminNotificationSettingsPageState();
}

class _AdminNotificationSettingsPageState extends State<AdminNotificationSettingsPage> {
 
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);


  bool _isOrderBaru = true;
  bool _isVerifikasiKTP = true;
  bool _isStockMenipis = true;
  bool _isVoucherExpired = false;

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
          "Notification Settings",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
            
                    _buildNotificationSwitch(
                      title: "Order Baru",
                      subtitle: "Notifikasi saat ada order masuk",
                      value: _isOrderBaru,
                      onChanged: (val) {
                        setState(() {
                          _isOrderBaru = val;
                        });
                      },
                    ),

     
                    _buildNotificationSwitch(
                      title: "Pengajuan Verifikasi KTP",
                      subtitle: "Notifikasi pengajuan baru",
                      value: _isVerifikasiKTP,
                      onChanged: (val) {
                        setState(() {
                          _isVerifikasiKTP = val;
                        });
                      },
                    ),

                    _buildNotificationSwitch(
                      title: "Stock Menipis",
                      subtitle: "Peringatan saat stock ≤ 1",
                      value: _isStockMenipis,
                      onChanged: (val) {
                        setState(() {
                          _isStockMenipis = val;
                        });
                      },
                    ),

            
                    _buildNotificationSwitch(
                      title: "Voucher Akan Expired",
                      subtitle: "Peringatan 3 hari sebelum expired",
                      value: _isVoucherExpired,
                      onChanged: (val) {
                        setState(() {
                          _isVoucherExpired = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

        
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
             
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan notifikasi berhasil disimpan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _grey200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _grey500,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _black, 
            inactiveThumbColor: _grey500,
            inactiveTrackColor: _grey200,
          ),
        ],
      ),
    );
  }
}