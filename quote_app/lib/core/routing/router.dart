import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';
import 'package:quote_app/features/quote/presentation/result_screen.dart';
import '../storage/prefs_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);

  return GoRouter(
    initialLocation: '/quote',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !goingToOnboarding) return '/onboarding';
      if (onboarded && goingToOnboarding) return '/quote';
      return null; // null means "allow it"
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/quote',
        builder: (context, state) => const CaptureScreen(),
        routes: [
          // Relative path: 'result/:id' under '/quote' => /quote/result/q-123
          GoRoute(
            path: 'result/:id',
            name: 'result',
            builder: (context, state) =>
                ResultScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});