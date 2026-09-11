import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quote_app/core/storage/prefs_providers.dart';
import 'package:quote_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';
import 'package:quote_app/features/quote/presentation/result_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);

  return GoRouter(
    initialLocation: '/quote',

    debugLogDiagnostics: true,

    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation == '/onboarding';

      if (!onboarded && !goingToOnboarding) {
        return '/onboarding';
      }

      if (onboarded && goingToOnboarding) {
        return '/quote';
      }

      return null;
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
          GoRoute(
            path: 'result/:id',
            name: 'result',
            builder: (context, state) =>
                ResultScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
