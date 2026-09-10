import 'package:flutter/material.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';

class QuoteApp extends StatefulWidget {
  const QuoteApp({super.key});

  @override
  State<QuoteApp> createState() => _QuoteAppState();
}

class _QuoteAppState extends State<QuoteApp> {
  String _brandKey = 'alpha';

  @override
  Widget build(BuildContext context) {
    final brand = brands[_brandKey]!;
    return MaterialApp(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      home: CaptureScreen(
        brand: brand,
        onSwitchBrand: () => setState(
          () => _brandKey = _brandKey == 'alpha' ? 'beta' : 'alpha',
        ),
      ),
    );
  }
}