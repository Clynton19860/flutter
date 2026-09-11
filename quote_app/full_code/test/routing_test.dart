import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/core/routing/router.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:quote_app/features/quote/data/sqlite_quote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container({required bool onboarded}) async {
  SharedPreferences.setMockInitialValues({'onboarded': onboarded});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository()),
  ]);
}

void main() {
  testWidgets('an un-onboarded user is redirected to /onboarding', (t) async {
    final c = await _container(onboarded: false);
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('a deep link to an unknown quote id shows not-found', (t) async {
    final c = await _container(onboarded: true);
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    router.go('/quote/result/q-does-not-exist');

    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Quote not found'), findsOneWidget);
  });

  testWidgets('an unknown route renders the errorBuilder', (t) async {
    final c = await _container(onboarded: true);
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    router.go('/nowhere');

    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Page not found'), findsOneWidget);
    expect(find.text('Go home'), findsOneWidget);
  });
}
