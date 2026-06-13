import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'receipt_page.dart';
import 'voucher_manager.dart';
import 'rental_manager.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> costumeData;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int totalRentPrice;
  final int deposit;
  final int discountAmount;
  final String? voucherCode;
  final int grandTotal;
  final Map<String, String>? shippingAddress;

  const PaymentPage({
    Key? key,
    required this.costumeData,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalRentPrice,
    required this.deposit,
    this.discountAmount = 0,
    this.voucherCode,
    required this.grandTotal,
    this.shippingAddress,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // ELEVENLABS LIGHT EDITORIAL COLOR SYSTEM
  final Color canvasLight = const Color(0xFFF5F5F5);
  final Color surfaceLightElevated = const Color(0xFFFFFFFF);
  final Color hairlineStrong = const Color(0xFFE7E5E4);
  final Color inkTextPrimary = const Color(0xFF0C0A09);
  final Color inkTextSecondary = const Color(0xFF4E4E4E);
  final Color textMuted = const Color(0xFF78716C);
  final Color accentMint = const Color(0xFFA7E5D3);
  final Color accentLavender = const Color(0xFFC8B8E0);
  final Color accentPeach = const Color(0xFFF4C5A8);

  String? _selectedMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "id": "bca",
      "name": "BCA Virtual Account",
      "subtitle": "Transfer otomatis 24 jam",
      "icon": Icons.account_balance_wallet_outlined,
    },
    {
      "id": "gopay",
      "name": "GoPay",
      "subtitle": "Bayar instan pakai aplikasi Gojek",
      "icon": Icons.phone_android_rounded,
    },
    {
      "id": "shopeepay",
      "name": "ShopeePay",
      "subtitle": "Bayar instan pakai aplikasi Shopee",
      "icon": Icons.shopping_bag_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: canvasLight,
      appBar: AppBar(
        backgroundColor: canvasLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: inkTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pembayaran",
          style: TextStyle(
            fontFamily: 'EB Garamond',
            fontSize: 22,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: inkTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. ATMOSPHERIC ORB (LAVENDER GLOW)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentLavender.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. ATMOSPHERIC ORB (PEACH GLOW)
          Positioned(
            bottom: 100,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentPeach.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. MAIN CONTENT
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // SUDAH DIPERBAIKI
              children: [
                // STEP TITLE
                Text(
                  "STEP 2 OF 3 · CHECKOUT",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 16),

                // RINGKASAN KOSTUM (PUTIH BERSIH)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceLightElevated,
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
                        child: Image.asset(
                          widget.costumeData['image'],
                          height: 70,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 70,
                            width: 60,
                            color: hairlineStrong,
                            child: Icon(Icons.broken_image, color: textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // SUDAH DIPERBAIKI
                          children: [
                            Text(
                              widget.costumeData['title'],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: inkTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.costumeData['series'],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: inkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${dateFormat.format(widget.startDate)} - ${dateFormat.format(widget.endDate)} (${widget.totalDays} Hari)",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: inkTextPrimary.withOpacity(0.8),
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

                // ALAMAT PENGIRIMAN (jika tersedia)
                if (widget.shippingAddress != null) ...[
                  Text(
                    "Alamat Pengiriman",
                    style: TextStyle(
                      fontFamily: 'EB Garamond',
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: inkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceLightElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hairlineStrong),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shippingAddress!['recipient'] ?? '-',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: inkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.shippingAddress!['phone'] ?? '-'} · ${widget.shippingAddress!['postal'] ?? ''}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: inkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.shippingAddress!['street'] ?? '-'}, ${widget.shippingAddress!['city'] ?? '-'}, ${widget.shippingAddress!['province'] ?? '-'}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: inkTextPrimary,
                          ),
                        ),
                        if ((widget.shippingAddress!['notes'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Catatan: ${widget.shippingAddress!['notes']}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: inkTextSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // RINCIAN TAGIHAN
                Text(
                  "Rincian Pembayaran",
                  style: TextStyle(
                    fontFamily: 'EB Garamond',
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    letterSpacing: -0.2,
                    color: inkTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceLightElevated,
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
                      _buildBillingRow(
                        "Biaya Sewa (${widget.totalDays} Hari)",
                        currencyFormat.format(widget.totalRentPrice),
                      ),
                      if (widget.discountAmount > 0) ...[
                        const SizedBox(height: 12),
                        _buildBillingRow(
                          "Diskon Promo (${widget.voucherCode})",
                          "-${currencyFormat.format(widget.discountAmount)}",
                          textColor: const Color(0xFF16A34A),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildBillingRow(
                        "Uang Jaminan (Refundable Deposit)",
                        currencyFormat.format(widget.deposit),
                      ),
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
                              color: inkTextPrimary,
                            ),
                          ),
                          Text(
                            currencyFormat.format(widget.grandTotal),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: inkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // METODE PEMBAYARAN
                Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontFamily: 'EB Garamond',
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    letterSpacing: -0.2,
                    color: inkTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedMethod == method['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMethod = method['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceLightElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? inkTextPrimary : hairlineStrong,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                method['icon'] as IconData,
                                color: isSelected
                                    ? inkTextPrimary
                                    : inkTextSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // SUDAH DIPERBAIKI
                                  children: [
                                    Text(
                                      method['name'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: inkTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      method['subtitle'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected ? inkTextPrimary : textMuted,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? inkTextPrimary
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 120), // Spacer for bottom sheet
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceLightElevated,
          border: Border(top: BorderSide(color: hairlineStrong)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedMethod == null ? hairlineStrong : inkTextPrimary,
                foregroundColor: surfaceLightElevated,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: _selectedMethod == null
                  ? null
                  : () {
                      if (widget.voucherCode != null) {
                        VoucherManager.instance.useVoucher(widget.voucherCode!);
                      }
                      
                      final generatedTrxId =
                          "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

                      // Add to RentalManager
                      RentalManager.instance.addRental(
                        Rental(
                          transactionId: generatedTrxId,
                          costumeName: widget.costumeData['title'] ?? 'Unknown Costume',
                          costumeSeries: widget.costumeData['series'] ?? 'Unknown Series',
                          size: 'L', // Or passed from booking page
                          imagePath: widget.costumeData['image'] ?? 'assets/images/default.jpg',
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          status: 'Renting',
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptPage(
                            costumeData: widget.costumeData,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            totalDays: widget.totalDays,
                            discountAmount: widget.discountAmount,
                            voucherCode: widget.voucherCode,
                            grandTotal: widget.grandTotal,
                            paymentMethod: _selectedMethod!,
                            transactionId: generatedTrxId,
                            shippingAddress: widget.shippingAddress,
                          ),
                        ),
                      );
                    },
              child: Text(
                "Bayar Sekarang",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _selectedMethod == null
                      ? textMuted
                      : surfaceLightElevated,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: textColor ?? inkTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor ?? inkTextPrimary,
          ),
        ),
      ],
    );
  }
}
