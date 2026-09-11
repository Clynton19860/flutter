import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/features/quote/data/sqlite_quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

abstract interface class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<Quote?> byId(String id);
  Future<void> save(Quote quote);
  Future<void> delete(String id);
}

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => SqliteQuoteRepository(ref.watch(databaseProvider)),
);

/// The Chrome and desktop fallback: sqflite is mobile-only.
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
