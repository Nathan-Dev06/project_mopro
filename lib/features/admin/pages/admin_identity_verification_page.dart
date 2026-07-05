
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class AdminIdentityVerificationPage extends StatefulWidget {
  const AdminIdentityVerificationPage({Key? key}) : super(key: key);

  @override
  State<AdminIdentityVerificationPage> createState() => _AdminIdentityVerificationPageState();
}

class _AdminIdentityVerificationPageState extends State<AdminIdentityVerificationPage> {

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _cardBg = Color(0xFFF9FAFB);
  static const Color _black = Color(0xFF111111);
  static const Color _grey500 = Color(0xFF888888);
  static const Color _grey200 = Color(0xFFE8E8E8);

  Future<void> _handleApprove(String id, String name) async {
    await FirebaseSyncService.updateUserVerification(
      userId: id,
      verificationStatus: 'approved',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Identity for $name approved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleReject(String id, String name) async {
    await FirebaseSyncService.updateUserVerification(
      userId: id,
      verificationStatus: 'rejected',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Identity for $name has been rejected.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildMockKtpCard(String name, String ktpNo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'REPUBLIK INDONESIA',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'KARTU TANDA PENDUDUK / IDENTITY CARD',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NIK: $ktpNo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nama: $name',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Inter',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Status: WNI / CITIZEN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Inter',
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white70, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Identity Verification",
          style: TextStyle(
            color: _black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Approve or reject customer identity cards (KTP) before they can rent costumes.",
                style: TextStyle(
                  color: _grey500,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseSyncService.usersCollection()
                    .where('verificationStatus', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load verification data.',
                        style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final requests = snapshot.data!.docs;

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.gpp_good_outlined, size: 64, color: _grey200),
                          SizedBox(height: 16),
                          Text(
                            "All identities have been validated!",
                            style: TextStyle(color: _grey500, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final item = requests[index].data();
                      final userId = requests[index].id;
                      final name = (item['name'] ?? 'Unknown').toString();
                      final email = (item['email'] ?? '').toString();
                      final ktp = (item['ktpNumber'] ?? item['ktp'] ?? '-').toString();
                      final date = (item['verificationRequestedAtLabel'] ?? 'Awaiting review').toString();
                      final ktpImageBase64 = item['ktpImageBase64']?.toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _grey200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.badge_outlined,
                                    color: _black,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: _black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          color: _grey500,
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "ID Card No: $ktp",
                                        style: const TextStyle(
                                          color: _black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "• $date",
                                        style: const TextStyle(
                                          color: _grey500,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // KTP Card Illustration Preview
                            if (ktpImageBase64 != null && ktpImageBase64.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              const Text(
                                'Submitted KTP Details',
                                style: TextStyle(
                                  color: _black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  // Full screen image preview
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(16),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          InteractiveViewer(
                                            child: Container(
                                              width: double.infinity,
                                              constraints: const BoxConstraints(maxHeight: 320),
                                              child: _buildMockKtpCard(name, ktp),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8, right: 8,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.black.withOpacity(0.5),
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildMockKtpCard(name, ktp),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Tap to zoom details',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: _grey500,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton(
                                      onPressed: () => _handleReject(userId, name),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Reject",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () => _handleApprove(userId, name),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _black,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Approve",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}