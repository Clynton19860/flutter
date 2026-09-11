import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest request);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (request.year < 2000) throw Exception('Vehicle too old to insure');
    return Quote(
      // TODO: debug ref(clockProvider)
      id: 'q-${ref.read(clockProvider)().millisecondsSinceEpoch}',
      premium: calculatePremium(request),
    );
  }
}
