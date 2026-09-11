import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/core/theme/brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  static const _key = 'brand';

  @override
  String build() => ref.watch(sharedPrefsProvider).getString(_key) ?? 'alpha';

  Future<void> set(String key) async {
    await ref.read(sharedPrefsProvider).setString(_key, key);
    state = key;
  }

  Future<void> toggle() {
    final keys = brands.keys.toList();
    final next = (keys.indexOf(state) + 1) % keys.length;
    return set(keys[next]);
  }
}

final brandKeyProvider = NotifierProvider<BrandKeyNotifier, String>(
  BrandKeyNotifier.new,
);

final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key]!;
});
