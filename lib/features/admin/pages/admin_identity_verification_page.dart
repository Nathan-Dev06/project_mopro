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