import 'package:flutter/material.dart';

class AdminIdentityVerificationPage extends StatefulWidget {
  const AdminIdentityVerificationPage({Key? key}) : super(key: key);

  @override
  State<AdminIdentityVerificationPage> createState() => _AdminIdentityVerificationPageState();
}

class _AdminIdentityVerificationPageState extends State<AdminIdentityVerificationPage> {
  // Tema Warna disesuaikan dengan Putih Bersih (Light Mode) sesuai request
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _cardBg = Color(0xFFF9FAFB);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  // Data Dummy Pengajuan KTP (Ada 4 item sesuai badge angka 4 di profil kamu)
  final List<Map<String, String>> _verificationRequests = [
    {
      'id': '1',
      'name': 'Nadia Pratiwi',
      'email': 'nadia.p@email.com',
      'ktp': '3175 0145 0298 0003',
      'date': '13 Jun 2026',
    },
    {
      'id': '2',
      'name': 'Farhan Maulana',
      'email': 'farhan.m@email.com',
      'ktp': '3173 0102 9501 0012',
      'date': '12 Jun 2026',
    },
    {
      'id': '3',
      'name': 'Ahmad Hidayat',
      'email': 'ahmad.h@email.com',
      'ktp': '3214 0918 0497 0001',
      'date': '11 Jun 2026',
    },
    {
      'id': '4',
      'name': 'Siti Rahmawati',
      'email': 'siti.r@email.com',
      'ktp': '3578 1244 0399 0005',
      'date': '10 Jun 2026',
    },
  ];

  void _handleApprove(String id, String name) {
    setState(() {
      _verificationRequests.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Identitas $name berhasil disetujui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleReject(String id, String name) {
    setState(() {
      _verificationRequests.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Identitas $name telah ditolak.'),
        backgroundColor: Colors.red,
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
          "Validasi Identitas",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deskripsi Halaman (diambil dari acuan teks gambar hitam kamu)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Setujui atau tolak KTP pelanggan sebelum mereka bisa menyewa.",
                style: TextStyle(
                  color: _grey500,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Konten Utama List Kartu Verifikasi
            Expanded(
              child: _verificationRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.gpp_good_outlined, size: 64, color: _grey200),
                          SizedBox(height: 16),
                          Text(
                            "Semua identitas sudah divalidasi!",
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _verificationRequests.length,
                      itemBuilder: (context, index) {
                        final item = _verificationRequests[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _grey200, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Info Pelanggan & KTP
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Kotak Ikon ID Card Kiri
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.badge_outlined,
                                      color: _black,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Detail Teks Utama
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name']!,
                                          style: const TextStyle(
                                            color: _black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['email']!,
                                          style: const TextStyle(
                                            color: _grey500,
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "No. KTP: ${item['ktp']}",
                                          style: const TextStyle(
                                            color: _black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "• ${item['date']}",
                                          style: const TextStyle(
                                            color: _grey500,
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Tombol Aksi: Tolak & Setujui
                              Row(
                                children: [
                                  // Tombol Tolak
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        onPressed: () => _handleReject(item['id']!, item['name']!),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.red, width: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Tolak",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Tombol Setujui
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: () => _handleApprove(item['id']!, item['name']!),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _black,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Setujui",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}