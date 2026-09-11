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

// Overridable in tests, so expiry can be checked by advancing a fake clock
// instead of waiting on real time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class QuoteNotifier extends Notifier<QuoteState> {
  static const defaultMaxAge = Duration(minutes: 15);

  DateTime? _loadedAt;

  @override
  QuoteState build() => const QuoteIdle();

  Future<void> submit(QuoteRequest request) async {
    state = const QuoteLoading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      _loadedAt = ref.read(clockProvider)();
      state = QuoteLoaded(quote);
    } catch (e) {
      state = QuoteFailed(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void checkExpiry({Duration maxAge = defaultMaxAge}) {
    final current = state;
    if (current is! QuoteLoaded || _loadedAt == null) return;
    final now = ref.read(clockProvider)();
    if (now.difference(_loadedAt!) > maxAge) {
      state = QuoteExpired(current.quote);
    }
  }

  void reset() {
    _loadedAt = null;
    state = const QuoteIdle();
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(
  QuoteNotifier.new,
);
