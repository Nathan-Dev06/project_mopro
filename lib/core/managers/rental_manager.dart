import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rental {
  final String transactionId;
  final String costumeName;
  final String costumeSeries;
  final String size;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;
  String status; // Non-final to allow runtime status changes
  final String customerName;
  final String userId;
  final String? cancellationReason;
  final double? rating;
  final String? reviewText;
  final String? reviewMediaPath;
  final String? reviewMediaType;
  final String? receiptNumber;
  final String? recipientName;
  final String? phone;
  final String? street;
  final String? city;
  final String? province;
  final String? postal;
  final int? totalRentPrice;
  final int? deposit;
  final int? discountAmount;
  final String? voucherCode;
  final int? grandTotal;
  final int? depositDeduction;
  final String? deductionReason;

  Rental({
    required this.transactionId,
    required this.costumeName,
    required this.costumeSeries,
    required this.size,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.customerName = 'Ayu Lestari',
    this.userId = 'guest',
    this.cancellationReason,
    this.rating,
    this.reviewText,
    this.reviewMediaPath,
    this.reviewMediaType,
    this.receiptNumber,
    this.recipientName,
    this.phone,
    this.street,
    this.city,
    this.province,
    this.postal,
    this.totalRentPrice,
    this.deposit,
    this.discountAmount,
    this.voucherCode,
    this.grandTotal,
    this.depositDeduction,
    this.deductionReason,
  });
}

class RentalManager {
  // Singleton instance
  static final RentalManager instance = RentalManager._internal();

  RentalManager._internal() {
    _listenToFirestore();
  }

  // ValueNotifier for reactive UI updates
  final ValueNotifier<List<Rental>> rentalsNotifier =
      ValueNotifier<List<Rental>>([]);

  // Getters for filtered rentals lists
  List<Rental> get activeRentals => rentalsNotifier.value
      .where((r) =>
          r.status == "Active" ||
          r.status == "Pending" ||
          r.status == "Packaging" ||
          r.status == "Shipped" ||
          r.status == "Cancellation Request" ||
          r.status == "Renting" ||
          r.status == "Returned" ||
          r.status == "Checking")
      .toList();
  List<Rental> get completedRentals =>
      rentalsNotifier.value.where((r) => r.status == "Completed").toList();
  List<Rental> get canceledRentals =>
      rentalsNotifier.value.where((r) => r.status == "Canceled").toList();

  // Listen to Firestore real-time updates
  void _listenToFirestore() {
    FirebaseFirestore.instance
        .collection('rentals')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedDummyData();
        return;
      }
      final rentals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Rental(
          transactionId: doc.id,
          costumeName: data['costumeName'] ?? '',
          costumeSeries: data['costumeSeries'] ?? '',
          size: data['size'] ?? '',
          imagePath: data['imagePath'] ?? '',
          startDate: data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : DateTime.now(),
          status: data['status'] ?? '',
          customerName: data['customerName'] ?? 'Ayu Lestari',
          userId: data['userId'] ?? 'guest',
          cancellationReason: data['cancellationReason'],
          rating: (data['rating'] as num?)?.toDouble(),
          reviewText: data['reviewText'],
          reviewMediaPath: data['reviewMediaPath'],
          reviewMediaType: data['reviewMediaType'],
          receiptNumber: data['receiptNumber'],
          recipientName: data['recipientName'],
          phone: data['phone'],
          street: data['street'],
          city: data['city'],
          province: data['province'],
          postal: data['postal'],
          totalRentPrice: data['totalRentPrice'] as int?,
          deposit: data['deposit'] as int?,
          discountAmount: data['discountAmount'] as int?,
          voucherCode: data['voucherCode'],
          grandTotal: data['grandTotal'] as int?,
          depositDeduction: data['depositDeduction'] as int?,
          deductionReason: data['deductionReason'],
        );
      }).toList();

      rentalsNotifier.value = rentals;
    });
  }

  // Populate Firestore with default data if empty
  Future<void> _seedDummyData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final dummyData = [
      Rental(
        transactionId: "TRX-1004",
        costumeName: "Chainsaw Man Denji",
        costumeSeries: "Chainsaw Man",
        size: "L",
        imagePath: "assets/images/deadpool.jpg",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        status: "Cancellation Request",
        customerName: "Rian Wijaya",
        cancellationReason: "Salah pilih ukuran costume, ingin ganti ke XL.",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-1003",
        costumeName: "Genshin Impact Zhongli",
        costumeSeries: "Genshin Impact",
        size: "L",
        imagePath: "assets/images/gojo.jpg",
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: "Pending",
        customerName: "Budi Santoso",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-1002",
        costumeName: "Spy x Family Anya",
        costumeSeries: "Spy x Family",
        size: "S",
        imagePath: "assets/images/anya.jpg",
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: "Packaging",
        customerName: "Ayu Lestari",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-1005",
        costumeName: "Frieren Beyond Journey's End",
        costumeSeries: "Frieren",
        size: "M",
        imagePath: "assets/images/frieren.jpg",
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: "Shipped",
        customerName: "Siti Rahma",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-1001",
        costumeName: "Naruto Akatsuki Cloak",
        costumeSeries: "Naruto",
        size: "XL",
        imagePath: "assets/images/luffy_wano.jpg",
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        status: "Active",
        customerName: "Dimas",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-1000",
        costumeName: "Genshin Impact Raiden Shogun",
        costumeSeries: "Genshin Impact",
        size: "M",
        imagePath: "assets/images/raiden.jpg",
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 7)),
        status: "Completed",
        customerName: "Eka Putri",
        rating: 5.0,
        reviewText: "Kostumnya sangat wangi dan lengkap aksesorisnya!",
        userId: currentUserId,
      ),
      Rental(
        transactionId: "TRX-0999",
        costumeName: "Neon Genesis Evangelion Zero Two",
        costumeSeries: "Evangelion",
        size: "S",
        imagePath: "assets/images/zero_two.jpg",
        startDate: DateTime.now().subtract(const Duration(days: 12)),
        endDate: DateTime.now().subtract(const Duration(days: 9)),
        status: "Canceled",
        customerName: "Fadel",
        userId: currentUserId,
      ),
    ];

    for (final r in dummyData) {
      await addRental(r);
    }
  }

  // Add rental to Firestore
  Future<void> addRental(Rental rental) async {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? rental.userId;
    String customerName = rental.customerName;

    // Skip user lookup for walk-in customers
    if (rental.userId != 'walkin-customer') {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        if (userDoc.exists && userDoc.data()?['name'] != null) {
          customerName = userDoc.data()?['name'];
        }
      } catch (_) {}
    }

    // Prepare Firestore data, only include non-null fields
    final Map<String, dynamic> rentalData = {
      'costumeName': rental.costumeName,
      'costumeSeries': rental.costumeSeries,
      'size': rental.size,
      'imagePath': rental.imagePath,
      'startDate': Timestamp.fromDate(rental.startDate),
      'endDate': Timestamp.fromDate(rental.endDate),
      'status': rental.status,
      'customerName': customerName,
      'userId': currentUserId,
    };

    // Add optional fields only if they are not null
    if (rental.cancellationReason != null)
      rentalData['cancellationReason'] = rental.cancellationReason;
    if (rental.rating != null) rentalData['rating'] = rental.rating;
    if (rental.reviewText != null) rentalData['reviewText'] = rental.reviewText;
    if (rental.reviewMediaPath != null)
      rentalData['reviewMediaPath'] = rental.reviewMediaPath;
    if (rental.reviewMediaType != null)
      rentalData['reviewMediaType'] = rental.reviewMediaType;
    if (rental.receiptNumber != null)
      rentalData['receiptNumber'] = rental.receiptNumber;
    if (rental.recipientName != null)
      rentalData['recipientName'] = rental.recipientName;
    if (rental.phone != null) rentalData['phone'] = rental.phone;
    if (rental.street != null) rentalData['street'] = rental.street;
    if (rental.city != null) rentalData['city'] = rental.city;
    if (rental.province != null) rentalData['province'] = rental.province;
    if (rental.postal != null) rentalData['postal'] = rental.postal;
    if (rental.totalRentPrice != null)
      rentalData['totalRentPrice'] = rental.totalRentPrice;
    if (rental.deposit != null) rentalData['deposit'] = rental.deposit;
    if (rental.discountAmount != null)
      rentalData['discountAmount'] = rental.discountAmount;
    if (rental.voucherCode != null)
      rentalData['voucherCode'] = rental.voucherCode;
    if (rental.grandTotal != null) rentalData['grandTotal'] = rental.grandTotal;
    if (rental.depositDeduction != null)
      rentalData['depositDeduction'] = rental.depositDeduction;
    if (rental.deductionReason != null)
      rentalData['deductionReason'] = rental.deductionReason;

    await FirebaseFirestore.instance
        .collection('rentals')
        .doc(rental.transactionId)
        .set(rentalData, SetOptions(merge: true));
  }

  // Update status or review detail in Firestore
  Future<void> updateRentalStatus(
    String transactionId,
    String newStatus, {
    String? cancellationReason,
    double? rating,
    String? reviewText,
    String? reviewMediaPath,
    String? reviewMediaType,
    String? receiptNumber,
    int? depositDeduction,
    String? deductionReason,
  }) async {
    final updates = <String, dynamic>{
      'status': newStatus,
    };
    if (cancellationReason != null) {
      updates['cancellationReason'] = cancellationReason;
    }
    if (rating != null) {
      updates['rating'] = rating;
    }
    if (reviewText != null) {
      updates['reviewText'] = reviewText;
    }
    if (reviewMediaPath != null) {
      updates['reviewMediaPath'] = reviewMediaPath;
    }
    if (reviewMediaType != null) {
      updates['reviewMediaType'] = reviewMediaType;
    }
    if (receiptNumber != null) {
      updates['receiptNumber'] = receiptNumber;
    }
    if (depositDeduction != null) {
      updates['depositDeduction'] = depositDeduction;
    }
    if (deductionReason != null) {
      updates['deductionReason'] = deductionReason;
    }

    await FirebaseFirestore.instance
        .collection('rentals')
        .doc(transactionId)
        .update(updates);

    if (newStatus == 'Completed') {
      try {
        final rentalDoc = await FirebaseFirestore.instance
            .collection('rentals')
            .doc(transactionId)
            .get();
        if (rentalDoc.exists) {
          final data = rentalDoc.data()!;
          final userId = data['userId'];
          final deposit = data['deposit'] as int? ?? 0;
          final deduction = depositDeduction ?? 0;
          final refund = deposit - deduction;

          if (refund > 0 && userId != null) {
            final batch = FirebaseFirestore.instance.batch();

            // 1. Update user balance
            final userRef =
                FirebaseFirestore.instance.collection('users').doc(userId);
            batch.update(userRef, {
              'deposit_balance': FieldValue.increment(refund),
            });

            // 2. Add transaction record
            final txRef = userRef.collection('wallet_transactions').doc();
            batch.set(txRef, {
              'title': 'Deposit Refund - Rental #$transactionId',
              'type': 'refund',
              'amount': refund,
              'deductionAmount': deduction,
              'deductionReason': deductionReason ?? '',
              'timestamp': FieldValue.serverTimestamp(),
            });

            await batch.commit();
          }
        }
      } catch (e) {
        debugPrint('Error refunding deposit: $e');
      }
    }
  }
}
