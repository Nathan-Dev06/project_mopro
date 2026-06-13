import 'package:flutter/material.dart';

class DetailCostumePage extends StatelessWidget {
  final Map<String, dynamic> costumeData;

  const DetailCostumePage({Key? key, required this.costumeData})
      : super(key: key);

  // WARNA TEMA PREMIUM (Sama dengan Home)
  final Color bgColor = const Color(0xFF0A0516);
  final Color cardColor = const Color(0xFF160D29);
  final Color accentGold = const Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. BACKGROUND / IMAGE HEADER
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                _buildMainInfo(),
                _buildDetailedInfo(),
                const SizedBox(
                    height: 120), // Spasi agar tidak tertutup tombol bawah
              ],
            ),
          ),

          // 2. TOMBOL BACK (NAVIGASI KEMBALI)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // <--- FUNGSI BACK
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // 3. BOTTOM ACTION BAR (HARGA & TOMBOL SEWA)
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(costumeData['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              bgColor.withOpacity(0.8),
              bgColor,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            costumeData['series'].toUpperCase(),
            style: TextStyle(
              color: accentGold,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            costumeData['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _infoChip(Icons.star_rounded, costumeData['rating'], accentGold),
              const SizedBox(width: 12),
              _infoChip(Icons.straighten_rounded, costumeData['size'],
                  Colors.blueAccent),
              const SizedBox(width: 12),
              _infoChip(Icons.location_on_rounded, costumeData['location'],
                  Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kelengkapan Kostum",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            costumeData['include'],
            style:
                TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 30),
          const Text(
            "Pemilik",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentGold.withOpacity(0.2),
                  child: Icon(Icons.storefront_rounded, color: accentGold),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(costumeData['seller'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Online 5 menit lalu",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chat_bubble_outline_rounded, color: accentGold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, -10)),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Harga",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(
                  "Rp ${costumeData['price']}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [accentGold, const Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: accentGold.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Sewa Sekarang",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
