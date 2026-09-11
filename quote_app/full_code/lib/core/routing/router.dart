import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/routing/app_shell.dart';
import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';
import 'package:quote_app/features/quote/presentation/result_screen.dart';
import 'package:quote_app/features/quote/presentation/saved_quotes_screen.dart';
import 'package:quote_app/features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);

  return GoRouter(
    initialLocation: '/quote',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !goingToOnboarding) return '/onboarding';
      if (onboarded && goingToOnboarding) return '/quote';
      return null;
    },
    routes: [
      // Onboarding stays OUTSIDE the shell - no bottom bar during onboarding.
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(shell: navigationShell),
        branches: [
          // Routes inside branches need ABSOLUTE paths.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/quote',
              builder: (context, state) => const CaptureScreen(),
              routes: [
                GoRoute(
                  path: 'result/:id',
                  name: 'result',
                  builder: (context, state) =>
                      ResultScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedQuotesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/quote'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
});
