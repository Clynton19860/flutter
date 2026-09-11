import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/prefs_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final db = await openQuoteDb();

  runApp(ProviderScope(
    // Course setting: surface failures immediately. Remove for production.
    retry: (retryCount, error) => null,
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(db),
    ],
    child: const QuoteApp(),
  ));
}