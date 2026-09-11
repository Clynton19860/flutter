import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

/// The state IS the async value here - a list from the database, with no extra
/// domain meaning - so AsyncNotifier fits rather than a sealed state.
class SavedQuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() => ref.watch(quoteRepositoryProvider).loadAll();

  Future<void> add(Quote q) async {
    await ref.read(quoteRepositoryProvider).save(q);
    ref.invalidateSelf(); // re-run build() so the list always matches the DB
  }

  Future<void> remove(String id) async {
    await ref.read(quoteRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final savedQuotesProvider =
    AsyncNotifierProvider<SavedQuotesNotifier, List<Quote>>(
        SavedQuotesNotifier.new);
