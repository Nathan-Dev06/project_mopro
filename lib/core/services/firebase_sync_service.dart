import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSyncService {
  FirebaseSyncService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> storeSettingsDoc() {
    return _firestore.collection('store_settings').doc('main');
  }

  static CollectionReference<Map<String, dynamic>> usersCollection() {
    return _firestore.collection('users');
  }

  static CollectionReference<Map<String, dynamic>> vouchersCollection() {
    return _firestore.collection('vouchers');
  }

  static DocumentReference<Map<String, dynamic>> financialSummaryDoc() {
    return _firestore.collection('financials').doc('main');
  }

  static CollectionReference<Map<String, dynamic>> payoutRequestsCollection() {
    return _firestore.collection('payout_requests');
  }

  static Map<String, dynamic> defaultStoreSettings() {
    return {
      'storeName': 'Cosvoria Rent',
      'province': 'DKI Jakarta',
      'city': 'Jakarta Selatan',
      'whatsapp': '0812-3456-7890',
      'deposit': 'Rp 50.000',
      'shipping': 'Rp 15.000',
      'isStoreActive': true,
      'requiresKtpVerification': true,
      'autoApproveOrder': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> defaultFinancialSummary() {
    return {
      'availableBalance': 2450000,
      'totalIncome': 12800000,
      'totalWithdrawn': 10300000,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Future<void> saveStoreSettings(Map<String, dynamic> data) {
    return storeSettingsDoc().set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> saveFinancialSummary(Map<String, dynamic> data) {
    return financialSummaryDoc().set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> updateUserVerification({
    required String userId,
    required String verificationStatus,
    String? reviewedBy,
    String? ktpNumber,
    String? requestedAtLabel,
  }) {
    return usersCollection().doc(userId).set(
      {
        'verificationStatus': verificationStatus,
        'verificationReviewedAt': FieldValue.serverTimestamp(),
        if (ktpNumber != null) 'ktpNumber': ktpNumber,
        if (requestedAtLabel != null) 'verificationRequestedAtLabel': requestedAtLabel,
        if (reviewedBy != null) 'verificationReviewedBy': reviewedBy,
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> submitKtpVerification({
    required String userId,
    required String ktpNumber,
  }) {
    return usersCollection().doc(userId).set(
      {
        'ktpNumber': ktpNumber,
        'verificationStatus': 'pending',
        'verificationRequestedAtLabel': DateTime.now().toIso8601String(),
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
        'verificationReviewedAt': FieldValue.delete(),
        'verificationReviewedBy': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> upsertUserRecord({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return usersCollection().doc(userId).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> createPayoutRequest({
    required int amount,
    required String title,
    String status = 'pending',
  }) {
    return payoutRequestsCollection().add(
      {
        'title': title,
        'amount': amount,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }
}