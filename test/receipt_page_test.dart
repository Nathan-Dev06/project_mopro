import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('ReceiptPage displays details and handles print simulation and returning home', (WidgetTester tester) async {
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 2));

    await tester.pumpWidget(MaterialApp(
      routes: {
        '/': (context) => const Scaffold(body: Text("Main Home Page Mock")),
        '/receipt': (context) => ReceiptPage(
          costumeData: costumeData,
          startDate: startDate,
          endDate: endDate,
          totalDays: 3,
          grandTotal: 170000,
          paymentMethod: "GoPay",
          transactionId: "TRX-9988-1234",
        ),
      },
      initialRoute: '/receipt',
    ));

    // Verify elements are displayed
    expect(find.textContaining("Transaksi Berhasil"), findsOneWidget);
    expect(find.text("TRX-9988-1234"), findsOneWidget);
    expect(find.text("Bundle Monkey D. Luffy (Wano)"), findsOneWidget);
    expect(find.text("GoPay"), findsOneWidget);
    expect(find.textContaining("170.000"), findsOneWidget);

    // Verify Cetak Bukti button is present
    final cetakBuktiFinder = find.text("Cetak Bukti");
    await tester.ensureVisible(cetakBuktiFinder);
    await tester.pumpAndSettle();
    expect(cetakBuktiFinder, findsOneWidget);
    
    // Tap Cetak Bukti and verify loading dialog appears immediately
    await tester.tap(cetakBuktiFinder);
    await tester.pump(); // Trigger the dialog build frame
    expect(find.textContaining("Menyiapkan"), findsOneWidget);
    
    // Advance virtual clock to let the simulated delay complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify dialog indicates document is ready
    expect(find.textContaining("Siap Dicetak"), findsOneWidget);
    
    // Close the simulation dialog by tapping the OK button
    final okFinder = find.text("OK");
    await tester.ensureVisible(okFinder);
    await tester.pumpAndSettle();
    await tester.tap(okFinder);
    await tester.pumpAndSettle();

    // Tap "Kembali ke Beranda"
    final kembaliFinder = find.text("Kembali ke Beranda");
    await tester.ensureVisible(kembaliFinder);
    await tester.pumpAndSettle();
    await tester.tap(kembaliFinder);
    await tester.pumpAndSettle();

    // Verify we navigated back to the root route
    expect(find.text("Main Home Page Mock"), findsOneWidget);
  });
}
