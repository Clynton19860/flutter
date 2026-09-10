import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  @override
  String build() => 'alpha';

  void set(String key) => state = key;
  void toggle() => state = state == 'alpha' ? 'beta' : 'alpha';
}

final brandKeyProvider = NotifierProvider<BrandKeyNotifier, String>(
  BrandKeyNotifier.new,
);

// Derived: recomputes only when brandKeyProvider changes
final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key] ?? brands['alpha']!;
});
