import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:project_mopro/features/customer/pages/payment_page.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> costumeData;

  const BookingPage({Key? key, required this.costumeData}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // ==================== NEW LIGHT EDITORIAL SYSTEM ====================
  final Color bgColor = const Color(0xFFF5F5F5); // Off-White Canvas
  final Color surfaceColor = const Color(0xFFFFFFFF); // Pure White Card
  final Color textPrimary = const Color(0xFF1C1917); // Charcoal Dark Ink
  final Color textSecondary = const Color(0xFF716B64); // Editorial Muted Text
  final Color hairlineStrong = const Color(0xFFE5E5E0); // Soft Muted Border

  // PASTEL ACCENTS
  final Color accentMint =
      const Color(0xFF0F9F7E); // Darker Emerald for clear text
  final Color accentLavender = const Color(0xFFD4C7EB);
  final Color accentPeach = const Color(0xFFFAD1B8);

  // STATE UNTUK KALENDER
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _totalDays = 0;
  final int _deposit = 50000;
  Voucher? _selectedVoucher;

  // Alamat pengiriman
  final _addressFormKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

    @override
  void initState() {
    super.initState();
    _fillFromProfile();
    _loadBookedDatesFromFirestore();
  }

  // BOOKED DATES — loaded from Firestore in real-time
  List<DateTime> _bookedDates = [];
  bool _isLoadingDates = true;

  /// Query Firestore for all active rentals of THIS costume and expand
  /// their date ranges into individual blocked days.
  Future<void> _loadBookedDatesFromFirestore() async {
    try {
      final costumeName = widget.costumeData['title'] ?? '';
      if (costumeName.isEmpty) {
        setState(() => _isLoadingDates = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('rentals')
          .where('costumeName', isEqualTo: costumeName)
          .get();

      final List<DateTime> blocked = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';

        // Skip canceled orders — those dates are freed up
        if (status == 'Canceled') continue;

        final startTs = data['startDate'];
        final endTs = data['endDate'];
        if (startTs == null || endTs == null) continue;

        final start = (startTs as Timestamp).toDate();
        final end = (endTs as Timestamp).toDate();

        // Expand the range into individual days
        DateTime current = DateTime(start.year, start.month, start.day);
        final endNormalized = DateTime(end.year, end.month, end.day);
        while (!current.isAfter(endNormalized)) {
          blocked.add(current);
          current = current.add(const Duration(days: 1));
        }
      }

      if (mounted) {
        setState(() {
          _bookedDates = blocked;
          _isLoadingDates = false;
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

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;

      if (start != null && end != null) {
        bool isClashing = false;
        DateTime checkDate = start;
        while (checkDate.isBefore(end) || isSameDay(checkDate, end)) {
          if (_isDayBooked(checkDate)) {
            isClashing = true;
            break;
          }
          checkDate = checkDate.add(const Duration(days: 1));
        }

        if (isClashing) {
          _rangeStart = null;
          _rangeEnd = null;
          _totalDays = 0;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Rentang tanggal tidak valid. Ada tanggal yang sudah disewa!"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _totalDays = end.difference(start).inDays + 1;
        }
      } else if (start != null && end == null) {
        _totalDays = 1;
      } else {
        _totalDays = 0;
      }
    });
  }

  Future<void> _fillFromProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      _recipientController.text =
          data['name']?.toString() ?? '';

      _phoneController.text =
          data['phone']?.toString() ?? '';

      _streetController.text =
          data['address']?.toString() ?? '';

      _cityController.text =
          data['city']?.toString() ?? '';

      _postalController.text =
          data['postal']?.toString() ?? '';

      _provinceController.text =
          data['province']?.toString() ?? '';
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data profil berhasil dimuat'),
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}

  void _showVoucherSelector() {
    final availableVouchers = VoucherManager.instance.claimedVouchers
        .where((v) => !v.isUsed)
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pilih Voucher",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (availableVouchers.isEmpty)
                Text(
                  "Tidak ada voucher yang tersedia.",
                  style: TextStyle(color: textSecondary, fontFamily: 'Inter'),
                )
              else
                ...availableVouchers.map((v) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_offer, color: Colors.green),
                    title: Text(v.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(v.description),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${v.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedVoucher = v;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parsing harga
    int pricePer3Days = int.parse(
        widget.costumeData['price'].replaceAll(RegExp(r'[^0-9]'), ''));
    int pricePerDay = pricePer3Days ~/ 3;
    int totalRentPrice = pricePerDay * _totalDays;
    
    int discountAmount = 0;
    if (_selectedVoucher != null && _totalDays > 0) {
      discountAmount = (totalRentPrice * (_selectedVoucher!.discountPercent / 100)).round();
    }
    
    int grandTotal = totalRentPrice - discountAmount + _deposit;

    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pilih Jadwal",
          style: TextStyle(
            fontFamily: 'Georgia', // Menyelaraskan display font dengan brand
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ATMOSPHERIC LAVENDER ORB (Adjusted for white canvas)
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentLavender.withOpacity(0.25),
                    accentLavender.withOpacity(0.05),
                    bgColor,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STEP TITLE
                Text(
                  "STEP 1 OF 3 • SCHEDULING",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // RINGKASAN PRODUK
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: hairlineStrong),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.costumeData['image']?.startsWith('http://') == true ||
                                widget.costumeData['image']?.startsWith('https://') == true
                            ? Image.network(
                                widget.costumeData['image'],
                                height: 60,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 60,
                                  width: 50,
                                  color: bgColor,
                                  child: Icon(Icons.broken_image,
                                      color: textSecondary),
                                ),
                              )
                            : Image.asset(
                                widget.costumeData['image'],
                                height: 60,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 60,
                                  width: 50,
                                  color: bgColor,
                                  child: Icon(Icons.broken_image,
                                      color: textSecondary),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.costumeData['title'],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${currencyFormat.format(pricePer3Days)} / 3 Hari",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: accentMint,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // CALENDAR HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pilih Tanggal Sewa",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: textPrimary,
                      ),
                    ),
                    if (_isLoadingDates)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: textSecondary,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() => _isLoadingDates = true);
                          _loadBookedDatesFromFirestore();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.sync_rounded, size: 14, color: accentMint),
                            const SizedBox(width: 4),
                            Text(
                              "Synced",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentMint,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // TABLE CALENDAR (MODIFIED FOR LIGHT THEME)
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(color: hairlineStrong),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      onRangeSelected: _onRangeSelected,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: textPrimary),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: textPrimary),
                      ),
                      calendarStyle: CalendarStyle(
                        // Selected Range Colors (Light Minimalist look)
                        rangeHighlightColor: textPrimary.withOpacity(0.05),
                        rangeStartDecoration: BoxDecoration(
                          color:
                              textPrimary, // Hitam pekat sebagai penanda start
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: textPrimary, // Hitam pekat sebagai penanda end
                          shape: BoxShape.circle,
                        ),
                        withinRangeTextStyle: TextStyle(
                            color: textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500),
                        rangeStartTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter'),
                        rangeEndTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter'),

                        // Today Style
                        todayDecoration: BoxDecoration(
                          color: hairlineStrong,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                            color: textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold),

                        // Default Text Style (Hitam semua)
                        defaultTextStyle:
                            TextStyle(color: textPrimary, fontFamily: 'Inter'),
                        weekendTextStyle: TextStyle(
                            color: textPrimary, // Diubah menjadi warna hitam sesuai request
                            fontFamily: 'Inter'), 

                        // Disabled / Booked Dates Style
                        disabledDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        disabledTextStyle: const TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontFamily: 'Inter',
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        disabledBuilder: (context, day, focusedDay) {
                          if (_isDayBooked(day)) {
                            // Tanggal yang sudah di-sewa tampil berwarna MERAH dengan coretan
                            return Center(
                              child: Text(
                                "${day.day}",
                                style: const TextStyle(
                                  color: Color(0xFFEF4444), // Merah
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            );
                          } else {
                            // Tanggal mati biasa (seperti tanggal lampau) tampil warna abu-abu
                            return Center(
                              child: Text(
                                "${day.day}",
                                style: const TextStyle(
                                  color: Color(0xFFD1D5DB), // Abu-abu
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

                // LEGEND KALENDER
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(surfaceColor, "Tersedia",
                        hasBorder: true, borderColor: hairlineStrong),
                    _buildLegendItem(const Color(0xFFFCA5A5), "Rented (Coret)"),
                    _buildLegendItem(textPrimary, "Pilihanmu",
                        textColor: textPrimary),
                  ],
                ),

                const SizedBox(height: 32),

                // ALAMAT PENGIRIMAN
                Text(
                  "Alamat Pengiriman",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _fillFromProfile,
                    child: const Text('Isi dari Profil'),
                  ),
                ),
                const SizedBox(height: 4),
                Form(
                  key: _addressFormKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: hairlineStrong),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _recipientController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Penerima',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan nama penerima'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'No. Telepon',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan nomor telepon'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Jalan / Alamat',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan alamat lengkap'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration:
                                    const InputDecoration(labelText: 'Kota/Kabupaten'),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Kota dibutuhkan'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _postalController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Kode Pos'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(labelText: 'Provinsi'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                              labelText: 'Catatan Pengiriman (opsional)'),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // helper to prefill from profile

                // VOUCHER SELECTION
                GestureDetector(
                  onTap: _showVoucherSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentMint.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: accentMint.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_rounded, color: accentMint, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedVoucher == null
                                ? "Makin hemat pakai promo"
                                : "Promo: ${_selectedVoucher!.code} dipakai!",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: _selectedVoucher == null ? FontWeight.normal : FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),

                // RINCIAN BIAYA
                Text(
                  "Rincian Pembayaran",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: hairlineStrong),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildCostRow("Biaya Sewa ($_totalDays Hari)",
                          currencyFormat.format(totalRentPrice)),
                      if (discountAmount > 0) ...[
                        const SizedBox(height: 12),
                        _buildCostRow("Diskon Promo (${_selectedVoucher!.code})",
                            "-${currencyFormat.format(discountAmount)}",
                            textColor: Colors.green),
                      ],
                      const SizedBox(height: 12),
                      _buildCostRow("Deposit (Uang Jaminan)",
                          currencyFormat.format(_deposit)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: hairlineStrong, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Pembayaran",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            currencyFormat.format(grandTotal),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height:
                        120), // Memberi ruang gulir agar tidak tertutup bottomSheet
              ],
            ),
          ),
        ],
      ),

      // BOTTOM SHEET (STICKY BUTTON)
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: hairlineStrong, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _rangeStart == null ? bgColor : textPrimary,
                foregroundColor: surfaceColor,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: _rangeStart == null
                  ? null
                  : () {
                      // Validasi alamat sebelum lanjut
                      if (!_addressFormKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Periksa kembali data alamat pengiriman.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final shippingAddress = {
                        'recipient': _recipientController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'street': _streetController.text.trim(),
                        'city': _cityController.text.trim(),
                        'postal': _postalController.text.trim(),
                        'province': _provinceController.text.trim(),
                        'notes': _notesController.text.trim(),
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            costumeData: widget.costumeData,
                            startDate: _rangeStart!,
                            endDate: _rangeEnd ?? _rangeStart!,
                            totalDays: _totalDays,
                            totalRentPrice: totalRentPrice,
                            deposit: _deposit,
                            discountAmount: discountAmount,
                            voucherCode: _selectedVoucher?.code,
                            grandTotal: grandTotal,
                            shippingAddress: shippingAddress,
                          ),
                        ),
                      );
                    },
              child: Text(
                "Lanjut Pembayaran",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _rangeStart == null ? textSecondary : surfaceColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: textColor ?? textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor ?? textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool hasBorder = false, Color? borderColor, Color? textColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(color: borderColor ?? Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
