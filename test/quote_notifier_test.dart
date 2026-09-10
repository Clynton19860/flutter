import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

void main() {
  test(
    'submit moves idle to loading to loaded',
    () async {
      final container = ProviderContainer(
        overrides: [
          quoteServiceProvider.overrideWithValue(
            FakeQuoteService(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final states = <QuoteState>[];

      container.listen(
        quoteProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container
          .read(quoteProvider.notifier)
          .submit(
            const QuoteRequest(
              make: 'VW',
              year: 2020,
              driverAge: 30,
              cover: Cover.comprehensive,
            ),
          );

      expect(
        states.map((s) => s.runtimeType),
        [Idle, Loading, Loaded],
      );
    },
  );
}