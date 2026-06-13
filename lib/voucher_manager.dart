import 'package:flutter/foundation.dart';

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
  VoucherManager._privateConstructor();
  static final VoucherManager instance = VoucherManager._privateConstructor();

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

  void claimVoucher(String code) {
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == code && !voucher.isClaimed) {
        voucher.isClaimed = true;
        break;
      }
    }
    // Force UI to rebuild
    vouchersNotifier.value = List.from(vouchers);
  }

  void useVoucher(String code) {
    final vouchers = vouchersNotifier.value;
    for (var voucher in vouchers) {
      if (voucher.code == code && voucher.isClaimed && !voucher.isUsed) {
        voucher.isUsed = true;
        break;
      }
    }
    vouchersNotifier.value = List.from(vouchers);
  }

  Voucher? getVoucher(String code) {
    try {
      return vouchersNotifier.value.firstWhere((v) => v.code == code);
    } catch (e) {
      return null;
    }
  }

  List<Voucher> get claimedVouchers {
    return vouchersNotifier.value.where((v) => v.isClaimed).toList();
  }

  List<Voucher> get availableVouchers {
    return vouchersNotifier.value.where((v) => v.isClaimed && !v.isUsed).toList();
  }
}
