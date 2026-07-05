import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';
import 'package:project_mopro/features/customer/pages/receipt_page.dart';

class PendingPaymentPage extends StatefulWidget {
  final Rental rental;

  const PendingPaymentPage({Key? key, required this.rental}) : super(key: key);

  @override
  State<PendingPaymentPage> createState() => _PendingPaymentPageState();
}

class _PendingPaymentPageState extends State<PendingPaymentPage> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 23, minutes: 59, seconds: 59);

  // Design Tokens
  final Color _bg = const Color(0xFFF9FAFB);
  final Color _cardBg = Colors.white;
  final Color _black = const Color(0xFF111111);
  final Color _grey700 = const Color(0xFF374151);
  final Color _grey500 = const Color(0xFF6B7280);
  final Color _grey200 = const Color(0xFFE5E7EB);
  final Color _orange = const Color(0xFFEE4D2D); // Shopee Orange

  @override
  void initState() {
    super.initState();
    // Simulate a countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    final grandTotal = widget.rental.grandTotal ?? 200000;
    final totalRentPrice = widget.rental.totalRentPrice ?? 150000;
    final deposit = widget.rental.deposit ?? 50000;
    final discountAmount = widget.rental.discountAmount ?? 0;

    final recipientName = widget.rental.recipientName ?? widget.rental.customerName;
    final recipientAddress = widget.rental.street != null && widget.rental.street!.isNotEmpty
        ? "${widget.rental.street}, ${widget.rental.city ?? ''}, ${widget.rental.province ?? ''}"
        : "Jl. Meruya Selatan No. 12, Kembangan, Jakarta Barat";

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Payment Details",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── COUNTDOWN TIMER CARD ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Light orange background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: _orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Deadline",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF9A3412),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Please pay within ${_formatDuration(_remainingTime)}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF7C2D12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── VIRTUAL ACCOUNT CARD ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "BCA Virtual Account",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Image.asset(
                        "assets/images/default.jpg", // Fallback, or simple placeholder
                        width: 45,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "BCA",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  const Text(
                    "Virtual Account Number",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SelectableText(
                        "800108123456789",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: "800108123456789"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("VA Number copied to clipboard!"),
                              backgroundColor: Colors.black,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _orange,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Copy",
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── COSTUME SUMMARY ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rented Item",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _grey200),
                          image: DecorationImage(
                            image: AssetImage(widget.rental.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rental.costumeName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.rental.costumeSeries} • Size ${widget.rental.size}",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: _grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Rental Period", "${dateFormat.format(widget.rental.startDate)} – ${dateFormat.format(widget.rental.endDate)}"),
                  _buildDetailRow("Delivery Address", "$recipientName\n$recipientAddress"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── PAYMENT DETAILS ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bill Details",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildDetailRow("Rental Subtotal", currencyFormat.format(totalRentPrice)),
                  _buildDetailRow("Refundable Deposit", currencyFormat.format(deposit)),
                  if (discountAmount > 0)
                    _buildDetailRow("Voucher Discount", "-${currencyFormat.format(discountAmount)}", valueColor: Colors.green),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Payment",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        currencyFormat.format(grandTotal),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── ACTIONS ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Complete the payment successfully
                  RentalManager.instance.updateRentalStatus(widget.rental.transactionId, "Packaging");

                  // Replace screen with ReceiptPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptPage(
                        costumeData: {
                          'title': widget.rental.costumeName,
                          'series': widget.rental.costumeSeries,
                          'image': widget.rental.imagePath,
                          'size': widget.rental.size,
                        },
                        startDate: widget.rental.startDate,
                        endDate: widget.rental.endDate,
                        totalDays: widget.rental.endDate.difference(widget.rental.startDate).inDays,
                        discountAmount: discountAmount,
                        voucherCode: widget.rental.voucherCode,
                        grandTotal: grandTotal,
                        paymentMethod: "BCA Virtual Account",
                        transactionId: widget.rental.transactionId,
                        shippingAddress: {
                          'recipient': recipientName,
                          'phone': widget.rental.phone ?? '',
                          'street': widget.rental.street ?? '',
                          'city': widget.rental.city ?? '',
                          'province': widget.rental.province ?? '',
                          'postal': widget.rental.postal ?? '',
                        },
                      ),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment successful! Costume is now being packaged.", style: TextStyle(fontFamily: 'Inter')),
                      backgroundColor: Color(0xFF16A34A),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _grey500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: valueColor ?? _grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
