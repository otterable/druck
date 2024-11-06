// My lib/app/features/dashboard/views/components/bottom_navbar.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';

class _BottomNavbar extends StatelessWidget {
  final bool isDarkMode;
  const _BottomNavbar({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54,
      selectedItemColor: isDarkMode ? Colors.white : Colors.black,
    );
  }
}
