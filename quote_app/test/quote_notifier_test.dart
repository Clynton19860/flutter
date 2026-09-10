import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class _StubQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest r) async =>
      Quote(id: 'stub', premium: calculatePremium(r));
}

void main() {
  test('QuoteNotifier goes Idle -> Loading -> Loaded on submit', () async {
    final container = ProviderContainer(
      overrides: [quoteServiceProvider.overrideWithValue(_StubQuoteService())],
    );
    addTearDown(container.dispose);

    expect(container.read(quoteProvider), isA<Idle>());

    final future = container.read(quoteProvider.notifier).submit(
      const QuoteRequest(
        make: 'VW',
        year: 2020,
        driverAge: 30,
        cover: Cover.comprehensive,
      ),
    );
    expect(container.read(quoteProvider), isA<Loading>());

    await future;
    expect(container.read(quoteProvider), isA<Loaded>());
  });
}
