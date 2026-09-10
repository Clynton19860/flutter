import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quote_app/app.dart';

Future<void> main() async {
  await initializeDateFormatting('en_ZA');
  runApp(const ProviderScope(child: QuoteApp()));
}
