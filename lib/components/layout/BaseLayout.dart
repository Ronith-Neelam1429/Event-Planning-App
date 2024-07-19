import 'package:event_planning/components/NavBar.dart';
import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Function refreshEvents;

  BaseLayout({
    required this.child,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.refreshEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          FloatingNavBar(
            selectedIndex: selectedIndex,
            onItemTapped: onItemTapped,
            refreshEvents: refreshEvents,
          ),
        ],
      ),
    );
  }
}
