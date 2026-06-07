import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // <--- Import package baru

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> costumeData;

  const BookingPage({Key? key, required this.costumeData}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // PALET WARNA CLEAN
  final Color bgColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF5F5F5);
  final Color textPrimary = Colors.black;
  final Color textSecondary = const Color(0xFF888888);

  // STATE UNTUK KALENDER
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _totalDays = 0;
  final int _deposit = 50000;

  // DUMMY TANGGAL YANG SUDAH DI-BOOKING (Warna Abu-abu)
  // Contoh: Besok dan lusa diset sebagai tanggal yang sudah terisi
  final List<DateTime> _bookedDates = [
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 7)),
    DateTime.now().add(const Duration(days: 8)),
  ];

  // Fungsi untuk ngecek apakah tanggal ada di list _bookedDates
  bool _isDayBooked(DateTime day) {
    for (DateTime bookedDay in _bookedDates) {
      if (isSameDay(day, bookedDay)) {
        return true;
      }
    }
    return false;
  }

  // Fungsi saat rentang tanggal dipilih
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;

      // Cek apakah di antara rentang yang dipilih ada tanggal yang bentrok (sudah di-booking)
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

        // Kalau bentrok, batalkan pilihan dan kasih notifikasi
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
          // Kalau aman, hitung durasi hari
          _totalDays = end.difference(start).inDays +
              1; // +1 supaya hari pertama dihitung
        }
      } else if (start != null && end == null) {
        _totalDays = 1;
      } else {
        _totalDays = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Parsing harga
    int pricePer3Days =
        int.parse(widget.costumeData['price'].replaceAll('.', ''));
    int pricePerDay = pricePer3Days ~/ 3;
    int totalRentPrice = pricePerDay * _totalDays;
    int grandTotal = totalRentPrice + _deposit;

    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pilih Jadwal",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RINGKASAN PRODUK
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.costumeData['image'],
                      height: 60,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.costumeData['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${currencyFormat.format(pricePer3Days)} / 3 Hari",
                          style: const TextStyle(
                              color: Color(0xFF00A651),
                              fontWeight: FontWeight.w800,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. INLINE CALENDAR (TABLE CALENDAR)
            const Text("Ketersediaan Kalender",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now()
                      .add(const Duration(days: 90)), // Max 3 bulan ke depan
                  focusedDay: _focusedDay,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  onRangeSelected: _onRangeSelected,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  calendarStyle: CalendarStyle(
                    // Warna saat rentang dipilih
                    rangeHighlightColor: Colors.black12,
                    rangeStartDecoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    rangeEndDecoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    withinRangeTextStyle: const TextStyle(color: Colors.black),

                    // Hari ini
                    todayDecoration: BoxDecoration(
                        color: Colors.grey[300], shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(color: Colors.black),

                    // Hari libur / weekend
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),

                    // Style untuk tanggal yang di-disable (sudah dibooking)
                    disabledDecoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle: TextStyle(
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough),
                  ),
                  // Logika men-disable tanggal
                  enabledDayPredicate: (day) {
                    // Kalau tanggalnya ada di list _bookedDates, return false (gabisa dipencet & jadi abu-abu)
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
                _buildLegendItem(Colors.white, "Tersedia", hasBorder: true),
                _buildLegendItem(Colors.grey[200]!, "Booked"),
                _buildLegendItem(Colors.black, "Pilihanmu",
                    textColor: Colors.white),
              ],
            ),

            const SizedBox(height: 35),

            // 3. RINCIAN BIAYA
            const Text("Rincian Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildCostRow("Biaya Sewa ($_totalDays Hari)",
                currencyFormat.format(totalRentPrice)),
            const SizedBox(height: 10),
            _buildCostRow(
                "Deposit (Uang Jaminan)", currencyFormat.format(_deposit)),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pembayaran",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  currencyFormat.format(grandTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 100), // Spasi bawah biar ga ketutup tombol
          ],
        ),
      ),

      // 4. TOMBOL BAYAR SEKARANG
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _rangeStart == null ? Colors.grey[400] : Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _rangeStart == null
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Melanjutkan ke Pembayaran..."),
                            backgroundColor: Colors.green),
                      );
                    },
              child: const Text(
                "Lanjut Pembayaran",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Bantuan Rincian Biaya
  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  // Widget Bantuan Legend Kalender
  Widget _buildLegendItem(Color color, String label,
      {bool hasBorder = false, Color textColor = Colors.black}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
