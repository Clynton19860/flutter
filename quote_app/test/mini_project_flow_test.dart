// The whole Day 4 flow with no emulator: onboarding -> capture -> service
// -> result -> save -> saved list. Storage is overridden, not mocked away.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/data/sqlite_quote_repository.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container({bool onboarded = false}) async {
  SharedPreferences.setMockInitialValues({'onboarded': onboarded});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository()),
    quoteServiceProvider.overrideWithValue(
      FakeQuoteService(DateTime.now),
    ),
  ]);
}

void main() {
  testWidgets('onboarding shows once and the flag persists', (t) async {
    final c = await _container();
    addTearDown(c.dispose);
    await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: const QuoteApp()));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);

    await t.tap(find.text('Get started'));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsNothing);

    // the flag really reached prefs
    expect(c.read(sharedPrefsProvider).getBool('onboarded'), isTrue);
  });

  testWidgets('quote -> result -> save -> appears in Saved', (t) async {
    final c = await _container(onboarded: true);
    addTearDown(c.dispose);
    await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: const QuoteApp()));
    await t.pumpAndSettle();

    await t.enterText(find.widgetWithText(TextFormField, 'Vehicle make'), 'VW');
    await t.enterText(find.widgetWithText(TextFormField, 'Year'), '2020');
    await t.tap(find.text('Select date'));
    await t.pumpAndSettle();
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Get quote'));
    await t.tap(find.text('Get quote'));
    await t.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Your quote'), findsOneWidget);

    await t.tap(find.text('Save this quote'));
    await t.pumpAndSettle();

    expect(find.text('Saved quotes'), findsOneWidget);
    expect(find.textContaining('Ref q-'), findsOneWidget);
  });

  testWidgets('the bottom navigation shell has three tabs', (t) async {
    final c = await _container(onboarded: true);
    addTearDown(c.dispose);
    await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: const QuoteApp()));
    await t.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    expect(find.text('Alpha Insure'), findsWidgets);
  });
}
