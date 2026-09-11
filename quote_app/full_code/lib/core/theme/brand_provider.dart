import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(brandKeyStoreProvider).read();

  Future<void> set(String key) async {
    await ref.read(brandKeyStoreProvider).write(key);
    state = key;
  }

  Future<void> toggle() => set(state == 'alpha' ? 'beta' : 'alpha');
}

final brandKeyProvider =
    NotifierProvider<BrandKeyNotifier, String>(BrandKeyNotifier.new);

/// Derived: recomputes only when brandKeyProvider changes.
final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key] ?? brands['alpha']!;
});
