import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class Voucher {
  final String code;
  final String description;
  final int discountPercent; // e.g., 20 for 20%
  final String discountType;
  final int usageCount;
  bool isClaimed;
  bool isUsed;

  Voucher({
    required this.code,
    required this.description,
    required this.discountPercent,
    this.discountType = 'Persentase',
    this.usageCount = 0,
    this.isClaimed = false,
    this.isUsed = false,
  });
}

class VoucherManager {
  static final VoucherManager instance = VoucherManager._privateConstructor();

  final List<Voucher> _fallbackVouchers = [
    Voucher(
      code: 'EUPHORIA20',
      description: 'Get 20% OFF for your first rental!',
      discountPercent: 20,
    ),
    Voucher(
      code: 'COSPLAY10',
      description: 'Get 10% OFF all costumes',
      discountPercent: 10,
    ),
  ];

  final ValueNotifier<List<Voucher>> vouchersNotifier = ValueNotifier([
    Voucher(
      code: 'EUPHORIA20',
      description: 'Get 20% OFF for your first rental!',
      discountPercent: 20,
    ),
    Voucher(
      code: 'COSPLAY10',
      description: 'Get 10% OFF all costumes',
      discountPercent: 10,
    ),
  ]);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _voucherSubscription;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _userVoucherSubscription;

  final Map<String, Map<String, dynamic>> _userVoucherStates = {};
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _globalDocs = [];

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.tryParse(value?.toString() ?? '')?.toInt() ?? 0;
  }

  VoucherManager._privateConstructor() {
    _listenToFirestore();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userVoucherSubscription?.cancel();
      _userVoucherSubscription = null;
      _userVoucherStates.clear();

      if (user != null) {
        _userVoucherSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('vouchers')
            .snapshots()
            .listen((snapshot) {
          _userVoucherStates.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final code = doc.id.toUpperCase();
            _userVoucherStates[code] = data;
          }
          _updateVouchersNotifier();
        }, onError: (err) {
          debugPrint('User vouchers sync error: $err');
        });
      } else {
        _updateVouchersNotifier();
      }
    });
  }

  void _listenToFirestore() {
    _voucherSubscription ??=
        FirebaseSyncService.vouchersCollection().snapshots().listen(
      (snapshot) {
        _globalDocs = snapshot.docs;
        _updateVouchersNotifier();
      },
      onError: (error) {
        debugPrint('Voucher sync failed: $error');
      },
    );
  }

  void _updateVouchersNotifier() {
    if (_globalDocs.isEmpty) {
      vouchersNotifier.value = _fallbackVouchers.map((v) {
        final state = _userVoucherStates[v.code];
        return Voucher(
          code: v.code,
          description: v.description,
          discountPercent: v.discountPercent,
          discountType: v.discountType,
          usageCount: v.usageCount,
          isClaimed: state?['isClaimed'] == true,
          isUsed: state?['isUsed'] == true,
        );
      }).toList();
      return;
    }

    vouchersNotifier.value = _globalDocs.map((doc) {
      final data = doc.data();
      final code = (data['code'] ?? doc.id).toString().toUpperCase();
      final state = _userVoucherStates[code];
      return Voucher(
        code: code,
        description: (data['description'] ?? '').toString(),
        discountPercent: _parseInt(
          data['discountPercent'] ?? data['discountValue'],
        ),
        discountType: (data['discountType'] ?? 'Persentase').toString(),
        usageCount: _parseInt(data['usageCount']),
        isClaimed: state?['isClaimed'] == true,
        isUsed: state?['isUsed'] == true,
      );
    }).toList();
  }

  Future<void> saveVoucher({
    required String code,
    required String description,
    required int discountPercent,
    String? discountType,
    String? expiresAt,
  }) async {
    final normalizedCode = code.toUpperCase().trim();
    await FirebaseSyncService.vouchersCollection().doc(normalizedCode).set({
      'code': normalizedCode,
      'description': description,
      'discountPercent': discountPercent,
      'discountType': discountType ?? 'Persentase',
      'expiresAtLabel': expiresAt,
      'usageCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Create global notification
    String discountStr = (discountType == 'Nominal Fixed') ? 'Rp $discountPercent' : '$discountPercent%';
    await FirebaseFirestore.instance.collection('global_notifications').add({
      'title': '🎉 Promo Baru!',
      'message': 'Gunakan kode $normalizedCode untuk mendapatkan diskon $discountStr. $description',
      'type': 'promo',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVoucher({
    required String code,
    required String description,
    required int discountPercent,
    String? discountType,
    String? expiresAt,
  }) {
    final normalizedCode = code.toUpperCase().trim();
    return FirebaseSyncService.vouchersCollection().doc(normalizedCode).set({
      'code': normalizedCode,
      'description': description,
      'discountPercent': discountPercent,
      'discountType': discountType ?? 'Persentase',
      'expiresAtLabel': expiresAt,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteVoucher(String code) {
    final normalizedCode = code.toUpperCase().trim();
    return FirebaseSyncService.vouchersCollection().doc(normalizedCode).delete();
  }

  Future<void> claimVoucher(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final normalizedCode = code.toUpperCase().trim();
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == normalizedCode && !voucher.isClaimed) {
        voucher.isClaimed = true;
        break;
      }
    }
    vouchersNotifier.value = List.from(vouchers);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vouchers')
          .doc(normalizedCode)
          .set({
        'code': normalizedCode,
        'isClaimed': true,
        'isUsed': false,
        'claimedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore claimVoucher failed: $e');
    }
  }

  Future<void> useVoucher(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final normalizedCode = code.toUpperCase().trim();
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == normalizedCode && voucher.isClaimed && !voucher.isUsed) {
        voucher.isUsed = true;
        break;
      }
    }
    vouchersNotifier.value = List.from(vouchers);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vouchers')
          .doc(normalizedCode)
          .set({
        'code': normalizedCode,
        'isUsed': true,
        'usedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // UPDATE GLOBAL USAGE COUNT
      await FirebaseSyncService.vouchersCollection().doc(normalizedCode).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Firestore useVoucher failed: $e');
    }
  }

  Voucher? getVoucher(String code) {
    try {
      final normalizedCode = code.toUpperCase().trim();
      return vouchersNotifier.value.firstWhere((v) => v.code == normalizedCode);
    } catch (e) {
      return null;
    }
  }

  List<Voucher> get claimedVouchers {
    return vouchersNotifier.value.where((v) => v.isClaimed).toList();
  }

  List<Voucher> get availableVouchers {
    return vouchersNotifier.value.where((v) => !v.isUsed).toList();
  }
}
