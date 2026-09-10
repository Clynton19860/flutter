import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell, // the shell IS the body
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) => shell.goBranch(
        i,
        initialLocation: i == shell.currentIndex, // re-tap pops to root
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          label: 'Quote',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    ),
  );
}
