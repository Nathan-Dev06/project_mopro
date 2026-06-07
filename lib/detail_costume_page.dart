import 'package:flutter/material.dart';
import 'booking_page.dart';

class DetailCostumePage extends StatelessWidget {
  final Map<String, dynamic> costumeData;

  const DetailCostumePage({Key? key, required this.costumeData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. APP BAR DENGAN GAMBAR (Collapsible)
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background:
                  Image.network(costumeData['image'], fit: BoxFit.cover),
            ),
          ),

          // 2. KONTEN DETAIL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadge("READY TO RENT"),
                  const SizedBox(height: 12),
                  Text(costumeData['title'],
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(costumeData['series'],
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 20),

                  // PRICE & QUICK STATS
                  _buildPriceSection(),
                  const Divider(height: 40),

                  // FITMENT (DETAIL UKURAN)
                  _buildSectionTitle("Detail Ukuran (Size Guide)"),
                  _buildSizeGrid(),
                  const SizedBox(height: 30),

                  // KELENGKAPAN
                  _buildSectionTitle("Apa saja yang didapat?"),
                  _buildIncludeList(costumeData['include']),
                  const SizedBox(height: 30),

                  // KEBIJAKAN (USP)
                  _buildSectionTitle("Ketentuan Sewa"),
                  _buildPolicyCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Harga Sewa",
              style: TextStyle(fontWeight: FontWeight.w600)),
          Text("Rp ${costumeData['price']}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A651))),
        ],
      ),
    );
  }

  Widget _buildSizeGrid() {
    return Row(
      children: [
        _statChip(Icons.straighten, "Size: ${costumeData['size']}"),
        const SizedBox(width: 10),
        _statChip(Icons.person_outline,
            "TB: 160-170cm"), // Tambahkan field ini di data nanti
      ],
    );
  }

  Widget _buildPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _policyRow(Icons.local_laundry_service, "Tidak perlu cuci sendiri"),
          const Divider(),
          _policyRow(Icons.shield_outlined, "Wajib deposit Rp 50.000"),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _policyRow(IconData icon, String text) => Row(
      children: [Icon(icon, size: 20), const SizedBox(width: 10), Text(text)]);

  Widget _statChip(IconData icon, String label) =>
      Chip(avatar: Icon(icon, size: 16), label: Text(label));

  Widget _buildBadge(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: Colors.green[800],
              fontSize: 10,
              fontWeight: FontWeight.bold)));

  Widget _buildIncludeList(String include) {
    return Text(include,
        style: const TextStyle(color: Colors.grey, height: 1.5));
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12))),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50)),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookingPage(costumeData: costumeData))),
        child: const Text("SEWA SEKARANG",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
