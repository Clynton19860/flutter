import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'brand_theme.dart';

final brandKeyProvider =
    NotifierProvider<BrandKeyNotifier, String>(
  BrandKeyNotifier.new,
);

class BrandKeyNotifier extends Notifier<String> {
  @override
  String build() => 'alpha';

  void toggle() {
    state = state == 'alpha'
        ? 'beta'
        : 'alpha';
  }
}

final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key]!;
});