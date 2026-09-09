import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/routing/router.dart';
import 'package:quote_app/core/storage/onboarding_provider.dart';

void main() {
  testWidgets('redirect forces onboarding, then completing goes to /quote',
      (t) async {
    await t.pumpWidget(const ProviderScope(child: QuoteApp()));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);

    await t.tap(find.text('Get started'));
    await t.pumpAndSettle();
    expect(find.text('Get started'), findsNothing);
    expect(find.text('Fill in the form to get a quote'), findsOneWidget);
  });

  testWidgets('deep link to a result id shows not-found, back returns to quote',
      (t) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(onboardedProvider.notifier).complete();
    final router = container.read(routerProvider);
    router.go('/quote/result/q-does-not-exist');

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Quote not found'), findsOneWidget);
  });
}
