import 'package:flutter/material.dart';

class BrandTheme {
  const BrandTheme({
    required this.key,
    required this.name,
    required this.seed,
    required this.logoAsset,
    this.fontFamily,
  });

  final String key;
  final String name;
  final Color seed;
  final String logoAsset;
  final String? fontFamily;

  ThemeData toThemeData(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        focusColor: scheme.primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}

const brands = <String, BrandTheme>{
  'alpha': BrandTheme(
    key: 'alpha',
    name: 'Alpha Insure',
    seed: Colors.blue,
    logoAsset: 'assets/brands/alpha.png',
  ),
  'beta': BrandTheme(
    key: 'beta',
    name: 'Reinsure Cover',
    seed: Colors.purple,
    logoAsset: 'assets/brands/beta.png',
  ),
  'gamma': BrandTheme(
    key: 'gamma',
    name: 'Gamma Surety',
    seed: Colors.amberAccent,
    logoAsset: 'assets/brands/gamma.png',
  ),
};