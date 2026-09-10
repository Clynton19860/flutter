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
      inputDecorationTheme: const InputDecorationThemeData(border: OutlineInputBorder()),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}

const brands = <String, BrandTheme>{
  'alpha': BrandTheme(
    key: 'alpha',
    name: 'Lumi Insure',
    seed: Color(0xFFFF3D8D),
    logoAsset: 'assets/brands/icons8-car-50.png',
  ),
  'beta': BrandTheme(
    key: 'beta',
    name: 'Luna cover',
    seed: Color(0xFF8B5CF6),
    logoAsset: 'assets/brands/icons8-car-50.png',
  ),
};