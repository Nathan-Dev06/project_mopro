import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _K {
  static const bg = Color(0xFFF9F9F9);
  static const black = Color(0xFF111111);
  static const grey500 = Color(0xFF888888);
  static const grey200 = Color(0xFFE8E8E8);
  static const grey100 = Color(0xFFF5F5F5);
  static const green = Color(0xFF28A745);
  static const red = Color(0xFFDC3545);
}

// =============================================
// DEPOSIT BALANCE PAGE
// =============================================
class DepositBalancePage extends StatelessWidget {
  const DepositBalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We would normally fetch this from Provider/Firestore.
    // Assuming 150000 for mockup history display (real balance is fetched in profile_page)
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    const depositBalance = 150000;

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                  colors: [Color(0xFF111111), Color(0xFF333333)],
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
                      Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
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
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Withdraw request submitted.")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _K.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Withdraw to Bank",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            // History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(color: _K.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionTile(
              title: "Deposit Refund - Rental #8912",
              date: "12 Jun 2026",
              amount: 50000,
              isAddition: true,
            ),
            _buildTransactionTile(
              title: "Deposit Refund - Rental #8804",
              date: "05 Jun 2026",
              amount: 100000,
              isAddition: true,
            ),
            _buildTransactionTile(
              title: "Withdrawal to BCA",
              date: "28 May 2026",
              amount: 250000,
              isAddition: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile({required String title, required String date, required int amount, required bool isAddition}) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _K.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAddition ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAddition ? Icons.call_received_rounded : Icons.call_made_rounded,
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
                  date,
                  style: const TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${isAddition ? '+' : '-'} ${format.format(amount)}",
            style: TextStyle(
              color: isAddition ? _K.green : _K.black,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// COSMO POINTS PAGE
// =============================================
class CosmoPointsPage extends StatelessWidget {
  const CosmoPointsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cosmoPoints = 450;

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
          "Cosmo Points",
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Points Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Your Total Points",
                        style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "$cosmoPoints KP",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redeeming points is coming soon.")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A11CB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Redeem for Voucher",
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            // History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Points History",
                    style: TextStyle(color: _K.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPointTile(
              title: "Rental Completed",
              date: "12 Jun 2026",
              points: 120,
              isAddition: true,
            ),
            _buildPointTile(
              title: "Daily Login Bonus",
              date: "12 Jun 2026",
              points: 5,
              isAddition: true,
            ),
            _buildPointTile(
              title: "Redeemed 10% Off Voucher",
              date: "20 May 2026",
              points: 300,
              isAddition: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPointTile({required String title, required String date, required int points, required bool isAddition}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _K.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAddition ? const Color(0xFFFFF8E1) : _K.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAddition ? Icons.star_rounded : Icons.local_activity_rounded,
              color: isAddition ? Colors.amber : _K.grey500,
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
                  date,
                  style: const TextStyle(color: _K.grey500, fontFamily: 'Inter', fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${isAddition ? '+' : '-'}$points KP",
            style: TextStyle(
              color: isAddition ? const Color(0xFFE65100) : _K.black,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
