import 'package:flutter/material.dart';

class DetailCostumePage extends StatelessWidget {
  final Map<String, dynamic> costumeData;

  const DetailCostumePage({Key? key, required this.costumeData})
      : super(key: key);

  // PALET WARNA CLEAN & MINIMALIST (Menyesuaikan Home Page)
  final Color bgColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF5F5F5); // Abu-abu terang
  final Color textPrimary = Colors.black;
  final Color textSecondary = const Color(0xFF888888);
  final Color priceColor = const Color(0xFF00A651); // Hijau khas harga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. KONTEN UTAMA YANG BISA DI-SCROLL
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                _buildMainInfo(),
                const Divider(
                    height: 1, color: Color(0xFFEEEEEE)), // Garis pemisah tipis
                _buildDetailedInfo(),
                const SizedBox(
                    height: 120), // Spasi agar tidak tertutup tombol bawah
              ],
            ),
          ),

          // 2. TOMBOL BACK (MINIMALIS)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),

          // 3. BOTTOM ACTION BAR (STICKY DI BAWAH)
          _buildBottomAction(),
        ],
      ),
    );
  }

  // --- WIDGET GAMBAR HEADER ---
  Widget _buildHeaderImage() {
    return SizedBox(
      height: 480, // Dibuat lebih tinggi agar detail kostum terlihat full
      width: double.infinity,
      child: Image.network(
        costumeData['image'] ?? "",
        fit: BoxFit.cover,
      ),
    );
  }

  // --- WIDGET INFO UTAMA (JUDUL & HARGA) ---
  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series
          Text(
            (costumeData['series'] ?? "").toUpperCase(),
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Nama Karakter
          Text(
            costumeData['title'] ?? "",
            style: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Harga
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${costumeData['price'] ?? "0"}",
                style: TextStyle(
                  color: priceColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                " / 3 Hari",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chips Ukuran & Kondisi
          Row(
            children: [
              _infoChip(Icons.straighten_rounded,
                  "Size: ${costumeData['size'] ?? "-"}"),
              const SizedBox(width: 12),
              _infoChip(Icons.diamond_outlined,
                  "Kondisi: ${costumeData['condition'] ?? "-"}"),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET DETAIL KELENGKAPAN & KEBIJAKAN ---
  Widget _buildDetailedInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KELENGKAPAN
          Text(
            "Kelengkapan Kostum",
            style: TextStyle(
                color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            costumeData['include'] ?? "-",
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 32),

          // BLOK KEBIJAKAN SEWA (Clean & Light)
          Text(
            "Kebijakan Sewa Cosvoria",
            style: TextStyle(
                color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: textPrimary, size: 22),
                    const SizedBox(width: 12),
                    Text("Wajib Deposit Rp 50.000",
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 34.0),
                  child: Text(
                      "Deposit akan dikembalikan penuh jika kostum kembali tanpa kerusakan mayor atau noda permanen.",
                      style: TextStyle(
                          color: textSecondary, fontSize: 12, height: 1.5)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Color(0xFFE0E0E0), height: 1),
                ),
                Row(
                  children: [
                    Icon(Icons.local_laundry_service_outlined,
                        color: textPrimary, size: 22),
                    const SizedBox(width: 12),
                    Text("Tidak Perlu Dicuci",
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 34.0),
                  child: Text(
                      "Kembalikan kostum apa adanya setelah event. Biar tim kami yang mengurus proses laundry dan styling ulang wig secara profesional.",
                      style: TextStyle(
                          color: textSecondary, fontSize: 12, height: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CHIP INFO ---
  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: textPrimary, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL SEWA (BOTTOM BAR) ---
  Widget _buildBottomAction() {
    bool isReady = costumeData['isReady'] ?? false;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[200]!, width: 1)), // Garis tipis di atas
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Kolom Info Total Harga
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total (3 Hari)",
                        style: TextStyle(color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      "Rp ${costumeData['price'] ?? "0"}",
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Tombol Sewa Sekarang
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: isReady
                      ? () {
                          // TODO: Aksi pindah ke keranjang/booking
                        }
                      : null,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isReady
                          ? Colors.black
                          : Colors
                              .grey[300], // Hitam jika ready, abu jika kosong
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isReady ? "Sewa Sekarang" : "Sedang Disewa",
                        style: TextStyle(
                          color: isReady ? Colors.white : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
