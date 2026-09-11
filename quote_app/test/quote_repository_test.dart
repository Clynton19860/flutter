// Real SQLite, in memory, via sqflite_common_ffi - no emulator needed.
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/features/quote/data/sqlite_quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database db;
  late SqliteQuoteRepository repo;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, v) => db.execute('''
          CREATE TABLE quotes (
            id TEXT PRIMARY KEY,
            premium REAL NOT NULL,
            currency TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        '''),
      ),
    );
    repo = SqliteQuoteRepository(db, DateTime.now);
  });

  tearDown(() => db.close());

  test('save then loadAll round-trips a quote', () async {
    await repo.save(const Quote(id: 'q-1', premium: 1450.0));
    final all = await repo.loadAll();
    expect(all, hasLength(1));
    expect(all.single.id, 'q-1');
    expect(all.single.premium, 1450.0);
    expect(all.single.currency, 'ZAR');
  });

  test('save is an upsert - same id twice does not duplicate', () async {
    await repo.save(const Quote(id: 'q-1', premium: 1000));
    await repo.save(const Quote(id: 'q-1', premium: 2000));
    final all = await repo.loadAll();
    expect(all, hasLength(1));
    expect(all.single.premium, 2000);
  });

  test('byId returns null for an unknown id', () async {
    expect(await repo.byId('nope'), isNull);
  });

  test('delete removes only the target row', () async {
    await repo.save(const Quote(id: 'a', premium: 1));
    await repo.save(const Quote(id: 'b', premium: 2));
    await repo.delete('a');
    final all = await repo.loadAll();
    expect(all.map((q) => q.id), ['b']);
  });
}
