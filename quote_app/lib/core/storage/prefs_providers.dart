import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the instance loaded before the first frame.
/// Throwing here makes a forgotten override fail loudly and immediately
/// instead of silently returning something wrong.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

/// Same class as Lab 4.1 - only build() and complete() changed. The router,
/// the onboarding screen and the redirect are all untouched.
class OnboardedNotifier extends Notifier<bool> {
  static const _key = 'onboarded';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPrefsProvider).setBool(_key, true);
    state = true; // the router redirect reacts
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(OnboardedNotifier.new);

/// The brand key now survives a restart too.
class BrandKeyStore {
  const BrandKeyStore(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'brand';

  String read() => _prefs.getString(_key) ?? 'alpha';
  Future<void> write(String key) => _prefs.setString(_key, key);
}

final brandKeyStoreProvider =
    Provider<BrandKeyStore>((ref) => BrandKeyStore(ref.watch(sharedPrefsProvider)));
