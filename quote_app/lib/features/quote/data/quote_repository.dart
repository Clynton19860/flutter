import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/features/quote/data/sqlite_quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

/// The one seam that knows about storage. Notifiers never see SQL.
abstract interface class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<Quote?> byId(String id);
  Future<void> save(Quote quote);
  Future<void> delete(String id);
}

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => SqliteQuoteRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);
