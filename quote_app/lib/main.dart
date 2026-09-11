import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // sqflite is mobile-only; Chrome and desktop fall back to an in-memory store.
  final overrides = [sharedPrefsProvider.overrideWithValue(prefs)];
  if (kIsWeb) {
    overrides.add(quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository()));
  } else {
    final db = await openQuoteDb();
    overrides.add(databaseProvider.overrideWithValue(db));
  }

  runApp(ProviderScope(
    // Course setting: surface failures immediately. Remove for production.
    retry: (retryCount, error) => null,
    overrides: overrides,
    child: const QuoteApp(),
  ));
}

