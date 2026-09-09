import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lab 4.1: in memory only. Lab 4.3 changes `build()` to read shared_preferences
/// and `complete()` to write it, and nothing else in the app changes.
class OnboardedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> complete() async {
    state = true; // the router's redirect reacts to this
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(OnboardedNotifier.new);
