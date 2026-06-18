import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  // Menyimpan status filter yang sedang dipilih aktif
  String selectedFilter = 'Semua';

  final List<Map<String, String>> dummyOrders = [
    {'id': 'ORD-1002', 'customer': 'Budi Santoso', 'costume': 'Genshin Impact Zhongli', 'status': 'Pending Approval', 'date': 'Today'},
    {'id': 'ORD-1001', 'customer': 'Ayu Lestari', 'costume': 'Spy x Family Anya', 'status': 'Active Rental', 'date': 'Yesterday'},
    {'id': 'ORD-1000', 'customer': 'Dimas', 'costume': 'Naruto Akatsuki Cloak', 'status': 'Completed', 'date': '10 Jun 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    // ── LOGIKA FILTER DATA ──
    // Di sini kita menyaring dummyOrders berdasarkan tombol status yang sedang aktif
    final filteredOrders = dummyOrders.where((order) {
      if (selectedFilter == 'Semua') {
        return true; // Tampilkan semua data jika pilih 'Semua'
      } else if (selectedFilter == 'Pending') {
        return order['status'] == 'Pending Approval';
      } else if (selectedFilter == 'Active') {
        return order['status'] == 'Active Rental';
      } else if (selectedFilter == 'Completed') {
        return order['status'] == 'Completed';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // ── JUDUL HALAMAN ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Orders",
                style: TextStyle(
                  color: _black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── 1. KOTAK PENCARIAN (SEARCH BAR) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  // TODO: Tempat menaruh logika pencarian nama/ID nanti setelah ini beres
                },
                style: const TextStyle(color: _black, fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari order ID atau nama...',
                  hintStyle: const TextStyle(color: _grey500, fontFamily: 'Inter'),
                  prefixIcon: const Icon(Icons.search, color: _grey500, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── 2. TOMBOL FILTER STATUS (DENGAN KURSOR TANGAN) ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── DAFTAR ORDERAN YANG SUDAH DI-FILTER ──
            Expanded(
              child: filteredOrders.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada orderan dengan status ini',
                        style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filteredOrders.length, // Menggunakan hasil filter
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index]; // Menggunakan hasil filter
                        final isPending = order['status'] == 'Pending Approval';
                        final isActive = order['status'] == 'Active Rental';
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _grey200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order['id']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      color: _grey500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending ? const Color(0xFFFEF08A) : (isActive ? const Color(0xFFDCFCE7) : _grey200),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order['status']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
                                        color: isPending ? const Color(0xFF854D0E) : (isActive ? const Color(0xFF166534) : _grey500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                order['costume']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  color: _black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rented by: ${order['customer']} • ${order['date']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  color: _grey500,
                                ),
                              ),
                              if (isPending) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                )
                              ]
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

  // Widget pembantu filter yang sudah ditambah interaksi klik tangan (MouseRegion)
  Widget _buildFilterChip(String label) {
    final bool isActive = selectedFilter == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // <── Bikin kursor jadi bentuk tangan saat diarahkan ke sini
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _black : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? _black : _grey200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : _grey500,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}