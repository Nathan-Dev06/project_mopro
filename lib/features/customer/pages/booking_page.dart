import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:project_mopro/features/customer/pages/payment_page.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> costumeData;
  final String selectedSize;

  const BookingPage({
    Key? key,
    required this.costumeData,
    required this.selectedSize,
  }) : super(key: key);

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

  // Shipping Method
  String _shippingMethod = 'Instant Delivery (Gojek/Grab)';

  // Shipping address
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

        // Expand the range into individual days + 2 Days Maintenance
        DateTime current = DateTime(start.year, start.month, start.day);
        DateTime effectiveEnd = DateTime(end.year, end.month, end.day);
        
        final now = DateTime.now();
        final todayNormalized = DateTime(now.year, now.month, now.day);
        
        // If the costume is still out (not Completed) and today is past the return date,
        // it means the item is late or still being checked. Block up to today!
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

    // Otomatis hitung masa sewa 3 hari (Hari 1, Hari 2, Hari 3)
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
                        v.discountType == 'Nominal Fixed' 
                            ? '-Rp ${v.discountPercent}'
                            : '-${v.discountPercent}%',
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
      if (_selectedVoucher!.discountType == 'Nominal Fixed') {
        discountAmount = _selectedVoucher!.discountPercent;
      } else {
        discountAmount = (totalRentPrice * (_selectedVoucher!.discountPercent / 100)).round();
      }
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
                            const SizedBox(height: 4),
                            Text(
                              "Ukuran: ${widget.selectedSize}",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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

                // DISCLAIMER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // Light yellow bg
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFD97706)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: const Text(
                          "Pilih Tanggal Pengiriman (H-1 sebelum Event). Sistem otomatis mengatur durasi sewa selama 3 Hari.",
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
                const SizedBox(height: 16),

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
                      rangeSelectionMode: RangeSelectionMode.toggledOff,
                      onDaySelected: _onDaySelected,
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
                        withinRangeDecoration: BoxDecoration(
                          color: textPrimary,
                          shape: BoxShape.circle,
                        ),
                        withinRangeTextStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold),
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
                            color: textPrimary, // Changed to black as per request
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
                            // Booked dates shown in RED with strikethrough
                            return Center(
                              child: Text(
                                "${day.day}",
                                style: const TextStyle(
                                  color: Color(0xFFEF4444), // Red
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            );
                          } else {
                            // Regular past dates shown in grey
                            return Center(
                              child: Text(
                                "${day.day}",
                                style: const TextStyle(
                                  color: Color(0xFFD1D5DB), // Grey
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

                // CALENDAR LEGEND
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(surfaceColor, "Available",
                        hasBorder: true, borderColor: hairlineStrong),
                    _buildLegendItem(const Color(0xFFFCA5A5), "Booked"),
                    _buildLegendItem(textPrimary, "Your Pick",
                        textColor: textPrimary),
                  ],
                ),

                const SizedBox(height: 32),

                // SHIPPING METHOD
                Text(
                  "Shipping Method",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: hairlineStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _shippingMethod,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrimary),
                      dropdownColor: surfaceColor,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _shippingMethod = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'Instant Delivery (Gojek/Grab)',
                        'Self Pickup at Store'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_shippingMethod == 'Instant Delivery (Gojek/Grab)')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "*Instant delivery covers the Greater Jakarta area (shipping paid by renter at destination).",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "*Please come directly to our location (Cosvoria HQ, South Jakarta) one day before the event to pick up your costume.",
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textSecondary),
                    ),
                  ),

                if (_shippingMethod == 'Instant Delivery (Gojek/Grab)') ...[
                // SHIPPING ADDRESS
                Text(
                  "Shipping Address",
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
                    child: const Text('Fill from Profile'),
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
                            labelText: 'Recipient Name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter recipient name'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter phone number'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Street / Address',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter full address'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration:
                                    const InputDecoration(labelText: 'City/Regency'),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'City required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _postalController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Postal Code'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(labelText: 'Province'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                              labelText: 'Shipping Notes (optional)'),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ],

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
                                ? "Save more with a promo code"
                                : "Promo: ${_selectedVoucher!.code} applied!",
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

                // PAYMENT DETAILS
                Text(
                  "Payment Summary",
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
                      _buildCostRow("Rental Fee ($_totalDays Days)",
                          currencyFormat.format(totalRentPrice)),
                      if (discountAmount > 0) ...[
                        const SizedBox(height: 12),
                        _buildCostRow("Promo Discount (${_selectedVoucher!.code})",
                            "-${currencyFormat.format(discountAmount)}",
                            textColor: Colors.green),
                      ],
                      const SizedBox(height: 12),
                      _buildCostRow("Deposit (Security Deposit)",
                          currencyFormat.format(_deposit)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: hairlineStrong, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Payment",
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
                        120), // Extra scroll space to prevent overlap with bottomSheet
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
                      Map<String, String> shippingAddress;

                      if (_shippingMethod == 'Instant Delivery (Gojek/Grab)') {
                        if (!_addressFormKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please check the shipping address details.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Check Jabodetabek radius loosely
                        final city = _cityController.text.trim().toLowerCase();
                        if (!city.contains('jakarta') && !city.contains('bogor') && !city.contains('depok') && !city.contains('tangerang') && !city.contains('bekasi')) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sorry, instant delivery currently only covers the Greater Jakarta area.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        shippingAddress = {
                          'recipient': _recipientController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'street': _streetController.text.trim(),
                          'city': _cityController.text.trim(),
                          'postal': _postalController.text.trim(),
                          'province': _provinceController.text.trim(),
                          'notes': _notesController.text.trim(),
                        };
                      } else {
                        // Self Pickup
                        shippingAddress = {
                          'recipient': FirebaseAuth.instance.currentUser?.displayName ?? 'Customer (Self Pickup)',
                          'phone': '0812-3456-7890',
                          'street': 'Cosvoria HQ (Jl. Kemang Raya No. 10, Bangka)',
                          'city': 'Jakarta Selatan',
                          'postal': '12730',
                          'province': 'DKI Jakarta',
                          'notes': 'Method: Self Pickup',
                        };
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            costumeData: {
                              ...widget.costumeData,
                              'size': widget.selectedSize,
                            },
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
                "Proceed to Payment",
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
