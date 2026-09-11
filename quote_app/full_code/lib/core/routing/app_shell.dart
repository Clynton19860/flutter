import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        // The shell IS the body. Do not wrap it in another Navigator.
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(
            i,
            // re-tapping the current tab pops it back to its root
            initialLocation: i == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.calculate_outlined), label: 'Quote'),
            NavigationDestination(
                icon: Icon(Icons.bookmark_outline), label: 'Saved'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      );
}
