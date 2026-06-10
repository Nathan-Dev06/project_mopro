import 'package:flutter/material.dart';
import 'booking_page.dart';

class DetailCostumePage extends StatelessWidget {
  final Map<String, dynamic> costumeData;

  const DetailCostumePage({
    Key? key,
    required this.costumeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  costumeData['image'] != null
                      ? Image.network(
                          costumeData['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadge("READY TO RENT"),

                  const SizedBox(height: 12),

                  Text(
                    costumeData['title'] ?? 'Nama Kostum',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    costumeData['series'] ?? 'Series',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: const [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "4.9",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "(120+ Penyewa)",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildPriceSection(),

                  const SizedBox(height: 25),

                  _buildSectionTitle("Deskripsi Kostum"),

                  const SizedBox(height: 10),

                  Text(
                    costumeData['description'] ??
                        "Kostum premium berkualitas tinggi yang cocok digunakan untuk cosplay, photoshoot, event komunitas, festival, maupun kebutuhan konten kreatif.",
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Detail Ukuran"),

                  const SizedBox(height: 10),

                  _buildSizeGrid(),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Informasi Kostum"),

                  const SizedBox(height: 10),

                  _buildInfoCard(),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Apa Saja Yang Didapat?"),

                  const SizedBox(height: 10),

                  _buildIncludeList(),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Ketentuan Sewa"),

                  const SizedBox(height: 10),

                  _buildPolicyCard(),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Additional Item"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _additionalRow("Jubah", "+ Rp 30.000"),
                        const Divider(),
                        _additionalRow("Pedang Excalibur", "+ Rp 50.000"),
                        const Divider(),
                        _additionalRow(
                            "Sarung Tangan Armor", "+ Rp 20.000"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Informasi Pengiriman"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _policyRow(
                          Icons.inventory_2_outlined,
                          "Berat kirim ± 1 - 2 Kg",
                        ),
                        const Divider(),
                        _policyRow(
                          Icons.local_shipping_outlined,
                          "Bisa kirim seluruh Indonesia",
                        ),
                        const Divider(),
                        _policyRow(
                          Icons.store_outlined,
                          "Bisa ambil langsung di store",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Catatan Penting"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Kostum tidak selalu dalam kondisi 100% baru karena efek pemakaian. Namun seluruh kostum selalu dibersihkan dan dirawat secara berkala.",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

              

                  _buildSectionTitle("Aturan Sewa"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• Akun Instagram wajib publik selama masa rental."),
                        SizedBox(height: 8),
                        Text(
                            "• Akun cosplay/real minimal memiliki 2 postingan."),
                        SizedBox(height: 8),
                        Text(
                            "• Sertakan tanggal pemakaian saat melakukan booking."),
                        SizedBox(height: 8),
                        Text(
                            "• Booking diproses setelah pembayaran DP minimal 50%."),
                        SizedBox(height: 8),
                        Text("• Sistem booking siapa cepat dia dapat."),
                        SizedBox(height: 8),
                        Text(
                            "• Kostum wajib dikembalikan sesuai jadwal yang disepakati."),
                        SizedBox(height: 8),
                        Text(
                            "• Kerusakan atau kehilangan dikenakan biaya ganti rugi."),
                        SizedBox(height: 8),
                        Text(
                            "• Dilarang memodifikasi kostum tanpa izin pemilik."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Harga Sewa",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            "Rp ${costumeData['price'] ?? '0'}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A651),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _statChip(
          Icons.straighten,
          "Size: ${costumeData['size'] ?? '-'}",
        ),
        _statChip(
          Icons.person_outline,
          "TB: 160-170 cm",
        ),
        _statChip(
          Icons.accessibility_new,
          "BB: 50-70 Kg",
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _policyRow(Icons.verified_outlined, "Kondisi kostum 95% Like New"),
          const Divider(),
          _policyRow(Icons.inventory_2_outlined, "Stok tersedia"),
          const Divider(),
          _policyRow(Icons.calendar_month_outlined, "Minimal sewa 1 hari"),
        ],
      ),
    );
  }

  Widget _buildIncludeList() {
    final items = [
      "Armor Perunggu",
      "Helm Spartan",
      "Perisai Merah",
      "Tombak Prop",
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00A651),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _policyRow(
            Icons.local_laundry_service,
            "Tidak perlu mencuci kostum",
          ),
          const Divider(),
          _policyRow(
            Icons.shield_outlined,
            "Wajib deposit Rp 50.000",
          ),
          const Divider(),
          _policyRow(
            Icons.schedule_outlined,
            "Denda keterlambatan Rp 10.000/hari",
          ),
        ],
      ),
    );
  }

  Widget _additionalRow(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item),
        Text(
          price,
          style: const TextStyle(
            color: Color(0xFF00A651),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _policyRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookingPage(costumeData: costumeData),
            ),
          );
        },
        child: const Text(
          "SEWA SEKARANG",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}