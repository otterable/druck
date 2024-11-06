// My lib/app/features/dashboard/views/components/main_menu.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class MainMenu extends StatelessWidget {
  final bool isDarkMode;

  const MainMenu({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Column(
      children: [
        SelectionButton(
          icon: EvaIcons.homeOutline,
          activeIcon: EvaIcons.home,
          label: "Home",
          textColor: textColor,
        ),
        SelectionButton(
          icon: EvaIcons.bellOutline,
          activeIcon: EvaIcons.bell,
          label: "Notifications",
          textColor: textColor,
        ),
        SelectionButton(
          icon: EvaIcons.checkmarkCircle,
          activeIcon: EvaIcons.checkmarkCircle2,
          label: "Completed",
          textColor: textColor,
        ),
        SelectionButton(
          icon: EvaIcons.settingsOutline,
          activeIcon: EvaIcons.settings,
          label: "Settings",
          textColor: textColor,
        ),
      ],
    );
  }
}

class SelectionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color textColor;

  const SelectionButton({
    Key? key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: () {},
    );
  }
}
