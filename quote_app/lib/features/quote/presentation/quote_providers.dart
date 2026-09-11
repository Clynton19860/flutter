import 'dart:async';

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
  // A quote left un-actioned this long auto-expires. A real Timer, so tests
  // can drive it with fake_async's FakeAsync instead of waiting for real time.
  static const expiryDuration = Duration(minutes: 5);

  Timer? _expiryTimer;

  @override
  QuoteState build() {
    ref.onDispose(() => _expiryTimer?.cancel());
    return const QuoteIdle();
  }

  Future<void> submit(QuoteRequest request) async {
    _expiryTimer?.cancel();
    state = const QuoteLoading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      state = QuoteLoaded(quote);
      _expiryTimer = Timer(expiryDuration, () {
        if (state case QuoteLoaded(quote: final loaded)
            when loaded.id == quote.id) {
          state = QuoteExpired(quote);
        }
      });
    } catch (e) {
      state = QuoteFailed(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() {
    _expiryTimer?.cancel();
    state = const QuoteIdle();
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(
  QuoteNotifier.new,
);
