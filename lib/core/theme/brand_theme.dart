// lib/core/theme/brand_theme.dart
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
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1.5),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
    seed: Color(0xFF2563EB),
    logoAsset: 'assets/brands/alpha.png',
  ),
  'beta': BrandTheme(
    key: 'beta',
    name: 'Beta Cover',
    seed: Color(0xFF7C3AED),
    logoAsset: 'assets/brands/beta.png',
  ),
};
