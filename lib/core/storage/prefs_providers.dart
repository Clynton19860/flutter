import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> complete() async {
    state = true;
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(
  OnboardedNotifier.new,
);