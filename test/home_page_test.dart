import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mopro/home_page.dart';
import 'package:project_mopro/detail_costume_page.dart';
import 'test_helper.dart';

void main() {
  testWidgets(
      'MainHomePage renders with Dark Fantasy theme and navigates to Detail page',
      (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides();
    await tester.pumpWidget(const MaterialApp(
      home: MainHomePage(),
    ));

    // Verify title COSVORIA is shown
    expect(find.text("COSVORIA"), findsOneWidget);

    // Verify background color is canvasDeep Color(0xFF0C0A09)
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF0C0A09));

    // Verify catalog headings or sections
    expect(find.text("Katalog Terbaru"), findsOneWidget);
    expect(find.text("Rekomendasi"), findsOneWidget);

    // Verify specific costumes are listed
    expect(find.textContaining("Bundle Monkey D. Luffy"), findsWidgets);

    // Click on Luffy card to navigate
    final luffyCard = find.textContaining("Bundle Monkey D. Luffy").first;
    await tester.ensureVisible(luffyCard);
    await tester.pumpAndSettle();
    await tester.tap(luffyCard);
    await tester.pumpAndSettle();

    // Verify DetailCostumePage is pushed onto stack
    expect(find.byType(DetailCostumePage), findsOneWidget);
  });
}
