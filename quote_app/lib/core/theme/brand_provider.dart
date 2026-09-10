import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  @override
  String build() => 'alpha';

  void toggle() {
    final keys = brands.keys.toList();
    final next = (keys.indexOf(state) + 1) % keys.length;
    state = keys[next];
  }
}

final brandKeyProvider = NotifierProvider<BrandKeyNotifier, String>(
  BrandKeyNotifier.new,
);

final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key]!;
});
