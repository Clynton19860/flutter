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
  Future<void> save(Quote quote) => _db.insert(
    'quotes',
    {
      'id': quote.id,
      'premium': quote.premium,
      'currency': quote.currency,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  @override
  Future<void> delete(String id) =>
      _db.delete('quotes', where: 'id = ?', whereArgs: [id]);

  Quote _fromRow(Map<String, Object?> row) => Quote(
    id: row['id'] as String,
    premium: (row['premium'] as num).toDouble(),
    currency: row['currency'] as String,
  );
}