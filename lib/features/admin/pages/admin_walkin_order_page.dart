import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mopro/core/managers/costume_manager.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';

class AdminWalkinOrderPage extends StatefulWidget {
  const AdminWalkinOrderPage({Key? key}) : super(key: key);

  @override
  State<AdminWalkinOrderPage> createState() => _AdminWalkinOrderPageState();
}

class _AdminWalkinOrderPageState extends State<AdminWalkinOrderPage> {
  // Tema Cosvoria Colors
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);
  static const Color _primaryPurple = Color(0xFF6A11CB);
  static const Color _primaryBlue = Color(0xFF2575FC);

  // State untuk kalender
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _totalDays = 0;
  final int _deposit = 50000;

  // Costume yang dipilih
  CostumeData? _selectedCostume;
  List<CostumeData> _availableCostumes = [];

  // Data customer walk-in
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSize = 'S';
  bool _isCashPayment = true;

  // Booked dates
  List<DateTime> _bookedDates = [];
  bool _isLoadingDates = false;

  @override
  void initState() {
    super.initState();
    _availableCostumes = CostumeManager.instance.costumesNotifier.value;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedDatesForCostume(CostumeData costume) async {
    setState(() => _isLoadingDates = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rentals')
          .where('costumeName', isEqualTo: costume.title)
          .get();

      final List<DateTime> blocked = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        if (status == 'Canceled') continue;

        final startTs = data['startDate'];
        final endTs = data['endDate'];
        if (startTs == null || endTs == null) continue;

        final start = (startTs as Timestamp).toDate();
        final end = (endTs as Timestamp).toDate();

        DateTime current = DateTime(start.year, start.month, start.day);
        DateTime effectiveEnd = DateTime(end.year, end.month, end.day);

        final now = DateTime.now();
        final todayNormalized = DateTime(now.year, now.month, now.day);

        if (status != 'Completed') {
          if (todayNormalized.isAfter(effectiveEnd)) {
            effectiveEnd = todayNormalized;
          }
        }

        final endWithMaintenance = effectiveEnd.add(const Duration(days: 2));

        while (!current.isAfter(endWithMaintenance)) {
          blocked.add(current);
          current = current.add(const Duration(days: 1));
        }
      }

      if (mounted) {
        setState(() {
          _bookedDates = blocked;
          _isLoadingDates = false;
          _rangeStart = null;
          _rangeEnd = null;
          _totalDays = 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading booked dates: $e');
      if (mounted) setState(() => _isLoadingDates = false);
    }
  }

  bool _isDayBooked(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    for (DateTime bookedDay in _bookedDates) {
      if (normalized.year == bookedDay.year &&
          normalized.month == bookedDay.month &&
          normalized.day == bookedDay.day) {
        return true;
      }
    }
    return false;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_isDayBooked(selectedDay)) return;

    DateTime calculatedEnd = selectedDay.add(const Duration(days: 2));
    bool isClashing = false;
    DateTime checkDate = selectedDay;

    while (!checkDate.isAfter(calculatedEnd)) {
      if (_isDayBooked(checkDate)) {
        isClashing = true;
        break;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    if (isClashing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Jadwal tidak tersedia. Terdapat pesanan lain dalam rentang 3 hari tersebut."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _totalDays = 0;
      });
      return;
    }

    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = selectedDay;
      _rangeEnd = calculatedEnd;
      _totalDays = 3;
    });
  }

  Future<void> _createWalkinOrder() async {
    if (_selectedCostume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pilih kostum terlebih dahulu!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pilih tanggal sewa!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final transactionId = 'WALKIN-${DateTime.now().millisecondsSinceEpoch}';

      int pricePerDay = 0;
      try {
        pricePerDay = int.parse(
                _selectedCostume!.price.replaceAll(RegExp(r'[^0-9]'), '')) ~/
            3;
      } catch (e) {
        pricePerDay = 50000;
      }

      final totalRentPrice = pricePerDay * _totalDays;
      final grandTotal = totalRentPrice + _deposit;

      final newRental = Rental(
        transactionId: transactionId,
        costumeName: _selectedCostume!.title,
        costumeSeries: _selectedCostume!.series,
        size: _selectedSize,
        imagePath: _selectedCostume!.image,
        startDate: _rangeStart!,
        endDate: _rangeEnd!,
        status: 'Active',
        customerName: _customerNameController.text,
        userId: 'walkin-customer',
        recipientName: _customerNameController.text,
        phone: _customerPhoneController.text,
        street: 'Walk-in Order',
        city: 'Walk-in Order',
        province: 'Walk-in Order',
        postal: '000000',
        totalRentPrice: totalRentPrice,
        deposit: _deposit,
        grandTotal: grandTotal,
      );

      await RentalManager.instance.addRental(newRental);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan Walk-in berhasil dibuat!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal membuat pesanan: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    int pricePerDay = 0;
    int totalRentPrice = 0;
    int grandTotal = 0;

    if (_selectedCostume != null) {
      try {
        pricePerDay = int.parse(
                _selectedCostume!.price.replaceAll(RegExp(r'[^0-9]'), '')) ~/
            3;
      } catch (e) {
        pricePerDay = 50000;
      }
      totalRentPrice = pricePerDay * _totalDays;
      grandTotal = totalRentPrice + _deposit;
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Pesanan Walk-in",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PILIH KOSTUM
            const Text(
              "Pilih Kostum",
              style: TextStyle(
                color: _black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _grey200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CostumeData>(
                  isExpanded: true,
                  value: _selectedCostume,
                  hint: const Text("Pilih Kostum"),
                  items: _availableCostumes.map((costume) {
                    return DropdownMenuItem<CostumeData>(
                      value: costume,
                      child: Text(
                        costume.title,
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCostume = value);
                      _loadBookedDatesForCostume(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // INFO KOSTUM (jika dipilih)
            if (_selectedCostume != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryPurple.withOpacity(0.1),
                      _primaryBlue.withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _selectedCostume!.image,
                        height: 70,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 70,
                          width: 60,
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
                            _selectedCostume!.title,
                            style: const TextStyle(
                              color: _black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCostume!.series,
                            style: const TextStyle(
                              color: _grey500,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(pricePerDay * 3),
                            style: const TextStyle(
                              color: _primaryPurple,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FORM CUSTOMER
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Data Customer",
                      style: TextStyle(
                        color: _black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Customer',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _grey200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _black, width: 1.5),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Masukkan nama customer'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'No. Telepon',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _grey200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _black, width: 1.5),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Masukkan nomor telepon'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _grey200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSize,
                          hint: const Text("Pilih Ukuran"),
                          items: ['S', 'M', 'L', 'XL', 'All Size']
                              .map((size) => DropdownMenuItem<String>(
                                    value: size,
                                    child: Text(size,
                                        style: const TextStyle(
                                            fontFamily: 'Inter')),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSize = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _grey200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _black, width: 1.5),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // PEMBAYARAN CASH
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Metode Pembayaran",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            _isCashPayment
                                ? "Bayar Cash / Offline"
                                : "Non-Tunai",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isCashPayment,
                      activeColor: _primaryPurple,
                      onChanged: (value) {
                        setState(() => _isCashPayment = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PILIH TANGGAL
              const Text(
                "Pilih Tanggal Sewa",
                style: TextStyle(
                  color: _black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 20, color: Color(0xFFD97706)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Pilih Tanggal Mulai Sewa. Sistem otomatis mengatur durasi sewa selama 3 Hari.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _grey200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isLoadingDates
                      ? const Center(child: CircularProgressIndicator())
                      : TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 90)),
                          focusedDay: _focusedDay,
                          rangeStartDay: _rangeStart,
                          rangeEndDay: _rangeEnd,
                          rangeSelectionMode: RangeSelectionMode.toggledOff,
                          onDaySelected: _onDaySelected,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _black,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            rangeHighlightColor:
                                _primaryPurple.withOpacity(0.1),
                            rangeStartDecoration: BoxDecoration(
                              color: _primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            rangeEndDecoration: BoxDecoration(
                              color: _primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            withinRangeDecoration: BoxDecoration(
                              color: _primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            withinRangeTextStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold),
                            todayDecoration: BoxDecoration(
                              color: _grey200,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                                color: _black,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold),
                          ),
                          calendarBuilders: CalendarBuilders(
                            disabledBuilder: (context, day, focusedDay) {
                              if (_isDayBooked(day)) {
                                return Center(
                                  child: Text(
                                    "${day.day}",
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "${day.day}",
                                    style: const TextStyle(
                                      color: Color(0xFFD1D5DB),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          enabledDayPredicate: (day) {
                            return !_isDayBooked(day);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.white, "Tersedia",
                      hasBorder: true, borderColor: _grey200),
                  _buildLegendItem(const Color(0xFFFCA5A5), "Rented (Coret)"),
                  _buildLegendItem(_primaryPurple, "Pilihanmu",
                      textColor: Colors.white),
                ],
              ),
              const SizedBox(height: 32),

              // RINCIAN BIAYA
              const Text(
                "Rincian Pembayaran",
                style: TextStyle(
                  color: _black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _grey200),
                ),
                child: Column(
                  children: [
                    _buildCostRow("Biaya Sewa ($_totalDays Hari)",
                        currencyFormat.format(totalRentPrice)),
                    const SizedBox(height: 12),
                    _buildCostRow("Deposit (Uang Jaminan)",
                        currencyFormat.format(_deposit)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: _grey200, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: _black,
                          ),
                        ),
                        Text(
                          currencyFormat.format(grandTotal),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: _black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _rangeStart == null ? _grey200 : _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _rangeStart == null ? null : _createWalkinOrder,
                  child: Text(
                    "Buat Pesanan Walk-in",
                    style: TextStyle(
                      color: _rangeStart == null ? _grey500 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool hasBorder = false,
      Color borderColor = Colors.transparent,
      Color textColor = const Color(0xFF111111)}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String amount, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor ?? _grey500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor ?? _black,
          ),
        ),
      ],
    );
  }
}
