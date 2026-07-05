import 'dart:math';
import 'package:flutter/material.dart';
import 'package:project_mopro/core/managers/rental_manager.dart';

class ManageShippingPage extends StatefulWidget {
  final Rental rental;

  const ManageShippingPage({Key? key, required this.rental}) : super(key: key);

  @override
  State<ManageShippingPage> createState() => _ManageShippingPageState();
}

class _ManageShippingPageState extends State<ManageShippingPage> {
  late String _randomReceiptNumber;

  @override
  void initState() {
    super.initState();
    // Generate a random Shopee Express receipt number
    final random = Random();
    final randomDigits = 10000000000 + random.nextInt(900000000);
    _randomReceiptNumber = "SPXID$randomDigits";
  }

  @override
  Widget build(BuildContext context) {
    // Fallback address values if address is empty
    final recipientName = (widget.rental.recipientName != null && widget.rental.recipientName!.isNotEmpty)
        ? widget.rental.recipientName!
        : widget.rental.customerName;

    final recipientPhone = (widget.rental.phone != null && widget.rental.phone!.isNotEmpty)
        ? widget.rental.phone!
        : "+62 812-9876-5432";

    final recipientAddress = (widget.rental.street != null && widget.rental.street!.isNotEmpty)
        ? "${widget.rental.street}, ${widget.rental.city ?? ''}, ${widget.rental.province ?? ''} ${widget.rental.postal ?? ''}"
        : "Jl. Meruya Selatan No. 12, Kembangan, Jakarta Barat, 11650";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Arrange Shipment",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── SHOPEE EXPRESS COURIER LABEL ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label Header (Shopee Orange theme)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEE4D2D), // Shopee Orange
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.local_shipping_rounded,
                                color: Color(0xFFEE4D2D),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "SPX Express",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "STANDARD",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barcode Mockup
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Barcode visual container
                        Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildBarcodeLines(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _randomReceiptNumber,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 3,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  // Sender & Receiver Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient info
                        _buildLabelRow(
                          icon: Icons.person_pin_circle_rounded,
                          title: "Recipient",
                          content: "$recipientName\n$recipientPhone\n$recipientAddress",
                        ),
                        const SizedBox(height: 20),
                        // Sender info
                        _buildLabelRow(
                          icon: Icons.store_mall_directory_rounded,
                          title: "Sender",
                          content: "Cosvoria Studio\n+62 821-3456-7890\nJl. Meruya Selatan No. 12, Kembangan, Jakarta Barat",
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  // Product Details (Costume details & thumbnail)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            image: DecorationImage(
                              image: AssetImage(widget.rental.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Description
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
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Qty: 1",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  RentalManager.instance.updateRentalStatus(
                    widget.rental.transactionId,
                    "Shipped",
                    receiptNumber: _randomReceiptNumber,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Order successfully shipped via Shopee Express! Tracking ID: $_randomReceiptNumber",
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE4D2D), // Shopee Orange
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Ship Order",
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

  // Generate vertical container stripes to mimic a real barcode
  List<Widget> _buildBarcodeLines() {
    final List<double> stripeWidths = [
      1.5, 3.0, 1.5, 1.5, 4.0, 1.5, 3.0, 1.5, 4.0, 1.5,
      1.5, 3.0, 1.5, 1.5, 4.0, 1.5, 3.0, 1.5, 4.0, 1.5,
      1.5, 3.0, 1.5, 1.5, 4.0, 1.5, 3.0, 1.5, 4.0, 1.5
    ];
    return stripeWidths.map((w) {
      return Container(
        width: w,
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        color: Colors.black,
      );
    }).toList();
  }

  Widget _buildLabelRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF4B5563), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
