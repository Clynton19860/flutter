import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/network/dio_client.dart';
import 'package:quote_app/features/quote/data/dio_quote_service.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

// FakeQuoteService is kept as the offline fallback — reverting this one line
// turns any network problem into a non-event.
final quoteServiceProvider = Provider<QuoteService>(
  (ref) => DioQuoteService(ref.watch(dioProvider)),
);

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() => const QuoteIdle();

  Future<void> submit(QuoteRequest request) async {
    state = const QuoteLoading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      state = QuoteLoaded(quote);
    } catch (e) {
      state = QuoteFailed(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const QuoteIdle();
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(
  QuoteNotifier.new,
);
