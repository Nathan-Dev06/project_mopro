import 'package:flutter/material.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:project_mopro/features/admin/pages/manage_shipping_page.dart';

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

  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ValueListenableBuilder<List<Rental>>(
          valueListenable: RentalManager.instance.rentalsNotifier,
          builder: (context, allRentals, child) {
            // Apply search filter
            final searchedRentals = allRentals.where((r) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return r.transactionId.toLowerCase().contains(q) ||
                  r.customerName.toLowerCase().contains(q) ||
                  r.costumeName.toLowerCase().contains(q);
            }).toList();

            // Apply status filter
            final filteredOrders = searchedRentals.where((r) {
              if (selectedFilter == 'All') return true;
              if (selectedFilter == 'Cancellation') return r.status == 'Cancellation Request';
              return r.status == selectedFilter;
            }).toList();

            return Column(
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
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: _black, fontFamily: 'Inter', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search order ID, customer, or costume...',
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

                // ── 2. TOMBOL FILTER STATUS ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Packaging'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Shipped'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Returned'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Checking'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancellation'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Canceled'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── DAFTAR ORDERAN YANG SUDAH DI-FILTER ──
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rental = filteredOrders[index];
                            return _buildOrderCard(rental);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Rental rental) {
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
          // Header: ID + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rental.transactionId,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: _grey500,
                ),
              ),
              _buildStatusBadge(rental.status),
            ],
          ),
          const SizedBox(height: 12),

          // Costume Name
          Text(
            rental.costumeName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Inter',
              color: _black,
            ),
          ),
          const SizedBox(height: 4),

          // Customer + Series
          Text(
            'Customer: ${rental.customerName} • ${rental.costumeSeries}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: _grey500,
            ),
          ),

          // Show review info for completed orders
          if (rental.status == 'Completed' && rental.rating != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      const Text(
                        "Customer Review",
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                      ),
                      const Spacer(),
                      ...List.generate(
                        rental.rating!.toInt(),
                        (_) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                      ),
                      ...List.generate(
                        5 - rental.rating!.toInt(),
                        (_) => const Icon(Icons.star_outline_rounded, color: Color(0xFFD1D5DB), size: 14),
                      ),
                    ],
                  ),
                  if (rental.reviewText != null && rental.reviewText!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      rental.reviewText!,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF555555), height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (rental.reviewMediaPath != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          rental.reviewMediaType == 'image' ? Icons.image_rounded : Icons.video_file_rounded,
                          size: 14,
                          color: const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rental.reviewMediaPath!,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Show Terima & Cek button for Returned orders
          if (rental.status == 'Returned') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  RentalManager.instance.updateRentalStatus(rental.transactionId, 'Checking');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order moved to Checking phase.', style: TextStyle(fontFamily: 'Inter'))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.inventory_rounded, size: 16),
                label: const Text("Terima & Cek Kostum", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
              ),
            ),
          ],

          // Show Selesaikan Sewa button for Checking orders
          if (rental.status == 'Checking') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDepositDeductionDialog(context, rental),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: const Text("Selesaikan Sewa (Deposit)", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
              ),
            ),
          ],

          // Show Atur Pemesanan button for Packaging orders
          if (rental.status == 'Packaging') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageShippingPage(rental: rental),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.local_shipping_rounded, size: 16),
                label: const Text(
                  "Atur Pemesanan",
                  style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                ),
              ),
            ),
          ],

          // Show cancellation reason + Approve/Reject for Cancellation Request
          if (rental.status == 'Cancellation Request') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE11D48)),
                      SizedBox(width: 6),
                      Text(
                        "Cancellation Reason:",
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE11D48)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rental.cancellationReason ?? 'No reason provided',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF881337), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      RentalManager.instance.updateRentalStatus(rental.transactionId, 'Packaging');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cancellation rejected. Order returned to Packaging.', style: TextStyle(fontFamily: 'Inter')),
                          backgroundColor: Color(0xFF3B82F6),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      RentalManager.instance.updateRentalStatus(rental.transactionId, 'Canceled');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cancellation approved. Order has been canceled.', style: TextStyle(fontFamily: 'Inter')),
                          backgroundColor: Color(0xFFDC2626),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Status Badge
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'Pending':
        bgColor = const Color(0xFFFEF08A);
        textColor = const Color(0xFF854D0E);
        break;
      case 'Packaging':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        break;
      case 'Shipped':
        bgColor = const Color(0xFFDDD6FE);
        textColor = const Color(0xFF5B21B6);
        break;
      case 'Active':
      case 'Renting':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'Cancellation Request':
        bgColor = const Color(0xFFFFE4E6);
        textColor = const Color(0xFFE11D48);
        break;
      case 'Returned':
        bgColor = const Color(0xFFFEF9C3); // yellow-100
        textColor = const Color(0xFFA16207); // yellow-800
        break;
      case 'Checking':
        bgColor = const Color(0xFFE0F2FE); // sky-100
        textColor = const Color(0xFF0369A1); // sky-700
        break;
      case 'Completed':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        break;
      case 'Canceled':
        bgColor = const Color(0xFFFFE4E6);
        textColor = const Color(0xFFE11D48);
        break;
      default:
        bgColor = _grey200;
        textColor = _grey500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
          color: textColor,
        ),
      ),
    );
  }

  // Filter Chip
  Widget _buildFilterChip(String label) {
    final bool isActive = selectedFilter == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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

  void _showDepositDeductionDialog(BuildContext context, Rental rental) {
    int deductionAmount = 0;
    String deductionReason = '';
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Penyelesaian & Deposit", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 18)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Uang Jaminan: Rp ${rental.deposit ?? 0}",
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Color(0xFF16A34A), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Denda / Potongan (Rp)", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Contoh: 20000 (Kosongkan jika tidak ada)",
                  hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _grey500),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _grey200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _grey200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                onChanged: (val) {
                  deductionAmount = int.tryParse(val) ?? 0;
                },
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final valInt = int.tryParse(val);
                    if (valInt == null) return "Harus berupa angka";
                    if (valInt > (rental.deposit ?? 0)) return "Denda melebihi deposit!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text("Alasan Denda", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Contoh: Terlambat 1 hari / Noda di baju",
                  hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _grey500),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _grey200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _grey200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                onChanged: (val) => deductionReason = val,
                validator: (val) {
                  if (deductionAmount > 0 && (val == null || val.isEmpty)) {
                    return "Alasan wajib diisi jika ada denda";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: _grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                RentalManager.instance.updateRentalStatus(
                  rental.transactionId,
                  'Completed',
                  depositDeduction: deductionAmount,
                  deductionReason: deductionAmount > 0 ? deductionReason : null,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order completed! Refund: Rp ${(rental.deposit ?? 0) - deductionAmount}', style: const TextStyle(fontFamily: 'Inter')),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Konfirmasi Selesai", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}