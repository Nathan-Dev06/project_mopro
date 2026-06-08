import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> costumeData;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int grandTotal;
  final String paymentMethod;
  final String transactionId;

  const ReceiptPage({
    Key? key,
    required this.costumeData,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.grandTotal,
    required this.paymentMethod,
    required this.transactionId,
  }) : super(key: key);

  // ELEVENLABS LIGHT SYSTEM COLORS (Diubah dari varian gelap)
  final Color canvasLight = const Color(0xFFF5F5F5);
  final Color surfaceLightElevated = const Color(0xFFFFFFFF);
  final Color hairlineStrong = const Color(0xFFE7E5E4);
  final Color hairlineDashed = const Color(0xFFD6D3D1);
  final Color inkTextPrimary = const Color(0xFF0C0A09);
  final Color inkTextSecondary = const Color(0xFF4E4E4E);
  final Color textMuted = const Color(0xFF777169);
  final Color accentMint = const Color(0xFFA7E5D3);
  final Color accentLavender = const Color(0xFFC8B8E0);
  final Color semanticSuccess = const Color(0xFF16A34A);

  // FUNGSI UNTUK MENAMPILKAN PREVIEW NOTA SIAP DOWNLOAD
  void _showReceiptPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ReceiptThermalSlip(
          transactionId: transactionId,
          costumeData: costumeData,
          startDate: startDate,
          endDate: endDate,
          totalDays: totalDays,
          grandTotal: grandTotal,
          paymentMethod: paymentMethod,
          canvasLight: canvasLight,
          inkTextPrimary: inkTextPrimary,
          hairlineStrong: hairlineStrong,
        );
      },
    );
  }

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
        automaticallyImplyLeading: false,
        title: Text(
          "Bukti Sewa",
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
          // ATMOSPHERIC MINT ORB (Disesuaikan opasitasnya untuk background terang)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentMint.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ATMOSPHERIC LAVENDER ORB
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
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

          // TICKET CONTENT
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: semanticSuccess.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: semanticSuccess.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(
                      Icons.checkroom_rounded,
                      color: semanticSuccess,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Transaksi Berhasil",
                    style: TextStyle(
                      fontFamily: 'EB Garamond',
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: inkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Pesanan cosplay Anda telah berhasil dijadwalkan.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: inkTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // TICKET CONTAINER (PUTIH BERSIH)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceLightElevated,
                      borderRadius: BorderRadius.circular(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ID TRANSAKSI",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transactionId,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: inkTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: semanticSuccess.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                      color: semanticSuccess.withOpacity(0.3)),
                                ),
                                child: Text(
                                  "LUNAS",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: semanticSuccess,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            30,
                            (index) => Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                height: 1.5,
                                color: index % 2 == 0
                                    ? hairlineDashed
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DETAIL PENYEWAAN",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                costumeData['title'] ?? '-',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: inkTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                costumeData['series'] ?? '-',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: inkTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTicketDetailRow("Periode Sewa",
                                  "${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}"),
                              _buildTicketDetailRow(
                                  "Durasi", "$totalDays Hari"),
                              _buildTicketDetailRow(
                                  "Metode Pembayaran", paymentMethod),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child:
                                    Divider(color: hairlineStrong, height: 1),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "TOTAL DIBAYAR",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: inkTextSecondary,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(grandTotal),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: inkTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // BUTTON UTAMA: Pemicu Bottom Sheet Struk Fisik
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inkTextPrimary,
                        foregroundColor: canvasLight,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () => _showReceiptPreview(context),
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text(
                        "Cetak Bukti",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: inkTextSecondary,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        "Kembali ke Beranda",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: inkTextSecondary)),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: inkTextPrimary)),
        ],
      ),
    );
  }
}

// WIDGET KERTAS NOTA STRUK FISIK INTERAKTIF (THERMAL SLIP)
class _ReceiptThermalSlip extends StatefulWidget {
  final String transactionId;
  final Map<String, dynamic> costumeData;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int grandTotal;
  final String paymentMethod;
  final Color canvasLight;
  final Color inkTextPrimary;
  final Color hairlineStrong;

  const _ReceiptThermalSlip({
    Key? key,
    required this.transactionId,
    required this.costumeData,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.grandTotal,
    required this.paymentMethod,
    required this.canvasLight,
    required this.inkTextPrimary,
    required this.hairlineStrong,
  }) : super(key: key);

  @override
  State<_ReceiptThermalSlip> createState() => _ReceiptThermalSlipState();
}

class _ReceiptThermalSlipState extends State<_ReceiptThermalSlip> {
  bool _isDownloading = false;

  void _simulateDownload() {
    setState(() {
      _isDownloading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Struk_${widget.transactionId}.png berhasil diunduh ke folder Downloads!",
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 20),
      decoration: BoxDecoration(
          color: widget
              .canvasLight, // Penyesuaian agar background modal bawah ikut berwarna terang
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.hairlineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Pratinjau Nota Cetak",
            style: TextStyle(
                color: widget.inkTextPrimary,
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // BLOK UTAMA: Kertas Struk Thermal Putih Bersih tetap dipertahankan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
              border: Border.all(color: widget.hairlineStrong),
            ),
            child: Column(
              children: [
                const Text(
                  "BUKTI TRANSAKSI RESMI",
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5),
                ),
                Text(
                  "ID: ${widget.transactionId}",
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                      25,
                      (index) => Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              height: 1,
                              color: index % 2 == 0
                                  ? Colors.grey[300]
                                  : Colors.transparent,
                            ),
                          )),
                ),
                const SizedBox(height: 12),
                _buildRowThermal(
                    "Item Penyewaan", widget.costumeData['title'] ?? '-'),
                _buildRowThermal(
                    "Seri / Karakter", widget.costumeData['series'] ?? '-'),
                _buildRowThermal("Durasi Sewa", "${widget.totalDays} Hari"),
                _buildRowThermal("Mulai", dateFormat.format(widget.startDate)),
                _buildRowThermal("Selesai", dateFormat.format(widget.endDate)),
                _buildRowThermal("Pembayaran", widget.paymentMethod),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                      25,
                      (index) => Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              height: 1,
                              color: index % 2 == 0
                                  ? Colors.grey[300]
                                  : Colors.transparent,
                            ),
                          )),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL LUNAS",
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      currencyFormat.format(widget.grandTotal),
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Terima kasih telah melakukan penyewaan!",
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // TOMBOL DOWNLOAD SEKARANG MENYESUAIKAN DENGAN SKEMA LIGHT MODE ELEGAN
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.inkTextPrimary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: _isDownloading ? null : _simulateDownload,
              child: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.file_download_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Unduh Struk",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowThermal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
