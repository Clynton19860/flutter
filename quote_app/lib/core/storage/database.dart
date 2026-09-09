import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// version + onCreate + onUpgrade IS the migration mechanism: bump the version
/// and add the ALTER in onUpgrade. Never edit onCreate for an existing table.
Future<Database> openQuoteDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'quotes.db'),
    version: 1,
    onCreate: (db, version) => db.execute('''
      CREATE TABLE quotes (
        id TEXT PRIMARY KEY,
        premium REAL NOT NULL,
        currency TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    '''),
    onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) await db.execute('ALTER TABLE quotes ADD COLUMN make TEXT');
    },
  );
}

/// Opened once in main() and overridden, exactly like sharedPrefsProvider.
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);
