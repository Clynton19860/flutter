import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/onboarding_provider.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield, size: 72, color: cs.primary),
              const SizedBox(height: 24),
              Text('Welcome to ${brand.name}',
                  style: tt.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Get a motor insurance quote in under a minute. '
                'We only ask for what we need.',
                style: tt.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(onboardedProvider.notifier).complete(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
