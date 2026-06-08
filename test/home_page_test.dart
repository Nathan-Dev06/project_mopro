import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mopro/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helper.dart';

void main() {
  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('MainHomePage renders bottom navigation and Browse page',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: MainHomePage()));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();

    expect(find.text('Browse Koleksi'), findsOneWidget);
    expect(find.byKey(const Key('search_field')), findsOneWidget);

    final firstSaveButton = find.byKey(ValueKey('save_button_${kCostumes.first.id}'));
    expect(firstSaveButton, findsOneWidget);
    await tester.tap(firstSaveButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text(kCostumes.first.title), findsWidgets);
  });

  testWidgets('Saved costumes persist across app restart',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'saved_costume_ids': [kCostumes.first.id]});

    await tester.pumpWidget(const MaterialApp(home: MainHomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text(kCostumes.first.title), findsWidgets);
  });
}
