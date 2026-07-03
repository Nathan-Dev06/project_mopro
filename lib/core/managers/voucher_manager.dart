import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:project_mopro/core/services/firebase_sync_service.dart';

class Voucher {
  final String code;
  final String description;
  final int discountPercent; // e.g., 20 for 20%
  bool isClaimed;
  bool isUsed;

  Voucher({
    required this.code,
    required this.description,
    required this.discountPercent,
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  VoucherManager._privateConstructor() {
    _listenToFirestore();
  }

  void _listenToFirestore() {
    _voucherSubscription ??=
        FirebaseSyncService.vouchersCollection().snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          vouchersNotifier.value = List<Voucher>.from(_fallbackVouchers);
          return;
        }

        vouchersNotifier.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return Voucher(
            code: (data['code'] ?? doc.id).toString().toUpperCase(),
            description: (data['description'] ?? '').toString(),
            discountPercent: _parseInt(
              data['discountPercent'] ?? data['discountValue'],
            ),
            isClaimed: data['isClaimed'] == true,
            isUsed: data['isUsed'] == true,
          );
        }).toList();
      },
      onError: (error) {
        debugPrint('Voucher sync failed: $error');
      },
    );
  }

  Future<void> saveVoucher({
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
      'isClaimed': false,
      'isUsed': false,
      'usageCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateVoucher({
    required String code,
    required String description,
    required int discountPercent,
    String? discountType,
    String? expiresAt,
    bool? isClaimed,
    bool? isUsed,
  }) {
    final normalizedCode = code.toUpperCase().trim();
    return FirebaseSyncService.vouchersCollection().doc(normalizedCode).set({
      'code': normalizedCode,
      'description': description,
      'discountPercent': discountPercent,
      'discountType': discountType ?? 'Persentase',
      'expiresAtLabel': expiresAt,
      if (isClaimed != null) 'isClaimed': isClaimed,
      if (isUsed != null) 'isUsed': isUsed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteVoucher(String code) {
    final normalizedCode = code.toUpperCase().trim();
    return FirebaseSyncService.vouchersCollection().doc(normalizedCode).delete();
  }

  Future<void> claimVoucher(String code) async {
    final normalizedCode = code.toUpperCase().trim();
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == normalizedCode && !voucher.isClaimed) {
        voucher.isClaimed = true;
        break;
      }
    }
    vouchersNotifier.value = List.from(vouchers);

    await FirebaseSyncService.vouchersCollection().doc(normalizedCode).set({
      'code': normalizedCode,
      'isClaimed': true,
      'claimedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> useVoucher(String code) async {
    final normalizedCode = code.toUpperCase().trim();
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == normalizedCode && voucher.isClaimed && !voucher.isUsed) {
        voucher.isUsed = true;
        break;
      }
    }
    vouchersNotifier.value = List.from(vouchers);

    await FirebaseSyncService.vouchersCollection().doc(normalizedCode).set({
      'code': normalizedCode,
      'isUsed': true,
      'usedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
