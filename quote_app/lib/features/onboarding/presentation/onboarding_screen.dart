import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await ref.read(onboardedProvider.notifier).complete();
            if (context.mounted) context.go('/quote');
          },
          child: Text('Get started with ${brand.name}'),
        ),
      ),
    );
  }
}