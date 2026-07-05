import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _K {
  static const bg = Color(0xFFF9F9F9);
  static const black = Color(0xFF111111);
  static const grey500 = Color(0xFF888888);
  static const grey200 = Color(0xFFE8E8E8);
  static const green = Color(0xFF28A745);
  static const red = Color(0xFFDC3545);
  static const blue = Color(0xFF2575FC);
}

// =============================================
// DEPOSIT BALANCE PAGE
// =============================================
class DepositBalancePage extends StatelessWidget {
  const DepositBalancePage({Key? key}) : super(key: key);

  void _showWithdrawModal(BuildContext context, int currentBalance, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WithdrawModal(
        currentBalance: currentBalance,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _K.bg,
      appBar: AppBar(
        backgroundColor: _K.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _K.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Deposit Balance",
          style: TextStyle(
            color: _K.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final depositBalance = (data?['deposit_balance'] ?? 0).toInt();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Balance Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF212121), Color(0xFF424242)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Available Balance",
                                      style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  formatCurrency.format(depositBalance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (depositBalance < 20000) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text("Minimal penarikan adalah Rp 20.000"),
                                          backgroundColor: _K.red,
                                        ));
                                        return;
                                      }
                                      _showWithdrawModal(context, depositBalance, user.uid);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: _K.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text(
                                      "Withdraw to Bank / E-Wallet",
                                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // History Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Recent Transactions",
                                  style: TextStyle(color: _K.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // History List using StreamBuilder inside Sliver
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('wallet_transactions')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, txSnapshot) {
                        if (txSnapshot.connectionState == ConnectionState.waiting) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        if (!txSnapshot.hasData || txSnapshot.data!.docs.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  "Belum ada riwayat transaksi.",
                                  style: TextStyle(color: _K.grey500, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final doc = txSnapshot.data!.docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return _TransactionTile(data: data);
                            },
                            childCount: txSnapshot.data!.docs.length,
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionTile({Key? key, required this.data}) : super(key: key);

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TransactionDetailModal(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final title = data['title'] ?? 'Unknown Transaction';
    final amount = (data['amount'] ?? 0).toInt();
    final type = data['type'] ?? 'refund';
    final isAddition = type == 'refund';
    final deductionAmount = (data['deductionAmount'] ?? 0).toInt();
    final deductionReason = data['deductionReason'] ?? '';
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    
    String dateStr = "";
    if (timestamp != null) {
      dateStr = DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _K.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAddition ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAddition ? Icons.download_rounded : Icons.upload_rounded,
                    color: isAddition ? _K.green : _K.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: _K.black, fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 12),
                      ),
                      if (isAddition && deductionAmount > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFF856404), size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Potongan ${format.format(deductionAmount)}: $deductionReason",
                                  style: const TextStyle(color: Color(0xFF856404), fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isAddition ? '+' : '-'} ${format.format(amount)}",
                      style: TextStyle(
                        color: isAddition ? _K.green : _K.black,
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Text("Detail", style: TextStyle(color: _K.blue, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right_rounded, color: _K.blue, size: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailModal extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionDetailModal({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final title = data['title'] ?? 'Unknown Transaction';
    final amount = (data['amount'] ?? 0).toInt();
    final type = data['type'] ?? 'refund';
    final isAddition = type == 'refund';
    final deductionAmount = (data['deductionAmount'] ?? 0).toInt();
    final deductionReason = data['deductionReason'] ?? '';
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    
    String dateStr = "";
    if (timestamp != null) {
      dateStr = DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }

    final totalDeposit = isAddition ? (amount + deductionAmount) : amount;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Detail Transaksi",
                style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: _K.black),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: _K.black),
              )
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAddition ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAddition ? Icons.download_rounded : Icons.upload_rounded,
                    color: isAddition ? _K.green : _K.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${isAddition ? '+' : '-'} ${format.format(amount)}",
                  style: TextStyle(
                    color: isAddition ? _K.green : _K.black,
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAddition ? "Dana Masuk (Refund)" : "Penarikan Berhasil",
                  style: const TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Rincian",
            style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: _K.black),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Keterangan", title),
          _buildDetailRow("Tanggal", dateStr),
          _buildDetailRow("Status", "Berhasil", isStatus: true),
          if (isAddition) ...[
            const Divider(height: 32, color: _K.grey200),
            _buildDetailRow("Total Uang Jaminan", format.format(totalDeposit)),
            _buildDetailRow("Denda / Potongan", "- ${format.format(deductionAmount)}", isDeduction: true),
            if (deductionAmount > 0)
              _buildDetailRow("Alasan Potongan", deductionReason),
          ],
          const SizedBox(height: 32),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false, bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isStatus ? _K.green : (isDeduction ? _K.red : _K.black),
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isStatus || isDeduction ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawModal extends StatefulWidget {
  final int currentBalance;
  final String userId;

  const _WithdrawModal({Key? key, required this.currentBalance, required this.userId}) : super(key: key);

  @override
  State<_WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<_WithdrawModal> {
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  String _selectedMethod = 'BCA';
  bool _isLoading = false;

  final List<String> _methods = [
    'BCA', 'Mandiri', 'BNI', 'BRI', 'BSI',
    'DANA', 'GoPay', 'OVO', 'ShopeePay',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (amountStr.isEmpty) return;
    
    final amount = int.parse(amountStr);
    final account = _accountController.text.trim();

    if (amount < 20000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Minimal penarikan adalah Rp 20.000")));
      return;
    }
    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saldo tidak mencukupi")));
      return;
    }
    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukkan nomor rekening / HP")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      
      // Kurangi saldo
      batch.update(userRef, {
        'deposit_balance': FieldValue.increment(-amount),
      });

      // Tambah transaksi
      final txRef = userRef.collection('wallet_transactions').doc();
      batch.set(txRef, {
        'title': 'Withdrawal ke $_selectedMethod ($account)',
        'type': 'withdrawal',
        'amount': amount,
        'deductionAmount': 0,
        'deductionReason': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Permintaan penarikan berhasil dikirim."),
          backgroundColor: _K.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Withdraw Funds",
                style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: _K.black),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: _K.black),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Pilih Metode Penarikan",
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: _K.grey200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMethod,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _K.black),
                items: _methods.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMethod = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Nomor Rekening / E-Wallet",
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
            decoration: InputDecoration(
              hintText: "Contoh: 081234567890",
              hintStyle: const TextStyle(color: _K.grey500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _K.grey200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _K.black)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nominal Penarikan",
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _K.black),
              ),
              Text(
                "Maks: ${formatCurrency.format(widget.currentBalance)}",
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: _K.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: "Rp ",
              prefixStyle: const TextStyle(color: _K.black, fontSize: 16, fontWeight: FontWeight.w600),
              hintText: "20000",
              hintStyle: const TextStyle(color: _K.grey500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _K.grey200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _K.black)),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: _K.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Tarik Dana", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          )
        ],
      ),
        ),
      ),
    );
  }
}
