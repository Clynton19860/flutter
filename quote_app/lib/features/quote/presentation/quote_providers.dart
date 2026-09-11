import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/network/dio_client.dart';
import 'package:quote_app/features/quote/data/dio_quote_service.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

final quoteServiceProvider =
    Provider<QuoteService>((ref) => DioQuoteService(ref.watch(dioProvider)));

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() => Idle();

  Future<void> submit(QuoteRequest request) async {
    state = const Loading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      state = Loaded(quote: quote);
    } catch (e) {
      state = Failed(message: e.toString());
    }
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(
  QuoteNotifier.new,
);
