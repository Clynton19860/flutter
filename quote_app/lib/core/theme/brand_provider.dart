// lib/core/theme/brand_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  static const _key = 'brandKey';

  @override
  String build() => ref.watch(sharedPrefsProvider).getString(_key) ?? 'alpha';

  Future<void> set(String key) async {
    await ref.read(sharedPrefsProvider).setString(_key, key);
    state = key;
  }

  void toggle() => set(
        switch (state) {
          'alpha' => 'beta',
          'beta' => 'gamma',
          'gamma' => 'alpha',
          _ => 'alpha',
        },
      );
}

final brandKeyProvider =
    NotifierProvider<BrandKeyNotifier, String>(BrandKeyNotifier.new);

// Derived: recomputes only when brandKeyProvider changes
final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key] ?? brands['alpha']!;
});

