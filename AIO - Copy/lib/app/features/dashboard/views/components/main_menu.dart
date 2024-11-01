// My lib/app/views/components/main_menu.dart
part of dashboard;

class _MainMenu extends StatelessWidget {
  final bool isDarkMode;
  final Function(int index, SelectionButtonData value) onSelected;

  const _MainMenu({
    required this.onSelected,
    required this.isDarkMode, // required to ensure it’s always passed in
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        SelectionButton(
          data: [
            SelectionButtonData(
              activeIcon: EvaIcons.home,
              icon: EvaIcons.homeOutline,
              label: "Home",
              color: textColor,
            ),
            SelectionButtonData(
              activeIcon: EvaIcons.bell,
              icon: EvaIcons.bellOutline,
              label: "Notifications",
              totalNotif: 100,
              color: textColor,
            ),
            SelectionButtonData(
              activeIcon: EvaIcons.checkmarkCircle2,
              icon: EvaIcons.checkmarkCircle,
              label: "Task",
              totalNotif: 20,
              color: textColor,
            ),
            SelectionButtonData(
              activeIcon: EvaIcons.settings,
              icon: EvaIcons.settingsOutline,
              label: "Settings",
              color: textColor,
            ),
          ],
          onSelected: onSelected,
          textColor: textColor,
        ),
      ],
    );
  }
}

class SelectionButtonData {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int? totalNotif;
  final Color color;

  SelectionButtonData({
    required this.activeIcon,
    required this.icon,
    required this.label,
    this.totalNotif,
    required this.color, // enforce color requirement
  });
}

class SelectionButton extends StatelessWidget {
  final List<SelectionButtonData> data;
  final Function(int index, SelectionButtonData value) onSelected;
  final Color textColor;

  const SelectionButton({
    required this.data,
    required this.onSelected,
    required this.textColor, // enforce color requirement
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return ListTile(
          leading: Icon(item.icon, color: textColor), // use textColor
          title: Text(item.label, style: TextStyle(color: textColor)), // use textColor
          trailing: item.totalNotif != null
              ? Text(item.totalNotif.toString(), style: TextStyle(color: textColor))
              : null,
          onTap: () => onSelected(index, item),
        );
      }).toList(),
    );
  }
}
