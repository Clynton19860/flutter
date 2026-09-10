import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class InMemoryQuoteRepository implements QuoteRepository {
  final _quotes = <String, Quote>{};

  @override
  Future<List<Quote>> loadAll() async =>
      _quotes.values.toList().reversed.toList();

  @override
  Future<Quote?> byId(String id) async => _quotes[id];

  @override
  Future<void> save(Quote quote) async => _quotes[quote.id] = quote;

  @override
  Future<void> delete(String id) async => _quotes.remove(id);
}
