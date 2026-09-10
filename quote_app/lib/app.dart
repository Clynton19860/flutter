import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';

import 'core/theme/brand_provider.dart';

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      home: CaptureScreen(
        brand: brand,
        onSwitchBrand: () => ref.read(brandKeyProvider.notifier).toggle(),
      ),
    );
  }
}