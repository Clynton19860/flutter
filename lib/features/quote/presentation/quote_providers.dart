import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';

import 'package:quote_app/features/quote/domain/quote_model.dart';

final quoteServiceProvider =
    Provider<QuoteService>(
  (ref) => FakeQuoteService(),
);

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() {
    return Idle();
  }

  Future<void> submit(
    QuoteRequest request,
  ) async {
    state = Loading();

    try {
      final quote = await ref
          .read(quoteServiceProvider)
          .getQuote(request);

      state = Loaded(quote);
    } catch (e) {
      state = Failed(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void reset() {
    state = Idle();
  }
}

final quoteProvider =
    NotifierProvider<
        QuoteNotifier,
        QuoteState>(
      QuoteNotifier.new,
    );