import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:sqflite/sqflite.dart';

class SqliteQuoteRepository implements QuoteRepository {
  SqliteQuoteRepository(this._db);
  final Database _db;

  @override
  Future<List<Quote>> loadAll() async {
    final rows = await _db.query('quotes', orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Quote?> byId(String id) async {
    final rows = await _db.query(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> save(Quote q) => _db.insert(
    'quotes',
    {
      'id': q.id,
      'premium': q.premium,
      'currency': q.currency,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // makes save() an upsert
  );

  @override
  Future<void> delete(String id) =>
      _db.delete('quotes', where: 'id = ?', whereArgs: [id]);

  Quote _fromRow(Map<String, Object?> r) => Quote(
    id: r['id'] as String,
    premium: (r['premium'] as num).toDouble(), // the num cast again
    currency: r['currency'] as String,
  );
}
