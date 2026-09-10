import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/data/quote_service.dart' as quote_service;
import 'package:quote_app/features/quote/domain/quote_model.dart';

final quoteServiceProvider = Provider<quote_service.QuoteService>((ref) => quote_service.FakeQuoteService());

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

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(QuoteNotifier.new);