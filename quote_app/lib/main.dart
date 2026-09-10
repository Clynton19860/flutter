import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';
import 'package:quote_app/core/storage/database.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/quote/data/in_memory_quote_repository.dart';
import 'package:quote_app/features/quote/data/quote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // sqflite is mobile-only (MissingPluginException on web). Chrome and other
  // web targets fall back to an in-memory repository; every other line in
  // the app is unchanged because both implement the same QuoteRepository.
  final overrides = kIsWeb
      ? [
          sharedPrefsProvider.overrideWithValue(prefs),
          quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository()),
        ]
      : [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(await openQuoteDb()),
        ];

  runApp(
    ProviderScope(
      // Course setting: surface failures immediately. Remove for production.
      retry: (retryCount, error) => null,
      overrides: overrides,
      child: const QuoteApp(),
    ),
  );
}
