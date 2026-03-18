import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final Widget child;

  const BottomNavBar({super.key, required this.child});

  // ─────────────────────────────────────
  // Routes + Icons + Labels — Ek jagah!
  // ─────────────────────────────────────

  static const List<String> _routes = [
    '/dashboard',
    '/medicines',
    '/health-records',
    '/ai-assistant',
    '/profile',
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.medication_outlined),
      selectedIcon: Icon(Icons.medication),
      label: 'Medicines',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: 'Records',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  // Calculate current tab
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexWhere((route) => location.startsWith(route));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) =>
            context.go(_routes[index]), // List se seedha navigate!
        destinations: _destinations,
      ),
    );
  }
}
