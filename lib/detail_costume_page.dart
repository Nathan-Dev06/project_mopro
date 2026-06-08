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
            elevation: 0,
            // Tombol kembali dengan lingkaran putih transparan agar selalu kontras
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Memastikan jika image URL kosong/error tidak membuat aplikasi crash
                  costumeData['image'] != null
                      ? Image.network(
                          costumeData['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey));
                          },
                        )
                      : const Center(
                          child:
                              Icon(Icons.image, size: 50, color: Colors.grey)),

                  // Gradasi gelap tipis di bagian paling atas widget
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  Text(
                    costumeData['title'] ?? 'Nama Kostum',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    costumeData['series'] ?? 'Serial',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // PRICE & QUICK STATS
                  _buildPriceSection(),
                  const Divider(height: 40),

                  // FITMENT (DETAIL UKURAN)
                  _buildSectionTitle("Detail Ukuran (Size Guide)"),
                  const SizedBox(height: 10),
                  _buildSizeGrid(),
                  const SizedBox(height: 30),

                  // KELENGKAPAN
                  _buildSectionTitle("Apa saja yang didapat?"),
                  const SizedBox(height: 10),
                  _buildIncludeList(costumeData['include'] ??
                      'Tidak ada deskripsi kelengkapan.'),
                  const SizedBox(height: 30),

                  // KEBIJAKAN (USP)
                  _buildSectionTitle("Ketentuan Sewa"),
                  const SizedBox(height: 10),
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
          Text(
            "Rp ${costumeData['price'] ?? '0'}",
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A651)),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeGrid() {
    return Row(
      children: [
        _statChip(Icons.straighten, "Size: ${costumeData['size'] ?? '-'}"),
        const SizedBox(width: 10),
        _statChip(Icons.person_outline, "TB: 160-170cm"),
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
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      );

  Widget _statChip(IconData icon, String label) => Chip(
        avatar: Icon(icon, size: 16, color: Colors.black87),
        label: Text(label),
        backgroundColor: const Color(0xFFF0F0F0),
        side: BorderSide(color: Colors.grey[200]!),
      );

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
        style:
            const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14));
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
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
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
