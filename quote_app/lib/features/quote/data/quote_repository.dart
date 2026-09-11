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

class SavedQuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() => ref.watch(quoteRepositoryProvider).loadAll();

  Future<void> add(Quote q) async {
    await ref.read(quoteRepositoryProvider).save(q);
    ref.invalidateSelf();      // re-run build() so the list matches the DB
  }

  Future<void> remove(String id) async {
    await ref.read(quoteRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final savedQuotesProvider =
AsyncNotifierProvider<SavedQuotesNotifier, List<Quote>>(SavedQuotesNotifier.new);