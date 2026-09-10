// Exercise 17: Onboarding that never finishes
//
// A provider's identity IS the top-level final that declares it. Two files each
// declaring `onboardedProvider` create TWO different providers that happen to
// share a name. The router watches one; complete() sets the other. The flag the
// redirect is watching never changes, so it redirects forever.
//
// Fix: declare it in exactly one file, delete the other copy, and point every
// import at the survivor - here, prefs_providers.dart.
//
//   router.dart            import '.../core/storage/prefs_providers.dart';
//   onboarding_screen.dart import '.../core/storage/prefs_providers.dart';
//
// This bites for real when a class is moved between files and a copy is left
// behind. If onboarding loops, search the project for the provider name and
// count how many declarations come back. It should be one.

class OnboardedNotifier extends Notifier<bool> {
  static const _key = 'onboarded';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPrefsProvider).setBool(_key, true);
    state = true;
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(OnboardedNotifier.new);
