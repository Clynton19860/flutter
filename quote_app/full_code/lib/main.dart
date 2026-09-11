import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Required before any plugin call.
  WidgetsFlutterBinding.ensureInitialized();

  // Load both stores before the first frame, then hand them to the providers.
  // Everything downstream can then read them synchronously.
  final prefs = await SharedPreferences.getInstance();
  final db = await openQuoteDb();

  runApp(ProviderScope(
    // Course setting: surface failures immediately instead of retrying.
    // Remove for production.
    retry: (retryCount, error) => null,
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(db),
    ],
    child: const QuoteApp(),
  ));
}
