import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mopro/payment_page.dart';
import 'package:project_mopro/receipt_page.dart';
import 'test_helper.dart';

void main() {
  HttpOverrides.global = MockHttpOverrides();
  final costumeData = {
    "title": "Bundle Monkey D. Luffy (Wano)",
    "series": "One Piece",
    "price": "120.000",
    "condition": "95%",
    "image": "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=1000&auto=format&fit=crop",
    "include": "Kemeja Merah Terbuka, Celana Pendek, Topi Jerami, Sabuk Kuning",
    "size": "L - XL",
    "isReady": true,
  };

  testWidgets('PaymentPage displays correct costume, billing info, and methods', (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides();
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 2)); // 3 days

    await tester.pumpWidget(MaterialApp(
      home: PaymentPage(
        costumeData: costumeData,
        startDate: startDate,
        endDate: endDate,
        totalDays: 3,
        totalRentPrice: 120000,
        deposit: 50000,
        grandTotal: 170000,
      ),
    ));

    // Verify costume details are displayed
    expect(find.text("Bundle Monkey D. Luffy (Wano)"), findsOneWidget);
    expect(find.text("One Piece"), findsOneWidget);

    // Verify price details are displayed
    expect(find.textContaining("120.000"), findsOneWidget);
    expect(find.textContaining("50.000"), findsOneWidget);
    expect(find.textContaining("170.000"), findsOneWidget);

    // Verify payment options are listed
    expect(find.text("BCA Virtual Account"), findsOneWidget);
    expect(find.text("GoPay"), findsOneWidget);
    expect(find.text("ShopeePay"), findsOneWidget);

    // Scroll GoPay into view
    final goPayFinder = find.text("GoPay");
    await tester.ensureVisible(goPayFinder);
    await tester.pumpAndSettle();

    // Click on GoPay method
    await tester.tap(goPayFinder);
    await tester.pumpAndSettle();

    // Tap "Bayar Sekarang" button
    await tester.tap(find.text("Bayar Sekarang"));
    await tester.pumpAndSettle();

    // Verify ReceiptPage is navigated to (and is on screen)
    expect(find.byType(ReceiptPage), findsOneWidget);
  });
}
