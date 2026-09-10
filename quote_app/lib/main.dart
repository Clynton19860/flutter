import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';

void main() => runApp(
  // wraps the app once, it owns every provide's state. Tests create their own ProviderScope to isolate state.
      const ProviderScope(
        child: QuoteApp(),
      ),
    );