
// My lib/app/views/components/bottom_navbar.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

part of dashboard;

class _BottomNavbar extends StatelessWidget {
  final bool isDarkMode;

  const _BottomNavbar({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      selectedItemColor: isDarkMode ? Colors.white : Colors.black,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Index'),
        BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Order'),
        BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Manage Orders'),
      ],
      onTap: (index) {
        // Define actions for each tab index if needed
      },
    );
  }
}
