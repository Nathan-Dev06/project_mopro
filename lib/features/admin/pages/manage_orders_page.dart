import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  // Tema Cosvoria Colors
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _primaryPurple = Color(0xFF6A11CB);

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip('All', _selectedFilter == 'All', () => setState(() => _selectedFilter = 'All')),
                    const SizedBox(width: 8),
                    _FilterChip('Active', _selectedFilter == 'Active', () => setState(() => _selectedFilter = 'Active')),
                    const SizedBox(width: 8),
                    _FilterChip('Pending', _selectedFilter == 'Pending', () => setState(() => _selectedFilter = 'Pending')),
                    const SizedBox(width: 8),
                    _FilterChip('Completed', _selectedFilter == 'Completed', () => setState(() => _selectedFilter = 'Completed')),
                    const SizedBox(width: 8),
                    _FilterChip('Walk-in', _selectedFilter == 'Walk-in', () => setState(() => _selectedFilter = 'Walk-in')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Rental>>(
                valueListenable: RentalManager.instance.rentalsNotifier,
                builder: (context, rentals, child) {
                  // Filter orders
                  List<Rental> filteredRentals = rentals.where((rental) {
                    if (_selectedFilter == 'All') {
                      return true;
                    } else if (_selectedFilter == 'Walk-in') {
                      return rental.userId == 'walkin-customer';
                    } else {
                      return rental.status == _selectedFilter;
                    }
                  }).toList();

                  if (filteredRentals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, color: _grey500, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'Walk-in' ? 'Belum ada pesanan walk-in' : 'Belum ada pesanan',
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: filteredRentals.length,
                    itemBuilder: (context, index) {
                      final rental = filteredRentals[index];
                      final isWalkin = rental.userId == 'walkin-customer';
                      
                      Color statusColor = Colors.orange;
                      if (rental.status == 'Completed') statusColor = Colors.green;
                      if (rental.status == 'Active') statusColor = Colors.blue;
                      if (rental.status == 'Cancelled') statusColor = Colors.red;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _grey200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rental.transactionId,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    rental.status,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (isWalkin)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: _primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Walk-in Order',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryPurple,
                                  ),
                                ),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    rental.imagePath,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: 60,
                                      height: 60,
                                      color: _grey200,
                                      child: const Icon(Icons.image, color: _grey500),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rental.costumeName,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: _black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rental.costumeSeries,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: _grey500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 14, color: _grey500),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              rental.customerName,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                color: _black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (rental.phone != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_outlined, size: 14, color: _grey500),
                                            const SizedBox(width: 4),
                                            Text(
                                              rental.phone!,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                color: _grey500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: _grey200, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tanggal Sewa',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: _grey500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _black,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: _grey500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      rental.grandTotal != null ? currencyFormat.format(rental.grandTotal) : '-',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
    );
  }

  Widget _FilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primaryPurple : _grey200),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _black,
          ),
        ),
      ),
    );
  }
}