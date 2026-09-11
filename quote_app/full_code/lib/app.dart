import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/routing/router.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
