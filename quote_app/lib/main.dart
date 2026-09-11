import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/quote/data/in_memory_quote_repository.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before any plugin call
  await initializeDateFormatting('en_ZA');

  final prefs = await SharedPreferences.getInstance();

  final overrides = [sharedPrefsProvider.overrideWithValue(prefs)];
  if (kIsWeb) {
    // sqflite is mobile-only; Chrome/desktop web falls back to an in-memory store.
    overrides.add(quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository()));
  } else {
    final db = await openQuoteDb();
    overrides.add(databaseProvider.overrideWithValue(db));
  }

  runApp(
    ProviderScope(
      // Course setting: surface failures immediately. Remove for production.
      retry: (retryCount, error) => null,
      overrides: overrides,
      child: const QuoteApp(),
    ),
  );
}
