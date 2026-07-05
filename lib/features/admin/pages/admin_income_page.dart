import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mopro/core/services/report_service.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';

class AdminIncomePage extends StatefulWidget {
  final String? initialPeriod; // 'today' or 'month'

  const AdminIncomePage({super.key, this.initialPeriod});

  @override
  State<AdminIncomePage> createState() => _AdminIncomePageState();
}

class _AdminIncomePageState extends State<AdminIncomePage> {
  // Tema Cosvoria Colors
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _primaryPurple = Color(0xFF6A11CB);
  static const Color _primaryBlue = Color(0xFF2575FC);
  static const Color _accentOrange = Color(0xFFFF6B00);

  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod ?? 'today';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    final monthFormat = DateFormat('MMMM yyyy');

    final todayIncome = ReportService.incomeForDay(now);
    final monthIncome = ReportService.incomeForMonth(now.year, now.month);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Revenue Report',
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Period
              Row(
                children: [
                  _FilterChip(
                    'Today',
                    _selectedPeriod == 'today',
                    () => setState(() => _selectedPeriod = 'today'),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    'This Month',
                    _selectedPeriod == 'month',
                    () => setState(() => _selectedPeriod = 'month'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _selectedPeriod == 'today' 
                      ? const [_primaryPurple, _primaryBlue]
                      : const [_accentOrange, Color(0xFFE91E8C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_selectedPeriod == 'today' ? _primaryPurple : _accentOrange).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPeriod == 'today' ? 'Today\'s Revenue' : 'This Month\'s Revenue',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedPeriod == 'today' ? dateFormat.format(now) : monthFormat.format(now),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(_selectedPeriod == 'today' ? todayIncome : monthIncome),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Transaction List
              const Text(
                'Transaction Details',
                style: TextStyle(
                  color: _black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List<Rental>>(
                valueListenable: RentalManager.instance.rentalsNotifier,
                builder: (context, rentals, child) {
                  final filteredRentals = RentalManager.instance.monetaryRentals.where((rental) {
                    final rentalDate = rental.startDate;
                    if (_selectedPeriod == 'today') {
                      return rentalDate.year == now.year &&
                             rentalDate.month == now.month &&
                             rentalDate.day == now.day;
                    } else {
                      return rentalDate.year == now.year &&
                             rentalDate.month == now.month;
                    }
                  }).toList();

                  if (filteredRentals.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _grey200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_outlined, color: _grey500, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRentals.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 12),
                    itemBuilder: (context, index) {
                      final rental = filteredRentals[index];
                      final totalAmount = (rental.totalRentPrice ?? 0) + (rental.deposit ?? 0);
                      final isWalkin = rental.userId == 'walkin-customer';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _grey200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long, color: _primaryPurple, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        rental.transactionId,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isWalkin)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _primaryPurple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Walk-in',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: _primaryPurple,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    rental.costumeName,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: _grey500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: _grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalAmount),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _FilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _black,
          ),
        ),
      ),
    );
  }
}
