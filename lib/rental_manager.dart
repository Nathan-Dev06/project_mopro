import 'package:flutter/foundation.dart';

class Rental {
  final String transactionId;
  final String costumeName;
  final String costumeSeries;
  final String size;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "Awaiting Payment", "Renting", "Completed", "Canceled"

  Rental({
    required this.transactionId,
    required this.costumeName,
    required this.costumeSeries,
    required this.size,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class RentalManager {
  // Singleton instance
  static final RentalManager instance = RentalManager._internal();

  RentalManager._internal();

  // ValueNotifier for reactive UI updates
  final ValueNotifier<List<Rental>> rentalsNotifier =
      ValueNotifier<List<Rental>>([]);

  // Getters
  List<Rental> get activeRentals => rentalsNotifier.value
      .where((r) => r.status == "Renting" || r.status == "Awaiting Payment")
      .toList();
  List<Rental> get completedRentals =>
      rentalsNotifier.value.where((r) => r.status == "Completed").toList();
  List<Rental> get canceledRentals =>
      rentalsNotifier.value.where((r) => r.status == "Canceled").toList();

  // Add a new rental
  void addRental(Rental rental) {
    rentalsNotifier.value = [...rentalsNotifier.value, rental];
  }
}
